// 🧬 PROVIDER: Autenticação - Gerenciamento de Estado do Usuário

import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import '../services/auth_service_local.dart';

enum AuthStatus {
  uninitialized,
  authenticated,
  unauthenticated,
}

class AuthProvider extends ChangeNotifier {
  final _authService = AuthServiceLocal();
  
  AuthStatus _status = AuthStatus.uninitialized;
  UserProfile? _user;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserProfile? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  // 🧬 Inicializar provider
  Future<void> initialize() async {
    try {
      await _authService.initialize();
      final hasSession = await _authService.validateSession();
      
      if (hasSession) {
        _user = _authService.currentUser;
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  // 🧬 Registro
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      _errorMessage = null;
      _user = await _authService.signUp(
        email: email,
        password: password,
        name: name,
      );
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // 🧬 Login
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _errorMessage = null;
      _user = await _authService.signIn(
        email: email,
        password: password,
      );
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // 🧬 Logout
  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    _status = AuthStatus.unauthenticated;
    _errorMessage = null;
    notifyListeners();
  }

  // 🧬 Atualizar perfil
  Future<void> updateProfile(UserProfile updatedUser) async {
    try {
      _user = await _authService.updateProfile(updatedUser);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  // 🧬 Criar usuário demo
  Future<bool> createDemoUser() async {
    try {
      _errorMessage = null;
      _user = await _authService.createDemoUser();
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // 🧬 Limpar erro
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
