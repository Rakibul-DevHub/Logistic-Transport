enum DriverAssignmentStatus { assigned, pending }

class Driver {
  final String id;
  final String name;
  final String email;
  final String? profileImage;
  final String accountStatus; // "active" / "inactive" from the API
  final DateTime? createdAt;

  // Local-only UI state (not persisted by the backend yet)
  DriverAssignmentStatus assignmentStatus;

  Driver({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
    this.accountStatus = 'active',
    this.createdAt,
    this.assignmentStatus = DriverAssignmentStatus.pending,
  });

  /// Handles both the GET list response (full object) and the POST
  /// response (partial object — no profileImage/status/createdAt).
  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown Driver',
      email: json['email']?.toString() ?? '',
      profileImage: json['profileImage']?.toString(),
      accountStatus: json['status']?.toString() ?? 'active',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Driver copyWith({DriverAssignmentStatus? assignmentStatus}) {
    return Driver(
      id: id,
      name: name,
      email: email,
      profileImage: profileImage,
      accountStatus: accountStatus,
      createdAt: createdAt,
      assignmentStatus: assignmentStatus ?? this.assignmentStatus,
    );
  }
}