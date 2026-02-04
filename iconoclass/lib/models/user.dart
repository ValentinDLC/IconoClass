// User data model representing authenticated users in the system
// Contains user profile information, authentication details, and role-based access control
// Supports JSON serialization for local storage and API communication

class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final UserRole role;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.role = UserRole.student,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Full name getter for display purposes
  String get fullName => '$firstName $lastName';

  // Initials getter for avatar display (e.g., "EK" for "Edson Kouebi")
  String get initials => '${firstName[0]}${lastName[0]}'.toUpperCase();

  // First letter of first name for simple avatar display
  String get firstLetter => firstName[0].toUpperCase();

  // Check if user has instructor privileges
  bool get isInstructor => role == UserRole.instructor;

  // Check if user has admin privileges
  bool get isAdmin => role == UserRole.admin;

  // Convert User object to JSON map for storage/API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'role': role.toString().split('.').last,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  // Create User object from JSON map
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      role: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == json['role'],
        orElse: () => UserRole.student,
      ),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  // Create a copy of User with updated fields
  User copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    UserRole? role,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name: $fullName, email: $email, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User &&
        other.id == id &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.email == email &&
        other.role == role;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        firstName.hashCode ^
        lastName.hashCode ^
        email.hashCode ^
        role.hashCode;
  }
}

// Enum representing different user roles in the system
enum UserRole {
  student, // Regular student user
  instructor, // Instructor with teaching privileges
  admin, // Administrator with full access
}

// Extension to get display names for user roles
extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.student:
        return 'Étudiant';
      case UserRole.instructor:
        return 'Intervenant';
      case UserRole.admin:
        return 'Administrateur';
    }
  }
}
