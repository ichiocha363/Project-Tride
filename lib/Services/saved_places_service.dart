import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:project_tride/Database/destination_model.dart';

/// Service untuk mengelola fitur Saved Places / Favorite menggunakan Firebase Cloud Firestore.
/// Data disimpan secara terisolasi per user di path: users/{uid}/saved_places/{destinationId}
class SavedPlacesService {
  SavedPlacesService._internal();
  static final SavedPlacesService instance = SavedPlacesService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Mengambil Firebase UID user yang sedang login
  String? get currentUserId => _auth.currentUser?.uid;

  /// Memeriksa apakah user sedang login di Firebase Auth
  bool get isAuthenticated => _auth.currentUser != null;

  /// Mendapatkan referensi subcollection `saved_places` untuk UID tertentu
  CollectionReference<Map<String, dynamic>>? _getSavedPlacesRef([String? uid]) {
    final targetUid = uid ?? currentUserId;
    if (targetUid == null || targetUid.isEmpty) {
      return null;
    }
    return _firestore.collection('users').doc(targetUid).collection('saved_places');
  }

  /// Menambahkan destinasi ke Saved Places milik user yang sedang login.
  /// Idempotent: menggunakan `SetOptions(merge: true)` untuk menghindari duplikasi.
  Future<bool> addFavorite(DestinationModel destination, {String? uid}) async {
    try {
      final ref = _getSavedPlacesRef(uid);
      if (ref == null) {
        debugPrint('[SavedPlacesService] User belum login. Gagal menyimpan favorite.');
        return false;
      }

      final destId = destination.id;
      final docId = destId != null ? destId.toString() : destination.name.replaceAll(' ', '_').toLowerCase();

      final data = <String, dynamic>{
        if (destId != null) 'id': destId,
        if (destId != null) 'destination_id': destId,
        'destinationId': docId,
        'name': destination.name,
        'location': destination.location,
        'description': destination.description,
        'image': destination.image,
        'category': destination.category,
        'rating': destination.rating,
        'estimated_budget': destination.estimatedBudget,
        if (destination.bestTime != null) 'best_time': destination.bestTime,
        if (destination.placeType != null) 'place_type': destination.placeType,
        if (destination.latitude != null) 'latitude': destination.latitude,
        if (destination.longitude != null) 'longitude': destination.longitude,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': FieldValue.serverTimestamp(),
      };

      await ref.doc(docId).set(data, SetOptions(merge: true));
      return true;
    } on FirebaseException catch (e) {
      debugPrint('[SavedPlacesService] Firebase error saat addFavorite: ${e.message} (${e.code})');
      return false;
    } catch (e) {
      debugPrint('[SavedPlacesService] Error tidak terduga saat addFavorite: $e');
      return false;
    }
  }

  /// Menghapus destinasi dari Saved Places milik user yang sedang login
  Future<bool> removeFavorite(int destinationId, {String? uid}) async {
    try {
      final ref = _getSavedPlacesRef(uid);
      if (ref == null) {
        debugPrint('[SavedPlacesService] User belum login. Gagal menghapus favorite.');
        return false;
      }

      await ref.doc(destinationId.toString()).delete();
      return true;
    } on FirebaseException catch (e) {
      debugPrint('[SavedPlacesService] Firebase error saat removeFavorite: ${e.message} (${e.code})');
      return false;
    } catch (e) {
      debugPrint('[SavedPlacesService] Error tidak terduga saat removeFavorite: $e');
      return false;
    }
  }

