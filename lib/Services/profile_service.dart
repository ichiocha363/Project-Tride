import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:project_tride/Models/user_profile_model.dart';

/// Service to manage User Profile operations with Cloud Firestore and Firebase Storage.
/// Data is isolated per user at path: `users/{uid}`
/// Profile images are isolated per user at: `profile_images/{uid}/profile.jpg`
class ProfileService {
  final FirebaseAuth? _injectedAuth;
  final FirebaseFirestore? _injectedFirestore;

  ProfileService._internal({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _injectedAuth = auth,
        _injectedFirestore = firestore;

  static ProfileService instance = ProfileService._internal();

  /// Factory constructor for Dependency Injection / Testing
  factory ProfileService.custom({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  }) {
    return ProfileService._internal(
      auth: auth,
      firestore: firestore,
    );
  }

  FirebaseAuth? get _auth {
    if (_injectedAuth != null) return _injectedAuth;
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  FirebaseFirestore? get _firestore {
    if (_injectedFirestore != null) return _injectedFirestore;
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  /// Current authenticated user's UID
  String? get currentUserId => _auth?.currentUser?.uid;

  /// Whether a user is currently authenticated
  bool get isAuthenticated => _auth?.currentUser != null;

  /// Document reference for `users/{uid}`
  DocumentReference<Map<String, dynamic>>? _getUserDocRef([String? uid]) {
    final targetUid = uid ?? currentUserId;
    if (targetUid == null || targetUid.trim().isEmpty || _firestore == null) {
      return null;
    }
    return _firestore!.collection('users').doc(targetUid.trim());
  }

  // ==================================================
  // READ PROFILE
  // ==================================================

  /// Retrieves user profile from `users/{uid}`.
  /// If the document does not exist yet, initializes it with defaults.
  Future<UserProfileModel> getUserProfile([String? uid]) async {
    final targetUid = uid ?? currentUserId;
    final currentUser = _auth?.currentUser;

    final fallbackEmail = currentUser?.email ?? '';
    final fallbackName = currentUser?.displayName ?? (fallbackEmail.isNotEmpty ? fallbackEmail.split('@').first : 'Pengguna Tride');
    final fallbackPhoto = currentUser?.photoURL;

    if (targetUid == null || targetUid.isEmpty) {
      return UserProfileModel.empty(
        uid: '',
        email: fallbackEmail,
        name: fallbackName,
        profileImage: fallbackPhoto,
      );
    }

    try {
      final docRef = _getUserDocRef(targetUid);
      if (docRef == null) {
        return UserProfileModel.empty(
          uid: targetUid,
          email: fallbackEmail,
          name: fallbackName,
          profileImage: fallbackPhoto,
        );
      }

      final doc = await docRef.get();
      if (doc.exists && doc.data() != null) {
        return UserProfileModel.fromFirestore(
          doc,
          fallbackEmail: fallbackEmail,
          fallbackName: fallbackName,
          fallbackPhoto: fallbackPhoto,
        );
      } else {
        // Document does not exist yet in Firestore — initialize it
        final defaultProfile = UserProfileModel(
          uid: targetUid,
          name: fallbackName,
          email: fallbackEmail,
          profileImage: fallbackPhoto,
          createdAt: DateTime.now().toIso8601String(),
        );

        try {
          await docRef.set(defaultProfile.toFirestore(), SetOptions(merge: true));
        } catch (_) {}

        return defaultProfile;
      }
    } on FirebaseException catch (e) {
      debugPrint('[ProfileService] Firebase error getUserProfile: ${e.message} (${e.code})');
      return UserProfileModel.empty(
        uid: targetUid,
        email: fallbackEmail,
        name: fallbackName,
        profileImage: fallbackPhoto,
      );
    } catch (e) {
      debugPrint('[ProfileService] Error getUserProfile: $e');
      return UserProfileModel.empty(
        uid: targetUid,
        email: fallbackEmail,
        name: fallbackName,
        profileImage: fallbackPhoto,
      );
    }
  }

  /// Real-time stream of user profile from `users/{uid}`
  Stream<UserProfileModel> streamUserProfile([String? uid]) {
    final targetUid = uid ?? currentUserId;
    final currentUser = _auth?.currentUser;
    final fallbackEmail = currentUser?.email ?? '';
    final fallbackName = currentUser?.displayName ?? (fallbackEmail.isNotEmpty ? fallbackEmail.split('@').first : 'Pengguna Tride');
    final fallbackPhoto = currentUser?.photoURL;

    final docRef = _getUserDocRef(targetUid);
    if (docRef == null) {
      return Stream.value(UserProfileModel.empty(
        uid: targetUid ?? '',
        email: fallbackEmail,
        name: fallbackName,
        profileImage: fallbackPhoto,
      ));
    }

    return docRef.snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return UserProfileModel.fromFirestore(
          snapshot,
          fallbackEmail: fallbackEmail,
          fallbackName: fallbackName,
          fallbackPhoto: fallbackPhoto,
        );
      }
      return UserProfileModel.empty(
        uid: targetUid ?? '',
        email: fallbackEmail,
        name: fallbackName,
        profileImage: fallbackPhoto,
      );
    }).handleError((error) {
      debugPrint('[ProfileService] Stream error on streamUserProfile: $error');
      return UserProfileModel.empty(
        uid: targetUid ?? '',
        email: fallbackEmail,
        name: fallbackName,
        profileImage: fallbackPhoto,
      );
    });
  }

  // ==================================================
  // UPDATE PERSONAL DETAILS
  // ==================================================

  /// Updates personal details (name, phone) on Firestore `users/{uid}`
  Future<bool> updatePersonalDetails({
    required String name,
    String? phone,
    String? uid,
  }) async {
    try {
      final docRef = _getUserDocRef(uid);
      if (docRef == null) {
        debugPrint('[ProfileService] UID tidak valid saat updatePersonalDetails.');
        return false;
      }

      final payload = <String, dynamic>{
        'name': name.trim(),
        if (phone != null) 'phone': phone.trim(),
        'updated_at': FieldValue.serverTimestamp(),
      };

      await docRef.set(payload, SetOptions(merge: true));

      // Also update Firebase Auth display name
      try {
        final authUser = _auth?.currentUser;
        if (authUser != null && (uid == null || uid == authUser.uid)) {
          await authUser.updateDisplayName(name.trim());
        }
      } catch (_) {}

      return true;
    } on FirebaseException catch (e) {
      debugPrint('[ProfileService] Firebase error updatePersonalDetails: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('[ProfileService] Error updatePersonalDetails: $e');
      return false;
    }
  }

  // ==================================================
  // UPDATE TRAVEL PREFERENCES
  // ==================================================

  /// Updates travel preferences (favorite destination, language, currency) on Firestore `users/{uid}`
  Future<bool> updateTravelPreferences({
    dynamic destinationId,
    String? destinationName,
    String? language,
    String? currency,
    String? uid,
  }) async {
    try {
      final docRef = _getUserDocRef(uid);
      if (docRef == null) {
        debugPrint('[ProfileService] UID tidak valid saat updateTravelPreferences.');
        return false;
      }

      final payload = <String, dynamic>{
        if (destinationId != null) 'favorite_destination_id': destinationId,
        if (destinationName != null) 'favorite_destination_name': destinationName,
        if (language != null) 'language': language,
        if (currency != null) 'currency': currency,
        'updated_at': FieldValue.serverTimestamp(),
      };

      await docRef.set(payload, SetOptions(merge: true));
      return true;
    } on FirebaseException catch (e) {
      debugPrint('[ProfileService] Firebase error updateTravelPreferences: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('[ProfileService] Error updateTravelPreferences: $e');
      return false;
    }
  }

  // ==================================================
  // UPDATE PROFILE IMAGE & FIREBASE STORAGE UPLOAD
  // ==================================================

  /// Uploads an image file to Firebase Storage under `profile_images/{uid}/profile.jpg`
  /// Saves profile image locally to App Documents Directory under `profile_images/{uid}_profile.jpg`
  /// and updates Firestore `users/{uid}.profile_image` with local file path.
  /// NO FIREBASE STORAGE IS USED.
  Future<String?> saveProfileImageLocally(File imageFile, {String? uid}) async {
    final targetUid = uid ?? currentUserId;
    if (targetUid == null || targetUid.isEmpty) {
      debugPrint('[ProfileService] User belum login / UID tidak valid saat saveProfileImageLocally.');
      return null;
    }

    try {
      if (!await imageFile.exists()) {
        debugPrint('[ProfileService] Source image file does not exist.');
        return null;
      }

      final appDocDir = await getApplicationDocumentsDirectory();
      final profileDir = Directory('${appDocDir.path}/profile_images');
      if (!await profileDir.exists()) {
        await profileDir.create(recursive: true);
      }

      final targetPath = '${profileDir.path}/${targetUid}_profile.jpg';
      final savedFile = await imageFile.copy(targetPath);

      final localPath = savedFile.path;

      // Update Firestore `users/{uid}.profile_image`
      await updateProfileImageUrl(localPath, uid: targetUid);

      return localPath;
    } catch (e) {
      debugPrint('[ProfileService] Error saveProfileImageLocally: $e');
      return null;
    }
  }

  /// Alias for backward compatibility — saves image locally without Firebase Storage.
  Future<String?> uploadProfileImage(File imageFile, {String? uid}) async {
    return saveProfileImageLocally(imageFile, uid: uid);
  }

  /// Updates profile image URL in Firestore `users/{uid}` directly
  Future<bool> updateProfileImageUrl(String imageUrl, {String? uid}) async {
    try {
      final docRef = _getUserDocRef(uid);
      if (docRef == null) return false;

      await docRef.set({
        'profile_image': imageUrl,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      debugPrint('[ProfileService] Error updateProfileImageUrl: $e');
      return false;
    }
  }

  // ==================================================
  // REAL STATS: TRIPS COUNT & SAVED PLACES COUNT
  // ==================================================

  /// Retrieves total count of trips for the user from `users/{uid}/trips`
  Future<int> getTripsCount([String? uid]) async {
    final targetUid = uid ?? currentUserId;
    if (targetUid == null || targetUid.isEmpty || _firestore == null) return 0;

    try {
      final snapshot = await _firestore!
          .collection('users')
          .doc(targetUid)
          .collection('trips')
          .get();
      return snapshot.docs.length;
    } catch (e) {
      debugPrint('[ProfileService] Error getTripsCount: $e');
      return 0;
    }
  }

  /// Stream of total trips count for the user
  Stream<int> streamTripsCount([String? uid]) {
    final targetUid = uid ?? currentUserId;
    if (targetUid == null || targetUid.isEmpty || _firestore == null) {
      return Stream.value(0);
    }

    return _firestore!
        .collection('users')
        .doc(targetUid)
        .collection('trips')
        .snapshots()
        .map((snapshot) => snapshot.docs.length)
        .handleError((_) => 0);
  }

  /// Retrieves total count of saved places for the user from `users/{uid}/saved_places`
  Future<int> getSavedPlacesCount([String? uid]) async {
    final targetUid = uid ?? currentUserId;
    if (targetUid == null || targetUid.isEmpty || _firestore == null) return 0;

    try {
      final snapshot = await _firestore!
          .collection('users')
          .doc(targetUid)
          .collection('saved_places')
          .get();
      return snapshot.docs.length;
    } catch (e) {
      debugPrint('[ProfileService] Error getSavedPlacesCount: $e');
      return 0;
    }
  }

  /// Stream of total saved places count for the user
  Stream<int> streamSavedPlacesCount([String? uid]) {
    final targetUid = uid ?? currentUserId;
    if (targetUid == null || targetUid.isEmpty || _firestore == null) {
      return Stream.value(0);
    }

    return _firestore!
        .collection('users')
        .doc(targetUid)
        .collection('saved_places')
        .snapshots()
        .map((snapshot) => snapshot.docs.length)
        .handleError((_) => 0);
  }
}
