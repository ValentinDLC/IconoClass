// Google Sheets service for syncing app data with Google Sheets
// Handles reading and writing sessions, instructors, and other data
// Provides automatic synchronization with cloud-based spreadsheet storage

import 'package:gsheets/gsheets.dart';
import '../models/session.dart';
import '../models/instructor.dart';

// Logger instance used for structured logging throughout the app
import 'package:logger/logger.dart';

final Logger logger = Logger();

class SheetsService {
  // Google Sheets credentials (replace with your own credentials)
  // To get credentials:
  // 1. Go to Google Cloud Console
  // 2. Create a new project or select existing
  // 3. Enable Google Sheets API
  // 4. Create service account credentials
  // 5. Share your Google Sheet with the service account email
  static const _credentials = r'''
  {
    "type": "service_account",
    "project_id": "your-project-id",
    "private_key_id": "your-private-key-id",
    "private_key": "-----BEGIN PRIVATE KEY-----\nYOUR_PRIVATE_KEY\n-----END PRIVATE KEY-----\n",
    "client_email": "your-service-account@your-project.iam.gserviceaccount.com",
    "client_id": "your-client-id",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url": "your-cert-url"
  }
  ''';

  // Replace with your Google Sheet ID
  static const _spreadsheetId = 'YOUR_SPREADSHEET_ID_HERE';

  // Sheet names
  static const _sessionsSheetName = 'Sessions';
  static const _instructorsSheetName = 'Instructors';

  static GSheets? _gsheets;
  static Spreadsheet? _spreadsheet;
  static Worksheet? _sessionsSheet;
  static Worksheet? _instructorsSheet;

  static bool _isInitialized = false;

  // Initialize Google Sheets connection
  static Future<void> _initialize() async {
    if (_isInitialized) return;

    try {
      _gsheets = GSheets(_credentials);
      _spreadsheet = await _gsheets!.spreadsheet(_spreadsheetId);

      _sessionsSheet = _spreadsheet!.worksheetByTitle(_sessionsSheetName);
      _instructorsSheet = _spreadsheet!.worksheetByTitle(_instructorsSheetName);

      // Create sheets if they don't exist
      _sessionsSheet ??= await _spreadsheet!.addWorksheet(_sessionsSheetName);
      _instructorsSheet ??=
          await _spreadsheet!.addWorksheet(_instructorsSheetName);

      // Initialize headers if needed
      await _initializeHeaders();

      _isInitialized = true;
    } catch (e, stackTrace) {
      logger.e(
        'Error initializing Google Sheets. Update credentials and spreadsheet ID in sheets_service.dart',
        error: e,
        stackTrace: stackTrace,
      );
      // Don't throw - allow app to work offline
    }
  }

  // Initialize sheet headers
  static Future<void> _initializeHeaders() async {
    try {
      // Sessions sheet headers
      final sessionsHeaders = await _sessionsSheet!.values.row(1);
      if (sessionsHeaders.isEmpty) {
        await _sessionsSheet!.values.insertRow(1, [
          'ID',
          'Title',
          'Time',
          'Instructor',
          'Zoom Link',
          'Is Live',
          'Date',
          'Description',
        ]);
      }

      // Instructors sheet headers
      final instructorsHeaders = await _instructorsSheet!.values.row(1);
      if (instructorsHeaders.isEmpty) {
        await _instructorsSheet!.values.insertRow(1, [
          'ID',
          'Name',
          'Role',
          'Specialty',
          'LinkedIn URL',
          'Email',
          'Photo URL',
          'Bio',
        ]);
      }
    } catch (e, stackTrace) {
      logger.e('Error initializing headers', error: e, stackTrace: stackTrace);
    }
  }

  // ============ SESSIONS ============

