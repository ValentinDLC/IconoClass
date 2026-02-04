// Session data model representing training sessions and live classes
// Contains session details including time, title, instructor, and meeting links
// Supports both scheduled sessions and live sessions with real-time indicators

class Session {
  final String id;
  final String title;
  final String time;
  final String instructor;
  final String? zoomLink;
  final bool isLive;
  final DateTime? date;
  final String? description;

  Session({
    required this.id,
    required this.title,
    required this.time,
    required this.instructor,
    this.zoomLink,
    this.isLive = false,
    this.date,
    this.description,
  });

  // Check if session is happening today
  bool get isToday {
    if (date == null) return true; // Assume today if no date specified
    final now = DateTime.now();
    return date!.year == now.year &&
        date!.month == now.month &&
        date!.day == now.day;
  }

  // Get formatted date string
  String get formattedDate {
    if (date == null) return '';
    return '${date!.day}/${date!.month}/${date!.year}';
  }

  // Check if session has a Zoom link available
  bool get hasZoomLink => zoomLink != null && zoomLink!.isNotEmpty;

  // Convert Session object to JSON map for storage/API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'time': time,
      'instructor': instructor,
      'zoomLink': zoomLink,
      'isLive': isLive,
      'date': date?.toIso8601String(),
      'description': description,
    };
  }

  // Create Session object from JSON map
  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'] as String,
      title: json['title'] as String,
      time: json['time'] as String,
      instructor: json['instructor'] as String,
      zoomLink: json['zoomLink'] as String?,
      isLive: json['isLive'] as bool? ?? false,
      date:
          json['date'] != null ? DateTime.parse(json['date'] as String) : null,
      description: json['description'] as String?,
    );
  }

  // Create Session from Google Sheets row data
  // Expected format: [id, title, time, instructor, zoomLink, isLive, date, description]
  factory Session.fromSheetRow(List<dynamic> row) {
    return Session(
      id: row.isNotEmpty ? row[0].toString() : '',
      title: row.length > 1 ? row[1].toString() : '',
      time: row.length > 2 ? row[2].toString() : '',
      instructor: row.length > 3 ? row[3].toString() : '',
      zoomLink: row.length > 4 && row[4].toString().isNotEmpty
          ? row[4].toString()
          : null,
      isLive:
          row.length > 5 ? row[5].toString().toLowerCase() == 'true' : false,
      date: row.length > 6 && row[6].toString().isNotEmpty
          ? DateTime.tryParse(row[6].toString())
          : null,
      description: row.length > 7 && row[7].toString().isNotEmpty
          ? row[7].toString()
          : null,
    );
  }

  // Convert Session to Google Sheets row format
  List<dynamic> toSheetRow() {
    return [
      id,
      title,
      time,
      instructor,
      zoomLink ?? '',
      isLive.toString(),
      date?.toIso8601String() ?? '',
      description ?? '',
    ];
  }

  // Create a copy of Session with updated fields
  Session copyWith({
    String? id,
    String? title,
    String? time,
    String? instructor,
    String? zoomLink,
    bool? isLive,
    DateTime? date,
    String? description,
  }) {
    return Session(
      id: id ?? this.id,
      title: title ?? this.title,
      time: time ?? this.time,
      instructor: instructor ?? this.instructor,
      zoomLink: zoomLink ?? this.zoomLink,
      isLive: isLive ?? this.isLive,
      date: date ?? this.date,
      description: description ?? this.description,
    );
  }

  @override
  String toString() {
    return 'Session(id: $id, title: $title, time: $time, instructor: $instructor, isLive: $isLive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Session &&
        other.id == id &&
        other.title == title &&
        other.time == time &&
        other.instructor == instructor &&
        other.zoomLink == zoomLink &&
        other.isLive == isLive;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        time.hashCode ^
        instructor.hashCode ^
        zoomLink.hashCode ^
        isLive.hashCode;
  }
}
