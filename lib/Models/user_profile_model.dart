import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing a user profile stored in Cloud Firestore under `users/{uid}`.
class UserProfileModel {
  final String uid;
  final String name;
  final String email;
  final String? phone;
  final String? profileImage;
  final dynamic favoriteDestinationId;
  final String? favoriteDestinationName;
  final String language;
  final String currency;
  final String createdAt;
  final dynamic updatedAt;

  UserProfileModel({
    required this.uid,
    required this.name,
    required this.email,
    this.phone,
    this.profileImage,
    this.favoriteDestinationId,
    this.favoriteDestinationName,
    this.language = 'Bahasa Indonesia',
    this.currency = 'IDR',
    String? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now().toIso8601String();

  /// Default fallback profile when no Firestore document exists yet
  factory UserProfileModel.empty({
    String uid = '',
    String email = '',
    String name = '',
    String? profileImage,
  }) {
    return UserProfileModel(
      uid: uid,
      name: name.isNotEmpty ? name : (email.isNotEmpty ? email.split('@').first : 'Pengguna Tride'),
      email: email,
      phone: null,
      profileImage: profileImage,
      favoriteDestinationId: null,
      favoriteDestinationName: null,
      language: 'Bahasa Indonesia',
      currency: 'IDR',
      createdAt: DateTime.now().toIso8601String(),
    );
  }

  /// Create model from Firestore DocumentSnapshot
  factory UserProfileModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    String? fallbackEmail,
    String? fallbackName,
    String? fallbackPhoto,
  }) {
    final data = doc.data() ?? {};
    final docUid = doc.id;

    final name = (data['name'] as String?)?.trim();
    final email = (data['email'] as String?)?.trim() ?? fallbackEmail ?? '';
    final resolvedName = (name != null && name.isNotEmpty)
        ? name
        : (fallbackName != null && fallbackName.isNotEmpty
            ? fallbackName
            : (email.isNotEmpty ? email.split('@').first : 'Pengguna Tride'));

    return UserProfileModel(
      uid: (data['uid'] as String?) ?? docUid,
      name: resolvedName,
      email: email,
      phone: data['phone'] as String?,
      profileImage: (data['profile_image'] as String?) ?? fallbackPhoto,
      favoriteDestinationId: data['favorite_destination_id'],
      favoriteDestinationName: data['favorite_destination_name'] as String?,
      language: (data['language'] as String?) ?? 'Bahasa Indonesia',
      currency: (data['currency'] as String?) ?? 'IDR',
      createdAt: (data['created_at'] as String?) ?? DateTime.now().toIso8601String(),
      updatedAt: data['updated_at'],
    );
  }

  /// Create model from general Map
  factory UserProfileModel.fromMap(
    Map<String, dynamic> data, {
    String uid = '',
    String? fallbackEmail,
    String? fallbackName,
    String? fallbackPhoto,
  }) {
    final name = (data['name'] as String?)?.trim();
    final email = (data['email'] as String?)?.trim() ?? fallbackEmail ?? '';
    final resolvedName = (name != null && name.isNotEmpty)
        ? name
        : (fallbackName != null && fallbackName.isNotEmpty
            ? fallbackName
            : (email.isNotEmpty ? email.split('@').first : 'Pengguna Tride'));

    return UserProfileModel(
      uid: (data['uid'] as String?) ?? uid,
      name: resolvedName,
      email: email,
      phone: data['phone'] as String?,
      profileImage: (data['profile_image'] as String?) ?? fallbackPhoto,
      favoriteDestinationId: data['favorite_destination_id'],
      favoriteDestinationName: data['favorite_destination_name'] as String?,
      language: (data['language'] as String?) ?? 'Bahasa Indonesia',
      currency: (data['currency'] as String?) ?? 'IDR',
      createdAt: (data['created_at'] as String?) ?? DateTime.now().toIso8601String(),
      updatedAt: data['updated_at'],
    );
  }

  /// Convert to Firestore payload
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name,
      'phone': phone,
      'profile_image': profileImage,
      'favorite_destination_id': favoriteDestinationId,
      'favorite_destination_name': favoriteDestinationName,
      'language': language,
      'currency': currency,
      'created_at': createdAt,
      'updated_at': FieldValue.serverTimestamp(),
    };
  }

  /// Convert to standard Map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'profile_image': profileImage,
      'favorite_destination_id': favoriteDestinationId,
      'favorite_destination_name': favoriteDestinationName,
      'language': language,
      'currency': currency,
      'created_at': createdAt,
      'updated_at': updatedAt?.toString(),
    };
  }

  /// Copy with updated fields
  UserProfileModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? phone,
    String? profileImage,
    dynamic favoriteDestinationId,
    String? favoriteDestinationName,
    String? language,
    String? currency,
    String? createdAt,
    dynamic updatedAt,
  }) {
    return UserProfileModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      favoriteDestinationId: favoriteDestinationId ?? this.favoriteDestinationId,
      favoriteDestinationName: favoriteDestinationName ?? this.favoriteDestinationName,
      language: language ?? this.language,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
