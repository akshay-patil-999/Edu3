import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign up with email and password
  Future<UserCredential> signUpWithEmail(String email, String password) async {
    try {
      debugPrint('Auth: Signing up with email: $email');
      
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      debugPrint('Auth: Sign up successful - ${userCredential.user?.email}');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('Auth: Sign up failed - ${e.code}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('Auth: Unexpected error - $e');
      throw Exception('Failed to create account: $e');
    }
  }

  /// Sign in with email and password
  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      debugPrint('Auth: Signing in with email: $email');
      
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      debugPrint('Auth: Sign in successful - ${userCredential.user?.email}');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('Auth: Sign in failed - ${e.code}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('Auth: Unexpected error - $e');
      throw Exception('Failed to sign in: $e');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      debugPrint('Auth: Signing out...');
      await _auth.signOut();
      debugPrint('Auth: Sign out successful');
    } catch (e) {
      debugPrint('Auth: Sign out error - $e');
      throw Exception('Failed to sign out: $e');
    }
  }

  /// Send Password Reset Email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      debugPrint('Auth: Sending password reset email to $email');
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to send reset email: $e');
    }
  }

  /// Send Email Verification
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        debugPrint('Auth: Sending email verification to ${user.email}');
        await user.sendEmailVerification();
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to send email verification: $e');
    }
  }

  /// Handle Firebase Auth Exceptions with user-friendly messages
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'user-not-found':
        return 'No user found for this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'Authentication error: ${e.message ?? e.code}';
    }
  }
}
