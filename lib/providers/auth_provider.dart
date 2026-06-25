import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isDarkMode = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  String? get errorMessage => _errorMessage;
  String get userRole => _currentUser?.role ?? 'student';
  String? get tuitionId => _currentUser?.tuitionId;
  bool get isDarkMode => _isDarkMode;

  /// Initialize user from Firebase Auth state
  Future<void> initializeUser() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Load dark mode preference
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool('is_dark_mode') ?? false;

      final firebaseUser = _authService.currentUser;
      
      if (firebaseUser != null) {
        // Fetch role from Firestore with error handling
        String role = 'student'; // Default fallback
        
        try {
          final fetchedRole = await _firestoreService.getUserRole(firebaseUser.uid);
          if (fetchedRole != null && fetchedRole.isNotEmpty) {
            role = fetchedRole;
          }
        } catch (e) {
          debugPrint('AuthProvider: Failed to fetch role, using default: $e');
        }
        
        _currentUser = UserModel(
          uid: firebaseUser.uid,
          name: firebaseUser.email?.split('@')[0] ?? 'User',
          email: firebaseUser.email ?? '',
          role: role,
        );
        
        debugPrint('AuthProvider: User initialized with role: $role');
      } else {
        debugPrint('AuthProvider: No Firebase user found');
      }
    } catch (e) {
      debugPrint('AuthProvider: Error initializing user: $e');
      // Don't crash - just set loading to false
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign in with email and password
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _authService.signInWithEmail(email, password);
      final user = credential.user;
      
      if (user != null) {
        // Fetch role from Firestore with error handling
        String role = 'student'; // Default fallback
        
        try {
          final fetchedRole = await _firestoreService.getUserRole(user.uid);
          if (fetchedRole != null && fetchedRole.isNotEmpty) {
            role = fetchedRole;
          }
        } catch (e) {
          debugPrint('AuthProvider: Failed to fetch role after login, using default: $e');
        }
        
        _currentUser = UserModel(
          uid: user.uid,
          name: user.email?.split('@')[0] ?? 'User',
          email: user.email ?? '',
          role: role,
        );
        
        debugPrint('AuthProvider: User logged in with role: $role');
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      _errorMessage = 'Sign in failed';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign up with email, password, and role
  Future<bool> signUp(String email, String password, String name, String role) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _authService.signUpWithEmail(email, password);
      final user = credential.user;
      
      if (user != null) {
        // Save user data to Firestore
        await _firestoreService.saveUserData(
          uid: user.uid,
          name: name,
          email: user.email ?? '',
          role: role,
        );
        
        _currentUser = UserModel(
          uid: user.uid,
          name: name,
          email: user.email ?? '',
          role: role,
        );
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      _errorMessage = 'Sign up failed';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _currentUser = null;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Error signing out: $e');
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Send password reset email
  Future<bool> sendPasswordReset(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.sendPasswordResetEmail(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Send email verification link
  Future<bool> sendEmailVerification() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.sendEmailVerification();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Set user role (local only, no Firestore)
  Future<void> setUserRole(String role) async {
    if (_currentUser == null) return;

    _currentUser = _currentUser!.copyWith(role: role);
    notifyListeners();
  }

  /// Set tuition ID (local only, no Firestore)
  Future<void> setTuitionId(String tuitionId) async {
    if (_currentUser == null) return;

    _currentUser = _currentUser!.copyWith(tuitionId: tuitionId);
    notifyListeners();
  }

  /// Toggle and persist Dark Mode
  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', _isDarkMode);
    notifyListeners();
  }
}
