// Instructor data model representing teachers and trainers in the system
// Contains instructor profile information, specialty areas, and contact details
// Used for displaying instructor cards and enabling student-instructor communication

class Instructor {
  final String id;
  final String name;
  final String role;
  final String specialty;
  final String? linkedinUrl;
  final String? email;
  final String? photoUrl;
  final String? bio;

  Instructor({
    required this.id,
    required this.name,
    required this.role,
    required this.specialty,
    this.linkedinUrl,
    this.email,
    this.photoUrl,
    this.bio,
  });

  // Get initials from instructor name (e.g., "JD" for "Jean Dupont")
  String get initials {
    final parts = name.split(' ');
    if (parts.isEmpty) return 'IN';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  // Check if instructor has LinkedIn profile
  bool get hasLinkedIn => linkedinUrl != null && linkedinUrl!.isNotEmpty;

  // Check if instructor has email
  bool get hasEmail => email != null && email!.isNotEmpty;

  // Check if instructor has profile photo
  bool get hasPhoto => photoUrl != null && photoUrl!.isNotEmpty;

  // Get specialty color based on specialty type
  SpecialtyColor get specialtyColor {
    switch (specialty.toUpperCase()) {
      case 'CLOSING':
        return SpecialtyColor.purple;
      case 'PSYCHO':
      case 'PSYCHOLOGY':
        return SpecialtyColor.blue;
      case 'B2B':
        return SpecialtyColor.green;
      case 'MARKETING':
        return SpecialtyColor.orange;
      default:
        return SpecialtyColor.gray;
    }
  }

  // Convert Instructor object to JSON map for storage/API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'specialty': specialty,
      'linkedinUrl': linkedinUrl,
      'email': email,
      'photoUrl': photoUrl,
      'bio': bio,
    };
  }

  // Create Instructor object from JSON map
  factory Instructor.fromJson(Map<String, dynamic> json) {
    return Instructor(
      id: json['id'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      specialty: json['specialty'] as String,
      linkedinUrl: json['linkedinUrl'] as String?,
      email: json['email'] as String?,
      photoUrl: json['photoUrl'] as String?,
      bio: json['bio'] as String?,
    );
  }

  // Create Instructor from Google Sheets row data
  // Expected format: [id, name, role, specialty, linkedinUrl, email, photoUrl, bio]
  factory Instructor.fromSheetRow(List<dynamic> row) {
    return Instructor(
      id: row.isNotEmpty ? row[0].toString() : '',
      name: row.length > 1 ? row[1].toString() : '',
      role: row.length > 2 ? row[2].toString() : '',
      specialty: row.length > 3 ? row[3].toString() : '',
      linkedinUrl: row.length > 4 && row[4].toString().isNotEmpty
          ? row[4].toString()
          : null,
      email: row.length > 5 && row[5].toString().isNotEmpty
          ? row[5].toString()
          : null,
      photoUrl: row.length > 6 && row[6].toString().isNotEmpty
          ? row[6].toString()
          : null,
      bio: row.length > 7 && row[7].toString().isNotEmpty
          ? row[7].toString()
          : null,
    );
  }

  // Convert Instructor to Google Sheets row format
  List<dynamic> toSheetRow() {
    return [
      id,
      name,
      role,
      specialty,
      linkedinUrl ?? '',
      email ?? '',
      photoUrl ?? '',
      bio ?? '',
    ];
  }

  // Create a copy of Instructor with updated fields
  Instructor copyWith({
    String? id,
    String? name,
    String? role,
    String? specialty,
    String? linkedinUrl,
    String? email,
    String? photoUrl,
    String? bio,
  }) {
    return Instructor(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      specialty: specialty ?? this.specialty,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
    );
  }

  @override
  String toString() {
    return 'Instructor(id: $id, name: $name, role: $role, specialty: $specialty)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Instructor &&
        other.id == id &&
        other.name == name &&
        other.role == role &&
        other.specialty == specialty;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ role.hashCode ^ specialty.hashCode;
  }
}

// Enum for specialty color coding in the UI
enum SpecialtyColor {
  purple,
  blue,
  green,
  orange,
  gray,
}
