class UserModel {
  final int? id;
  final String name;
  final String email;
  final String password;
  final String? profileImage;
  final String createdAt;

  UserModel({
    this.id,
    String? name,
    String? nama,
    required this.email,
    required this.password,
    this.profileImage,
    String? createdAt,
  })  : name = name ?? nama ?? '',
        createdAt = createdAt ?? DateTime.now().toIso8601String();

  String get nama => name;

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'email': email,
      'password': password,
      'profile_image': profileImage,
      'created_at': createdAt,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      name: (map['name'] ?? map['nama']) as String? ?? '',
      email: map['email'] as String? ?? '',
      password: map['password'] as String? ?? '',
      profileImage: map['profile_image'] as String?,
      createdAt: map['created_at'] as String? ?? '',
    );
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? password,
    String? profileImage,
    String? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
