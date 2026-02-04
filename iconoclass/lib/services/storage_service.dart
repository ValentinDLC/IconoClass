// Local storage service using SharedPreferences
// Handles persistent storage of user data, app data, and settings
// Provides methods for saving, loading, and clearing cached data

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

class StorageService {
  static SharedPreferences? _preferences;

  // Storage keys
  static const String _keyUser = 'user_data';
  static const String _keyAppData = 'app_data';
  static const String _keySettings = 'app_settings';
  static const String _keyLastSync = 'last_sync_date';

  // Initialize SharedPreferences instance
  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // Ensure preferences are initialized
  static SharedPreferences get _prefs {
    if (_preferences == null) {
      throw Exception('StorageService not initialized. Call init() first.');
    }
    return _preferences!;
  }

  // ============ USER DATA ============

  // Save user data to storage
  static Future<bool> saveUser(Map<String, dynamic> userData) async {
    try {
      final jsonString = jsonEncode(userData);
      return await _prefs.setString(_keyUser, jsonString);
    } catch (e) {
      developer.log('Error saving user data: $e');
      return false;
    }
  }

  // Get user data from storage
  static Future<Map<String, dynamic>?> getUser() async {
    try {
      final jsonString = _prefs.getString(_keyUser);
      if (jsonString == null) return null;
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      developer.log('Error getting user data: $e');
      return null;
    }
  }

  // Clear user data (logout)
  static Future<bool> clearUser() async {
    try {
      return await _prefs.remove(_keyUser);
    } catch (e) {
      developer.log('Error clearing user data: $e');
      return false;
    }
  }

  // ============ APP DATA ============

  // Save app data (sessions, instructors, badges, etc.)
  static Future<bool> saveAppData(Map<String, dynamic> appData) async {
    try {
      final jsonString = jsonEncode(appData);
      return await _prefs.setString(_keyAppData, jsonString);
    } catch (e) {
      developer.log('Error saving app data: $e');
      return false;
    }
  }

  // Get app data from storage
  static Future<Map<String, dynamic>?> getAppData() async {
    try {
      final jsonString = _prefs.getString(_keyAppData);
      if (jsonString == null) return null;
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      developer.log('Error getting app data: $e');
      return null;
    }
  }

  // Clear app data
  static Future<bool> clearAppData() async {
    try {
      return await _prefs.remove(_keyAppData);
    } catch (e) {
      developer.log('Error clearing app data: $e');
      return false;
    }
  }

  // ============ SETTINGS ============

  // Save app settings
  static Future<bool> saveSettings(Map<String, dynamic> settings) async {
    try {
      final jsonString = jsonEncode(settings);
      return await _prefs.setString(_keySettings, jsonString);
    } catch (e) {
      developer.log('Error saving settings: $e');
      return false;
    }
  }

  // Get app settings
  static Future<Map<String, dynamic>?> getSettings() async {
    try {
      final jsonString = _prefs.getString(_keySettings);
      if (jsonString == null) return null;
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      developer.log('Error getting settings: $e');
      return null;
    }
  }

  // ============ SYNC DATE ============

  // Save last sync date
  static Future<bool> saveLastSyncDate(DateTime date) async {
    try {
      return await _prefs.setString(_keyLastSync, date.toIso8601String());
    } catch (e) {
      developer.log('Error saving last sync date: $e');
      return false;
    }
  }

  // Get last sync date
  static Future<DateTime?> getLastSyncDate() async {
    try {
      final dateString = _prefs.getString(_keyLastSync);
      if (dateString == null) return null;
      return DateTime.parse(dateString);
    } catch (e) {
      developer.log('Error getting last sync date: $e');
      return null;
    }
  }

  // ============ CACHE MANAGEMENT ============

  // Clear all cached data (keeps user session)
  static Future<bool> clearCache() async {
    try {
      await clearAppData();
      await _prefs.remove(_keyLastSync);
      return true;
    } catch (e) {
      developer.log('Error clearing cache: $e');
      return false;
    }
  }

  // Clear all storage (complete reset)
  static Future<bool> clearAll() async {
    try {
      return await _prefs.clear();
    } catch (e) {
      developer.log('Error clearing all storage: $e');
      return false;
    }
  }

  // ============ GENERIC KEY-VALUE STORAGE ============

  // Save string value
  static Future<bool> setString(String key, String value) async {
    try {
      return await _prefs.setString(key, value);
    } catch (e) {
      developer.log('Error setting string: $e');
      return false;
    }
  }

  // Get string value
  static String? getString(String key) {
    try {
      return _prefs.getString(key);
    } catch (e) {
      developer.log('Error getting string: $e');
      return null;
    }
  }

  // Save int value
  static Future<bool> setInt(String key, int value) async {
    try {
      return await _prefs.setInt(key, value);
    } catch (e) {
      developer.log('Error setting int: $e');
      return false;
    }
  }

  // Get int value
  static int? getInt(String key) {
    try {
      return _prefs.getInt(key);
    } catch (e) {
      developer.log('Error getting int: $e');
      return null;
    }
  }

  // Save bool value
  static Future<bool> setBool(String key, bool value) async {
    try {
      return await _prefs.setBool(key, value);
    } catch (e) {
      developer.log('Error setting bool: $e');
      return false;
    }
  }

  // Get bool value
  static bool? getBool(String key) {
    try {
      return _prefs.getBool(key);
    } catch (e) {
      developer.log('Error getting bool: $e');
      return null;
    }
  }

  // Remove specific key
  static Future<bool> remove(String key) async {
    try {
      return await _prefs.remove(key);
    } catch (e) {
      developer.log('Error removing key: $e');
      return false;
    }
  }

  // Check if key exists
  static bool containsKey(String key) {
    try {
      return _prefs.containsKey(key);
    } catch (e) {
      developer.log('Error checking key: $e');
      return false;
    }
  }
}
