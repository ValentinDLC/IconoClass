/*
  local_storage.dart
  IconoClass - Learning Platform
  This file handles saving and loading AppData locally using SharedPreferences.
*/

import 'package:logger/logger.dart';
final Logger logger = Logger ();

// Import for JSON encoding/decoding
import 'dart:convert';

// Import SharedPreferences package for local storage
import 'package:shared_preferences/shared_preferences.dart';

// Import the AppData model
import '../models/app_data.dart';

/// LocalStorage class to manage saving and loading app data locally
class LocalStorage {
  // Key used to store the app data in SharedPreferences
  static const String _key = 'iconoclass_data';

  /// Save the AppData to local storage
  /// Converts AppData to JSON string and stores it in SharedPreferences
  static Future<void> saveData(AppData data) async {
    // Get instance of SharedPreferences
    final prefs = await SharedPreferences.getInstance();

    // Convert AppData to JSON string and save it
    await prefs.setString(_key, jsonEncode(data.toJson()));
  }

  /// Load AppData from local storage
  /// Returns null if no data exists or if decoding fails
  static Future<AppData?> loadData() async {
    // Get instance of SharedPreferences
    final prefs = await SharedPreferences.getInstance();

    // Retrieve the JSON string stored under the key
    final jsonString = prefs.getString(_key);

    if (jsonString != null) {
      try {
        // Decode JSON string to Map
        final jsonData = jsonDecode(jsonString);

        // Convert Map to AppData object
        return AppData.fromJson(jsonData);
      } catch (e) {
        // logger.e error if JSON decoding fails
        logger.e('Error loading data', error: e);
        return null;
      }
    }

    // Return null if no data found
    return null;
  }
}