  /// Memeriksa apakah destinasi dengan id tertentu sudah difavoritkan oleh user yang sedang login
  Future<bool> isFavorite(int destinationId, {String? uid}) async {
    try {
      final ref = _getSavedPlacesRef(uid);
      if (ref == null) return false;

      final doc = await ref.doc(destinationId.toString()).get();
      return doc.exists;
    } on FirebaseException catch (e) {
      debugPrint('[SavedPlacesService] Firebase error saat isFavorite: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('[SavedPlacesService] Error tidak terduga saat isFavorite: $e');
      return false;
    }
  }

  /// Mengambil kumpulan ID destinasi yang difavoritkan user saat ini
  Future<Set<int>> getFavoriteIds({String? uid}) async {
    try {
      final ref = _getSavedPlacesRef(uid);
      if (ref == null) return {};

      final snapshot = await ref.get();
      final ids = <int>{};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final rawId = data['destination_id'] ?? data['id'] ?? int.tryParse(doc.id);
        if (rawId is int) {
          ids.add(rawId);
        } else if (rawId is num) {
          ids.add(rawId.toInt());
        }
      }

      return ids;
    } on FirebaseException catch (e) {
      debugPrint('[SavedPlacesService] Firebase error saat getFavoriteIds: ${e.message}');
      return {};
    } catch (e) {
      debugPrint('[SavedPlacesService] Error tidak terduga saat getFavoriteIds: $e');
      return {};
    }
  }

  /// Mengambil semua daftar Saved Places user yang sedang login dari Firestore
  Future<List<DestinationModel>> getSavedPlaces({String? uid}) async {
    try {
      final ref = _getSavedPlacesRef(uid);
      if (ref == null) return [];

      final snapshot = await ref.orderBy('created_at', descending: true).get();
      return snapshot.docs.map((doc) => _mapDocToDestination(doc)).toList();
    } on FirebaseException catch (e) {
      debugPrint('[SavedPlacesService] Firebase error saat getSavedPlaces: ${e.message}');
      // Fallback query tanpa orderBy jika index belum siap
      try {
        final ref = _getSavedPlacesRef(uid);
        if (ref == null) return [];
        final snapshot = await ref.get();
        return snapshot.docs.map((doc) => _mapDocToDestination(doc)).toList();
      } catch (_) {
        return [];
      }
    } catch (e) {
      debugPrint('[SavedPlacesService] Error tidak terduga saat getSavedPlaces: $e');
      return [];
    }
  }

  /// Stream real-time untuk daftar Saved Places user yang sedang login
  Stream<List<DestinationModel>> streamSavedPlaces({String? uid}) {
    final ref = _getSavedPlacesRef(uid);
    if (ref == null) {
      return Stream.value([]);
    }

    return ref.snapshots().map((snapshot) {
      final list = snapshot.docs.map((doc) => _mapDocToDestination(doc)).toList();
      return list;
    }).handleError((error) {
      debugPrint('[SavedPlacesService] Stream error on streamSavedPlaces: $error');
      return <DestinationModel>[];
    });
  }

  /// Stream real-time untuk Set ID destinasi yang difavoritkan
  Stream<Set<int>> streamFavoriteIds({String? uid}) {
    final ref = _getSavedPlacesRef(uid);
    if (ref == null) {
      return Stream.value(<int>{});
    }

    return ref.snapshots().map((snapshot) {
      final ids = <int>{};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final rawId = data['destination_id'] ?? data['id'] ?? int.tryParse(doc.id);
        if (rawId is int) {
          ids.add(rawId);
        } else if (rawId is num) {
          ids.add(rawId.toInt());
        }
      }
      return ids;
    }).handleError((error) {
      debugPrint('[SavedPlacesService] Stream error on streamFavoriteIds: $error');
      return <int>{};
    });
  }

  /// Mengonversi Dokumen Firestore menjadi objek DestinationModel
  DestinationModel _mapDocToDestination(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final docIdNum = int.tryParse(doc.id);

    final rawId = data['destination_id'] ?? data['id'] ?? docIdNum;
    final int? id = rawId is num ? rawId.toInt() : (rawId is String ? int.tryParse(rawId) : null);

    return DestinationModel(
      id: id,
      name: data['name'] as String? ?? '',
      location: data['location'] as String? ?? '',
      description: data['description'] as String? ?? '',
      image: data['image'] as String? ?? '',
      category: data['category'] as String? ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      estimatedBudget: (data['estimated_budget'] as num?)?.toInt() ?? 0,
      bestTime: data['best_time'] as String?,
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      placeType: data['place_type'] as String?,
    );
  }
}
