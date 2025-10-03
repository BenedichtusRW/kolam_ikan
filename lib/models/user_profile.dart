class UserProfile {
  final String uid;
  final String email;
  final String name;
  final String role; // 'admin' or 'user'
  final String? pondId; // null for admin, specific pond ID for user

  UserProfile({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.pondId,
  });

  // Convert from Firestore document
  factory UserProfile.fromMap(Map<String, dynamic> map, String uid) {
    return UserProfile(
      uid: uid,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? 'user',
      pondId: map['pondId'],
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'role': role,
      'pondId': pondId,
    };
  }

  bool get isAdmin => role == 'admin';
}