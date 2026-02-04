// Authentication service for handling user authentication
// Manages login, registration, and credential validation
// Currently uses mock authentication - can be extended to use Firebase or custom API

import 'package:uuid/uuid.dart';
import '../models/user.dart';

// Logger instance used for structured logging throughout the app
import 'package:logger/logger.dart';

final Logger logger = Logger();

class AuthService {
  static const _uuid = Uuid();

  // Mock user database (replace with real API/Firebase in production)
  static final List<Map<String, dynamic>> _mockUsers = [
    {
      'email': 'edson.kouebi@email.com',
      'password': 'password123',
      'firstName': 'Edson',
      'lastName': 'Kouebi',
      'role': 'student',
    },
    {
      'email': 'instructor@iconoclass.com',
      'password': 'instructor123',
      'firstName': 'Jean',
      'lastName': 'Dupont',
      'role': 'instructor',
    },
    {
      'email': 'admin@iconoclass.com',
      'password': 'admin123',
      'firstName': 'Admin',
      'lastName': 'User',
      'role': 'admin',
    },
  ];

  // Login user with email and password
  static Future<User?> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      // Find user in mock database
      final userData = _mockUsers.firstWhere(
        (user) =>
            user['email']?.toLowerCase() == email.toLowerCase() &&
            user['password'] == password,
        orElse: () => {},
      );

      if (userData.isEmpty) {
        return null; // Invalid credentials
      }

      // Create and return User object
      return User(
        id: _uuid.v4(),
        firstName: userData['firstName'] as String,
        lastName: userData['lastName'] as String,
        email: userData['email'] as String,
        role: _parseUserRole(userData['role'] as String?),
      );
    } catch (e, stackTrace) {
      logger.e('Login error', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  // Register new user
  static Future<User?> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    UserRole role = UserRole.student,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      // Check if email already exists
      final emailExists = _mockUsers.any(
        (user) => user['email']?.toLowerCase() == email.toLowerCase(),
      );

      if (emailExists) {
        throw Exception('Email already registered');
      }

      // Validate input
      if (firstName.isEmpty ||
          lastName.isEmpty ||
          email.isEmpty ||
          password.isEmpty) {
        throw Exception('All fields are required');
      }

      if (!_isValidEmail(email)) {
        throw Exception('Invalid email format');
      }

      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }

      // Add user to mock database
      _mockUsers.add({
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'role': role.toString().split('.').last,
      });

      // Create and return User object
      return User(
        id: _uuid.v4(),
        firstName: firstName,
        lastName: lastName,
        email: email,
        role: role,
      );
    } catch (e, stackTrace) {
      logger.e('Registration error', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  // Validate email format
  static bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  // Parse user role from string
  static UserRole _parseUserRole(String? roleStr) {
    if (roleStr == null) return UserRole.student;

    switch (roleStr.toLowerCase()) {
      case 'instructor':
        return UserRole.instructor;
      case 'admin':
        return UserRole.admin;
      case 'student':
      default:
        return UserRole.student;
    }
  }

  // Verify current user session (check if token is valid)
  static Future<User?> verifySession(String userId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // In production, this would validate a session token with the backend
    // For now, we return null to indicate session should be checked via storage
    return null;
  }

  // Password reset (mock implementation)
  static Future<bool> resetPassword(String email) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1000));

    try {
      // Check if email exists
      final emailExists = _mockUsers.any(
        (user) => user['email']?.toLowerCase() == email.toLowerCase(),
      );

      if (!emailExists) {
        throw Exception('Email not found');
      }

      // In production, this would send a password reset email
      logger.i('Password reset email sent to: $email');
      return true;
    } catch (e, stackTrace) {
      logger.e('Password reset error', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  // Change password (mock implementation)
  static Future<bool> changePassword({
    required String userId,
    required String oldPassword,
    required String newPassword,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      if (newPassword.length < 6) {
        throw Exception('New password must be at least 6 characters');
      }

      // In production, this would update the password in the backend
      logger.i('Password changed for user: $userId');
      return true;
    } catch (e, stackTrace) {
      logger.e('Change password error', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  // Delete account (mock implementation)
  static Future<bool> deleteAccount(String userId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      // In production, this would delete the account from the backend
      logger.i('Account deleted: $userId');
      return true;
    } catch (e, stackTrace) {
      logger.e('Delete account error', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  // Update user profile
  static Future<User?> updateProfile({
    required String userId,
    String? firstName,
    String? lastName,
    String? email,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // In production, this would update the profile in the backend
    // For now, we just return null to indicate the update should be handled locally
    return null;
  }
}
