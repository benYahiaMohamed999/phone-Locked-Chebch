import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  bool _isAuthenticated = false;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      _isAuthenticated = user != null;
      notifyListeners();
    });
  }

  User? get user => _user;
  bool get isAuthenticated => _isAuthenticated;

  Future<void> signIn(String email, String password) async {
    try {
      // Firebase Auth on certain platforms can throw pigeon conversion errors
      // when handling PigeonUserDetails objects
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      // Rethrow Firebase auth exceptions to be handled by UI
      rethrow;
    } catch (e) {
      // Handle potential pigeon conversion errors or other exceptions
      debugPrint('Authentication error: $e');
      throw FirebaseAuthException(
        code: 'auth-error',
        message: 'Authentication failed. Please try again.',
      );
    }
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      rethrow;
    }
  }
}
