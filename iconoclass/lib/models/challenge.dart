// Challenge data model representing events, competitions, and special activities
// Contains challenge information including icon, title, description, and visual styling
// Used for displaying upcoming challenges and allowing users to participate

class Challenge {
  final String id;
  final String icon;
  final String title;
  final String description;
  final ChallengeColor color;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;
  final String? link;

  Challenge({
    required this.id,
    required this.icon,
    required this.title,
    required this.description,
    this.color = ChallengeColor.purple,
    this.startDate,
    this.endDate,
    this.isActive = true,
    this.link,
  });

  // Check if challenge is currently running
  bool get isRunning {
    if (!isActive) return false;
    final now = DateTime.now();
    if (startDate != null && now.isBefore(startDate!)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;
    return true;
  }

  // Check if challenge is upcoming (not started yet)
  bool get isUpcoming {
    if (startDate == null) return false;
    return DateTime.now().isBefore(startDate!);
  }

  // Check if challenge has ended
  bool get hasEnded {
    if (endDate == null) return false;
    return DateTime.now().isAfter(endDate!);
  }

  // Get formatted date range string
  String get dateRange {
    if (startDate == null && endDate == null) return '';
    if (startDate != null && endDate == null) {
      return 'À partir du ${_formatDate(startDate!)}';
    }
    if (startDate == null && endDate != null) {
      return 'Jusqu\'au ${_formatDate(endDate!)}';
    }
    return '${_formatDate(startDate!)} - ${_formatDate(endDate!)}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Convert Challenge object to JSON map for storage/API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'icon': icon,
      'title': title,
      'description': description,
      'color': color.toString().split('.').last,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isActive': isActive,
      'link': link,
    };
  }

  // Create Challenge object from JSON map
  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'] as String,
      icon: json['icon'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      color: ChallengeColor.values.firstWhere(
        (e) => e.toString().split('.').last == json['color'],
        orElse: () => ChallengeColor.purple,
      ),
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? true,
      link: json['link'] as String?,
    );
  }

  // Create a copy of Challenge with updated fields
  Challenge copyWith({
    String? id,
    String? icon,
    String? title,
    String? description,
    ChallengeColor? color,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    String? link,
  }) {
    return Challenge(
      id: id ?? this.id,
      icon: icon ?? this.icon,
      title: title ?? this.title,
      description: description ?? this.description,
      color: color ?? this.color,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      link: link ?? this.link,
    );
  }

  @override
  String toString() {
    return 'Challenge(id: $id, title: $title, isActive: $isActive, isRunning: $isRunning)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Challenge &&
        other.id == id &&
        other.icon == icon &&
        other.title == title &&
        other.description == description &&
        other.color == color;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        icon.hashCode ^
        title.hashCode ^
        description.hashCode ^
        color.hashCode;
  }
}

// Challenge color enum for UI styling
enum ChallengeColor {
  purple,
  blue,
  green,
  orange,
  red,
}

// Extension to get color values for challenge colors
extension ChallengeColorExtension on ChallengeColor {
  // Get primary color value
  int get primaryColor {
    switch (this) {
      case ChallengeColor.purple:
        return 0xFF9333EA; // Purple 600
      case ChallengeColor.blue:
        return 0xFF2563EB; // Blue 600
      case ChallengeColor.green:
        return 0xFF16A34A; // Green 600
      case ChallengeColor.orange:
        return 0xFFEA580C; // Orange 600
      case ChallengeColor.red:
        return 0xFFDC2626; // Red 600
    }
  }

  // Get light background color value
  int get lightColor {
    switch (this) {
      case ChallengeColor.purple:
        return 0xFFF3E8FF; // Purple 100
      case ChallengeColor.blue:
        return 0xFFDBEAFE; // Blue 100
      case ChallengeColor.green:
        return 0xFFDCFCE7; // Green 100
      case ChallengeColor.orange:
        return 0xFFFFEDD5; // Orange 100
      case ChallengeColor.red:
        return 0xFFFEE2E2; // Red 100
    }
  }
}

// Predefined default challenges
class DefaultChallenges {
  static List<Challenge> get defaultChallenges => [
        Challenge(
          id: 'icono_arena',
          icon: '🎮',
          title: 'IconoArena',
          description: 'Challenge vente',
          color: ChallengeColor.purple,
        ),
        Challenge(
          id: 'eloquence',
          icon: '🎤',
          title: 'Concours éloquence',
          description: 'Talents oratoires',
          color: ChallengeColor.blue,
        ),
        Challenge(
          id: 'alumni_breakfast',
          icon: '🍳',
          title: 'Alumni Breakfast',
          description: '28 Janvier',
          color: ChallengeColor.green,
          startDate: DateTime(2025, 1, 28),
        ),
      ];
}
