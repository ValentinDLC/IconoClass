// App data provider for managing application-wide data
// Handles sessions, instructors, badges, challenges, and user progress
// Syncs data with Google Sheets and local storage for offline access

import 'package:flutter/foundation.dart';
import '../models/session.dart';
import '../models/instructor.dart';
import '../models/badge.dart';
import '../models/challenge.dart';
import '../services/storage_service.dart';
import '../services/sheets_service.dart';

class AppDataProvider with ChangeNotifier {
  List<Session> _sessions = [];
  List<Instructor> _instructors = [];
  List<Badge> _badges = [];
  List<Challenge> _challenges = [];

  int _level = 5;
  int _points = 1250;
  int _promoProgress = 0;
  int _rdvProgress = 75;

  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _lastSyncDate;

  // Getters
  List<Session> get sessions => _sessions;
  List<Session> get todaySessions => _sessions.where((s) => s.isToday).toList();
  Session? get liveSession =>
      _sessions.firstWhere((s) => s.isLive, orElse: () => _sessions.first);

  List<Instructor> get instructors => _instructors;
  List<Badge> get badges => _badges;
  List<Badge> get unlockedBadges => _badges.where((b) => b.unlocked).toList();
  List<Challenge> get challenges => _challenges;
  List<Challenge> get activeChallenges =>
      _challenges.where((c) => c.isActive).toList();

  int get level => _level;
  int get points => _points;
  int get promoProgress => _promoProgress;
  int get rdvProgress => _rdvProgress;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime? get lastSyncDate => _lastSyncDate;

  // Initialize provider and load data
  AppDataProvider() {
    _initializeData();
  }

  // Initialize data from storage and sync with Google Sheets
  Future<void> _initializeData() async {
    await _loadFromStorage();
    await syncWithSheets();
  }

  // Load all data from local storage
  Future<void> _loadFromStorage() async {
    try {
      final appData = await StorageService.getAppData();
      if (appData != null) {
        // Load sessions
        if (appData['sessions'] != null) {
          _sessions = (appData['sessions'] as List)
              .map((s) => Session.fromJson(s as Map<String, dynamic>))
              .toList();
        }

        // Load instructors
        if (appData['instructors'] != null) {
          _instructors = (appData['instructors'] as List)
              .map((i) => Instructor.fromJson(i as Map<String, dynamic>))
              .toList();
        }

        // Load badges
        if (appData['badges'] != null) {
          _badges = (appData['badges'] as List)
              .map((b) => Badge.fromJson(b as Map<String, dynamic>))
              .toList();
        } else {
          _badges = DefaultBadges.defaultBadges;
        }

        // Load challenges
        if (appData['challenges'] != null) {
          _challenges = (appData['challenges'] as List)
              .map((c) => Challenge.fromJson(c as Map<String, dynamic>))
              .toList();
        } else {
          _challenges = DefaultChallenges.defaultChallenges;
        }

        // Load progress stats
        _level = appData['level'] as int? ?? 5;
        _points = appData['points'] as int? ?? 1250;
        _promoProgress =
            appData['promoProgress'] as int? ?? _calculatePromoProgress();
        _rdvProgress = appData['rdvProgress'] as int? ?? 75;

        notifyListeners();
      } else {
        // Initialize with default data if no storage data exists
        _initializeDefaultData();
      }
    } catch (e) {
      debugPrint('Error loading from storage: $e');
      _initializeDefaultData();
    }
  }

  // Initialize with default data
  void _initializeDefaultData() {
    _sessions = [
      Session(
        id: '1',
        title: 'Fondamentaux du Sales',
        time: '08:30 - 10:00',
        instructor: 'Thomas Durant',
      ),
      Session(
        id: '2',
        title: 'Pitch & Storytelling',
        time: '10:30 - 12:00',
        instructor: 'Sarah Bernand',
      ),
      Session(
        id: 'live',
        title: 'Techniques de closing avancé',
        time: '09:30 - 12:30',
        instructor: 'Expert',
        zoomLink: 'https://app.zoom.us/wc/4321432126/join?fromPWA=1',
        isLive: true,
      ),
    ];

    _instructors = [
      Instructor(
        id: '1',
        name: 'Jean Dupont',
        role: 'Expert closing',
        specialty: 'CLOSING',
        linkedinUrl: 'https://www.linkedin.com/in/edson-kouebi/',
      ),
      Instructor(
        id: '2',
        name: 'Marie Martin',
        role: 'Psychologue vente',
        specialty: 'PSYCHO',
        linkedinUrl: 'https://www.linkedin.com/in/edson-kouebi/',
      ),
      Instructor(
        id: '3',
        name: 'Lucas Bernard',
        role: 'Coach B2B',
        specialty: 'CLOSING',
        linkedinUrl: 'https://www.linkedin.com/in/edson-kouebi/',
      ),
    ];

    _badges = DefaultBadges.defaultBadges;
    _challenges = DefaultChallenges.defaultChallenges;
    _promoProgress = _calculatePromoProgress();

    notifyListeners();
    _saveToStorage();
  }

