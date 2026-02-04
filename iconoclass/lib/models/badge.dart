// Badge data model representing user achievements and milestones
// Contains badge information including icon, name, unlock status, and progress tracking
// Used for gamification features to encourage user engagement and activity

class Badge {
  final String id;
  final String icon;
  final String name;
  final bool unlocked;
  final int progress;
  final String? description;
  final BadgeCategory category;

  Badge({
    required this.id,
    required this.icon,
    required this.name,
    required this.unlocked,
    this.progress = 0,
    this.description,
    this.category = BadgeCategory.general,
  });

  // Check if badge is in progress (not locked, not fully unlocked)
  bool get isInProgress => !unlocked && progress > 0;

  // Check if badge is locked (no progress yet)
  bool get isLocked => !unlocked && progress == 0;

  // Get progress percentage (0-100)
  int get progressPercentage => progress.clamp(0, 100);

  // Convert Badge object to JSON map for storage/API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'icon': icon,
      'name': name,
      'unlocked': unlocked,
      'progress': progress,
      'description': description,
      'category': category.toString().split('.').last,
    };
  }

  // Create Badge object from JSON map
  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      id: json['id'] as String,
      icon: json['icon'] as String,
      name: json['name'] as String,
      unlocked: json['unlocked'] as bool,
      progress: json['progress'] as int? ?? 0,
      description: json['description'] as String?,
      category: BadgeCategory.values.firstWhere(
        (e) => e.toString().split('.').last == json['category'],
        orElse: () => BadgeCategory.general,
      ),
    );
  }

  // Create a copy of Badge with updated fields
  Badge copyWith({
    String? id,
    String? icon,
    String? name,
    bool? unlocked,
    int? progress,
    String? description,
    BadgeCategory? category,
  }) {
    return Badge(
      id: id ?? this.id,
      icon: icon ?? this.icon,
      name: name ?? this.name,
      unlocked: unlocked ?? this.unlocked,
      progress: progress ?? this.progress,
      description: description ?? this.description,
      category: category ?? this.category,
    );
  }

  @override
  String toString() {
    return 'Badge(id: $id, name: $name, unlocked: $unlocked, progress: $progress%)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Badge &&
        other.id == id &&
        other.icon == icon &&
        other.name == name &&
        other.unlocked == unlocked &&
        other.progress == progress;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        icon.hashCode ^
        name.hashCode ^
        unlocked.hashCode ^
        progress.hashCode;
  }
}

// Badge category enum for organizing badges by type
enum BadgeCategory {
  calls, // Call-related achievements (e.g., "+5 appels", "+10 appels")
  streak, // Streak-related achievements (e.g., "Série 7j", "Série 30j")
  performance, // Performance-related achievements (e.g., "Top 10%")
  general, // General achievements
}

// Extension to get display names and colors for badge categories
extension BadgeCategoryExtension on BadgeCategory {
  String get displayName {
    switch (this) {
      case BadgeCategory.calls:
        return 'Appels';
      case BadgeCategory.streak:
        return 'Séries';
      case BadgeCategory.performance:
        return 'Performance';
      case BadgeCategory.general:
        return 'Général';
    }
  }

  // Get category color for UI display
  int get colorValue {
    switch (this) {
      case BadgeCategory.calls:
        return 0xFF10B981; // Green
      case BadgeCategory.streak:
        return 0xFFEF4444; // Red
      case BadgeCategory.performance:
        return 0xFF8B5CF6; // Purple
      case BadgeCategory.general:
        return 0xFF6B7280; // Gray
    }
  }
}

// Predefined default badges for new users
class DefaultBadges {
  static List<Badge> get defaultBadges => [
        Badge(
          id: 'calls_5',
          icon: '📞',
          name: '+5 appels',
          unlocked: true,
          progress: 100,
          description: 'Effectuez 5 appels',
          category: BadgeCategory.calls,
        ),
        Badge(
          id: 'calls_10',
          icon: '📱',
          name: '+10 appels',
          unlocked: true,
          progress: 100,
          description: 'Effectuez 10 appels',
          category: BadgeCategory.calls,
        ),
        Badge(
          id: 'calls_20',
          icon: '🎯',
          name: '+20 appels',
          unlocked: false,
          progress: 65,
          description: 'Effectuez 20 appels',
          category: BadgeCategory.calls,
        ),
        Badge(
          id: 'streak_7',
          icon: '🔥',
          name: 'Série 7j',
          unlocked: true,
          progress: 100,
          description: 'Maintenez une série de 7 jours',
          category: BadgeCategory.streak,
        ),
        Badge(
          id: 'streak_30',
          icon: '⚡',
          name: 'Série 30j',
          unlocked: false,
          progress: 40,
          description: 'Maintenez une série de 30 jours',
          category: BadgeCategory.streak,
        ),
        Badge(
          id: 'top_10',
          icon: '⭐',
          name: 'Top 10%',
          unlocked: true,
          progress: 100,
          description: 'Rejoignez le top 10% des étudiants',
          category: BadgeCategory.performance,
        ),
      ];
}