  // Get all sessions from Google Sheets
  static Future<List<Session>> getSessions() async {
    try {
      await _initialize();

      if (_sessionsSheet == null) {
        logger.w('Sessions sheet not initialized');
        return [];
      }

      // Get all rows (skip header row)
      final rows = await _sessionsSheet!.values.allRows();

      if (rows.length <= 1) {
        // No data rows (only header or empty)
        return [];
      }

      // Convert rows to Session objects (skip header)
      final sessions = <Session>[];
      for (var i = 1; i < rows.length; i++) {
        try {
          final session = Session.fromSheetRow(rows[i]);
          sessions.add(session);
        } catch (e, stackTrace) {
          logger.e('Error parsing session row $i',
              error: e, stackTrace: stackTrace);
        }
      }

      return sessions;
    } catch (e, stackTrace) {
      logger.e('Error getting sessions from sheets',
          error: e, stackTrace: stackTrace);
      return [];
    }
  }

  // Add new session to Google Sheets
  static Future<bool> addSession(Session session) async {
    try {
      await _initialize();

      if (_sessionsSheet == null) {
        logger.w('Sessions sheet not initialized');
        return false;
      }

      // Add session row
      await _sessionsSheet!.values.appendRow(session.toSheetRow());
      return true;
    } catch (e, stackTrace) {
      logger.e('Error adding session to sheets',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  // Update existing session in Google Sheets
  static Future<bool> updateSession(Session session) async {
    try {
      await _initialize();

      if (_sessionsSheet == null) {
        logger.w('Sessions sheet not initialized');
        return false;
      }

      // Find row with matching ID
      final allRows = await _sessionsSheet!.values.allRows();
      for (var i = 1; i < allRows.length; i++) {
        if (allRows[i].isNotEmpty && allRows[i][0] == session.id) {
          // Update the row
          await _sessionsSheet!.values.insertRow(i + 1, session.toSheetRow());
          return true;
        }
      }

      logger.w('Session not found: ${session.id}');
      return false;
    } catch (e, stackTrace) {
      logger.e('Error updating session in sheets',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  // Delete session from Google Sheets
  static Future<bool> deleteSession(String sessionId) async {
    try {
      await _initialize();

      if (_sessionsSheet == null) {
        logger.w('Sessions sheet not initialized');
        return false;
      }

      // Find and delete row with matching ID
      final allRows = await _sessionsSheet!.values.allRows();
      for (var i = 1; i < allRows.length; i++) {
        if (allRows[i].isNotEmpty && allRows[i][0] == sessionId) {
          await _sessionsSheet!.deleteRow(i + 1);
          return true;
        }
      }

      logger.w('Session not found: $sessionId');
      return false;
    } catch (e, stackTrace) {
      logger.e('Error deleting session from sheets',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  // ============ INSTRUCTORS ============

  // Get all instructors from Google Sheets
  static Future<List<Instructor>> getInstructors() async {
    try {
      await _initialize();

      if (_instructorsSheet == null) {
        logger.w('Instructors sheet not initialized');
        return [];
      }

      // Get all rows (skip header row)
      final rows = await _instructorsSheet!.values.allRows();

      if (rows.length <= 1) {
        // No data rows (only header or empty)
        return [];
      }

      // Convert rows to Instructor objects (skip header)
      final instructors = <Instructor>[];
      for (var i = 1; i < rows.length; i++) {
        try {
          final instructor = Instructor.fromSheetRow(rows[i]);
          instructors.add(instructor);
        } catch (e, stackTrace) {
          logger.e('Error parsing instructor row $i',
              error: e, stackTrace: stackTrace);
        }
      }

      return instructors;
    } catch (e, stackTrace) {
      logger.e('Error getting instructors from sheets',
          error: e, stackTrace: stackTrace);
      return [];
    }
  }

  // Add new instructor to Google Sheets
  static Future<bool> addInstructor(Instructor instructor) async {
    try {
      await _initialize();

      if (_instructorsSheet == null) {
        logger.w('Instructors sheet not initialized');
        return false;
      }

      // Add instructor row
      await _instructorsSheet!.values.appendRow(instructor.toSheetRow());
      return true;
    } catch (e, stackTrace) {
      logger.e('Error adding instructor to sheets',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  // Clear cache and force re-initialization
  static void reset() {
    _isInitialized = false;
    _gsheets = null;
    _spreadsheet = null;
    _sessionsSheet = null;
    _instructorsSheet = null;
  }
}
