// 🧬 SERVIÇO: Autenticação - Identidade do Organismo Digital
// Inspiração: Sistema de reconhecimento biológico (DNA/RNA)

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🧬 Stream de estado de autenticação (pulsação vital)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // 🧬 Usuário atual
  User? get currentUser => _auth.currentUser;

  // 🧬 Registro (nascimento digital)
  Future<UserProfile?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Criar conta Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) return null;

      // Criar perfil no Firestore
      final userProfile = UserProfile(
        id: user.uid,
        email: email,
        name: name,
        createdAt: DateTime.now(),
        lastActive: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userProfile.toFirestore());

      return userProfile;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro no registro: $e');
      }
      rethrow;
    }
  }

  // 🧬 Login (reconhecimento de identidade)
  Future<UserProfile?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) return null;

      // Atualizar última atividade
      await _firestore.collection('users').doc(user.uid).update({
        'last_active': Timestamp.now(),
      });

      // Buscar perfil
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return null;

      return UserProfile.fromFirestore(doc);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro no login: $e');
      }
      rethrow;
    }
  }

  // 🧬 Logout (suspensão temporária)
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro no logout: $e');
      }
      rethrow;
    }
  }

  // 🧬 Buscar perfil do usuário
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return null;
      return UserProfile.fromFirestore(doc);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro ao buscar perfil: $e');
      }
      return null;
    }
  }

  // 🧬 Atualizar perfil
  Future<void> updateUserProfile(UserProfile profile) async {
    try {
      await _firestore
          .collection('users')
          .doc(profile.id)
          .update(profile.toFirestore());
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro ao atualizar perfil: $e');
      }
      rethrow;
    }
  }

  // 🧬 Resetar senha
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro ao resetar senha: $e');
      }
      rethrow;
    }
  }

  // 🧬 Deletar conta (morte digital)
  Future<void> deleteAccount() async {
    try {
      final user = currentUser;
      if (user == null) return;

      // Deletar dados do Firestore
      await _firestore.collection('users').doc(user.uid).delete();

      // Deletar conta Firebase Auth
      await user.delete();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro ao deletar conta: $e');
      }
      rethrow;
    }
  }
}
