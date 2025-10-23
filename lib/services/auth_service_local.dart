// 🧬 SERVIÇO: Autenticação Local - Sistema de Identidade Híbrido
// Funciona offline, sincroniza com Firebase quando disponível

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';
import 'local_storage_service.dart';

class AuthServiceLocal {
  // 🧬 Singleton
  static final AuthServiceLocal _instance = AuthServiceLocal._internal();
  factory AuthServiceLocal() => _instance;
  AuthServiceLocal._internal();

  final _storage = LocalStorageService();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  
  // 🧬 Keys para SharedPreferences
  static const String _authTokenKey = 'auth_token';
  static const String _userCredentialsKey = 'user_credentials';

  // 🧬 Estado atual de autenticação
  UserProfile? _currentUser;
  UserProfile? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  // 🧬 Inicializar autenticação (verificar sessão existente)
  Future<void> initialize() async {
    _currentUser = await _storage.getCurrentUser();
  }

  // 🧬 Registro de novo usuário (offline-first)
  Future<UserProfile> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    // Validações básicas
    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      throw Exception('Todos os campos são obrigatórios');
    }

    if (!_isValidEmail(email)) {
      throw Exception('Email inválido');
    }

    if (password.length < 6) {
      throw Exception('Senha deve ter pelo menos 6 caracteres');
    }

    // Verificar se email já existe
    final prefs = await SharedPreferences.getInstance();
    final existingCredentials = prefs.getString(_userCredentialsKey);
    
    if (existingCredentials != null) {
      final credentials = Map<String, dynamic>.from(
        json.decode(existingCredentials) as Map,
      );
      
      if (credentials['email'] == email) {
        throw Exception('Email já cadastrado');
      }
    }

    // Criar usuário
    final user = await _storage.createUser(
      email: email,
      name: name,
    );

    // Salvar credenciais (hash da senha)
    final passwordHash = _hashPassword(password);
    await prefs.setString(_userCredentialsKey, json.encode({
      'email': email,
      'password_hash': passwordHash,
      'user_id': user.id,
    }));

    // Gerar token de sessão
    final token = _generateToken(user.id);
    await prefs.setString(_authTokenKey, token);

    _currentUser = user;
    return user;
  }

  // 🧬 Login (verificação local)
  Future<UserProfile> signIn({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email e senha são obrigatórios');
    }

    final prefs = await SharedPreferences.getInstance();
    final credentialsJson = prefs.getString(_userCredentialsKey);

    if (credentialsJson == null) {
      throw Exception('Usuário não encontrado. Faça o cadastro primeiro.');
    }

    final credentials = Map<String, dynamic>.from(
      json.decode(credentialsJson) as Map,
    );

    // Verificar email
    if (credentials['email'] != email) {
      throw Exception('Email ou senha incorretos');
    }

    // Verificar senha
    final passwordHash = _hashPassword(password);
    if (credentials['password_hash'] != passwordHash) {
      throw Exception('Email ou senha incorretos');
    }

    // Buscar usuário
    final userId = credentials['user_id'] as String;
    final user = await _storage.getCurrentUser();

    if (user == null || user.id != userId) {
      throw Exception('Erro ao recuperar dados do usuário');
    }

    // Atualizar última atividade
    final updatedUser = user.copyWith(lastActive: DateTime.now());
    await _storage.updateUser(updatedUser);

    // Gerar novo token
    final token = _generateToken(user.id);
    await prefs.setString(_authTokenKey, token);

    _currentUser = updatedUser;
    return updatedUser;
  }

  // 🧬 Login com Google
  Future<UserProfile> signInWithGoogle() async {
    try {
      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw Exception('Login cancelado pelo usuário');
      }

      // Obtain auth details from request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw Exception('Erro ao autenticar com Google');
      }

      // Criar ou atualizar usuário local
      UserProfile? existingUser = await _storage.getCurrentUser();
      
      UserProfile user;
      if (existingUser != null && existingUser.email == firebaseUser.email) {
        // Atualizar usuário existente
        user = existingUser.copyWith(
          name: firebaseUser.displayName ?? existingUser.name,
          lastActive: DateTime.now(),
        );
      } else {
        // Criar novo usuário
        user = await _storage.createUser(
          email: firebaseUser.email ?? 'no-email@google.com',
          name: firebaseUser.displayName ?? 'Usuário Google',
        );
      }

      await _storage.updateUser(user);

      // Gerar token de sessão
      final prefs = await SharedPreferences.getInstance();
      final token = _generateToken(user.id);
      await prefs.setString(_authTokenKey, token);

      _currentUser = user;
      return user;
    } catch (e) {
      throw Exception('Erro ao fazer login com Google: ${e.toString()}');
    }
  }

  // 🧬 Logout
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey);
    await _storage.clearCurrentUser();
    
    // Sign out from Google if signed in
    if (await _googleSignIn.isSignedIn()) {
      await _googleSignIn.signOut();
    }
    
    // Sign out from Firebase
    await _firebaseAuth.signOut();
    
    _currentUser = null;
  }

  // 🧬 Verificar token de sessão
  Future<bool> validateSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_authTokenKey);
    
    if (token == null) return false;

    final user = await _storage.getCurrentUser();
    if (user == null) return false;

    _currentUser = user;
    return true;
  }

  // 🧬 Atualizar perfil
  Future<UserProfile> updateProfile(UserProfile user) async {
    await _storage.updateUser(user);
    _currentUser = user;
    return user;
  }

  // 🧬 Deletar conta
  Future<void> deleteAccount() async {
    if (_currentUser == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey);
    await prefs.remove(_userCredentialsKey);
    await _storage.clearAllData();
    
    _currentUser = null;
  }

  // 🧬 Utilitários privados

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  String _generateToken(String userId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final data = '$userId:$timestamp';
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // 🧬 Modo de demonstração (usuário de teste)
  Future<UserProfile> createDemoUser() async {
    return await signUp(
      email: 'demo@nexialfinance.com',
      password: 'demo123',
      name: 'Usuário Demo',
    );
  }
}
