// Authentication provider for managing user authentication state
// Handles login, logout, registration, and persistent session management
// Uses ChangeNotifier for reactive state updates across the app

import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/storage_service.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Initialize provider and check for existing session
  AuthProvider() {
    _loadUserFromStorage();
  }

  // Load user from local storage on app start (persistent session)
  Future<void> _loadUserFromStorage() async {
    try {
      _isLoading = true;
      notifyListeners();

      final userData = await StorageService.getUser();
      if (userData != null) {
        _currentUser = User.fromJson(userData);
      }
    } catch (e) {
      debugPrint('Error loading user from storage: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login with email and password
  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Authenticate user via auth service
      final user = await AuthService.login(email, password);

      if (user != null) {
        _currentUser = user;
        // Save user to local storage for persistent session
        await StorageService.saveUser(user.toJson());
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Email ou mot de passe incorrect';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Erreur de connexion: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register new user account
  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    UserRole role = UserRole.student,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Create new user via auth service
      final user = await AuthService.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        role: role,
      );

      if (user != null) {
        _currentUser = user;
        // Save user to local storage
        await StorageService.saveUser(user.toJson());
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Erreur lors de la création du compte';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Erreur: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout and clear session
  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Clear user from storage
      await StorageService.clearUser();
      _currentUser = null;
      _errorMessage = null;
    } catch (e) {
      debugPrint('Error during logout: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update user profile information
  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
  }) async {
    if (_currentUser == null) return false;

    try {
      _isLoading = true;
      notifyListeners();

      // Update user object with new information
      final updatedUser = _currentUser!.copyWith(
        firstName: firstName ?? _currentUser!.firstName,
        lastName: lastName ?? _currentUser!.lastName,
        email: email ?? _currentUser!.email,
      );

      // Save updated user to storage
      await StorageService.saveUser(updatedUser.toJson());
      _currentUser = updatedUser;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de la mise à jour: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Check if current user is an instructor
  bool get isInstructor => _currentUser?.isInstructor ?? false;

  // Check if current user is an admin
  bool get isAdmin => _currentUser?.isAdmin ?? false;
}