  // Calculate promotion progress in days
  int _calculatePromoProgress() {
    final startDate = DateTime(2025, 1, 20);
    final today = DateTime.now();
    final difference = today.difference(startDate).inDays;
    return difference.clamp(0, 90);
  }

  // Save all data to local storage
  Future<void> _saveToStorage() async {
    try {
      final appData = {
        'sessions': _sessions.map((s) => s.toJson()).toList(),
        'instructors': _instructors.map((i) => i.toJson()).toList(),
        'badges': _badges.map((b) => b.toJson()).toList(),
        'challenges': _challenges.map((c) => c.toJson()).toList(),
        'level': _level,
        'points': _points,
        'promoProgress': _promoProgress,
        'rdvProgress': _rdvProgress,
      };
      await StorageService.saveAppData(appData);
    } catch (e) {
      debugPrint('Error saving to storage: $e');
    }
  }

  // Sync data with Google Sheets
  Future<void> syncWithSheets() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Fetch sessions from Google Sheets
      final sheetSessions = await SheetsService.getSessions();
      if (sheetSessions.isNotEmpty) {
        _sessions = sheetSessions;
      }

      // Fetch instructors from Google Sheets
      final sheetInstructors = await SheetsService.getInstructors();
      if (sheetInstructors.isNotEmpty) {
        _instructors = sheetInstructors;
      }

      _lastSyncDate = DateTime.now();
      await _saveToStorage();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur de synchronisation: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      debugPrint('Sync error: $e');
    }
  }

  // Add new session (instructor only)
  Future<void> addSession(Session session) async {
    _sessions.add(session);
    await _saveToStorage();
    notifyListeners();

    // Sync to Google Sheets
    try {
      await SheetsService.addSession(session);
    } catch (e) {
      debugPrint('Error adding session to sheets: $e');
    }
  }

  // Update existing session (instructor only)
  Future<void> updateSession(Session session) async {
    final index = _sessions.indexWhere((s) => s.id == session.id);
    if (index != -1) {
      _sessions[index] = session;
      await _saveToStorage();
      notifyListeners();

      // Sync to Google Sheets
      try {
        await SheetsService.updateSession(session);
      } catch (e) {
        debugPrint('Error updating session in sheets: $e');
      }
    }
  }

  // Delete session (instructor only)
  Future<void> deleteSession(String sessionId) async {
    _sessions.removeWhere((s) => s.id == sessionId);
    await _saveToStorage();
    notifyListeners();
  }

  // Update badge progress
  void updateBadgeProgress(String badgeId, int progress,
      {bool unlock = false}) {
    final index = _badges.indexWhere((b) => b.id == badgeId);
    if (index != -1) {
      _badges[index] = _badges[index].copyWith(
        progress: progress,
        unlocked: unlock || progress >= 100,
      );
      _saveToStorage();
      notifyListeners();
    }
  }

  // Add points and update level
  void addPoints(int pointsToAdd) {
    _points += pointsToAdd;
    // Level up logic: every 500 points = 1 level
    final newLevel = (_points / 500).floor() + 1;
    if (newLevel > _level) {
      _level = newLevel;
    }
    _saveToStorage();
    notifyListeners();
  }

  // Update RDV progress
  void updateRdvProgress(int progress) {
    _rdvProgress = progress.clamp(0, 100);
    _saveToStorage();
    notifyListeners();
  }

  // Refresh promo progress (should be called daily)
  void refreshPromoProgress() {
    _promoProgress = _calculatePromoProgress();
    _saveToStorage();
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
