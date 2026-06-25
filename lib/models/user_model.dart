class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role;
  final String? tuitionId;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.tuitionId,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'tuitionId': tuitionId,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? '',
      tuitionId: map['tuitionId'],
    );
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? role,
    String? tuitionId,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      tuitionId: tuitionId ?? this.tuitionId,
    );
  }
}
