import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:project_tride/Database/accommodation_model.dart';
import 'package:project_tride/Database/attraction_model.dart';
import 'package:project_tride/Database/destination_model.dart';
import 'package:project_tride/Database/local_food_model.dart';

/// Service untuk membaca katalog Destinasi Wisata Indonesia dan subkoleksi
/// (attractions, accommodations, local_foods) dari Cloud Firestore (Source of Truth).
class DestinationService {
  DestinationService._internal();
  static final DestinationService instance = DestinationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _destinationsRef =>
      _firestore.collection('destinations');

  /// Mengambil semua destinasi dari Cloud Firestore (diurutkan berdasarkan id).
  /// Mengembalikan list kosong `[]` jika offline/gagal koneksi.
  Future<List<DestinationModel>> getDestinations() async {
    try {
      final snapshot = await _destinationsRef.orderBy('id').get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs
            .map((doc) => DestinationModel.fromFirestore(doc))
            .toList();
      }
    } on FirebaseException catch (e) {
      debugPrint('[DestinationService] Firebase error getDestinations: ${e.message}');
      // Fallback coba query tanpa orderBy jika index belum siap
      try {
        final snapshot = await _destinationsRef.get();
        if (snapshot.docs.isNotEmpty) {
          final list = snapshot.docs
              .map((doc) => DestinationModel.fromFirestore(doc))
              .toList();
          list.sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0));
          return list;
        }
      } catch (_) {}
    } catch (e) {
      debugPrint('[DestinationService] Error getDestinations: $e');
    }

    return <DestinationModel>[];
  }

  /// Mengambil destinasi berdasarkan filter place_type (e.g. Pantai, Pegunungan, Perkotaan, Pedesaan, Alam)
  Future<List<DestinationModel>> getDestinationsByPlaceType(String placeType) async {
    if (placeType.isEmpty || placeType.toLowerCase() == 'semua' || placeType.toLowerCase() == 'all') {
      return getDestinations();
    }

    try {
      final snapshot = await _destinationsRef
          .where('place_type', isEqualTo: placeType)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final list = snapshot.docs
            .map((doc) => DestinationModel.fromFirestore(doc))
            .toList();
        list.sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0));
        return list;
      }
    } catch (e) {
      debugPrint('[DestinationService] Error getDestinationsByPlaceType ($placeType): $e');
    }

    return <DestinationModel>[];
  }

  /// Mengambil destinasi populer berating tinggi dari Firestore
  Future<List<DestinationModel>> getPopularDestinations({int limit = 6}) async {
    try {
      final snapshot = await _destinationsRef
          .orderBy('rating', descending: true)
          .limit(limit)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs
            .map((doc) => DestinationModel.fromFirestore(doc))
            .toList();
      }
    } catch (e) {
      debugPrint('[DestinationService] Error getPopularDestinations query: $e');
      try {
        final all = await getDestinations();
        all.sort((a, b) => b.rating.compareTo(a.rating));
        return all.take(limit).toList();
      } catch (_) {}
    }

    return <DestinationModel>[];
  }

  /// Mengambil satu destinasi berdasarkan ID dari Firestore
  Future<DestinationModel?> getDestinationById(dynamic id) async {
    if (id == null) return null;
    try {
      final doc = await _destinationsRef.doc(id.toString()).get();
      if (doc.exists) {
        return DestinationModel.fromFirestore(doc);
      }
    } catch (e) {
      debugPrint('[DestinationService] Error getDestinationById ($id): $e');
    }

    return null;
  }

  /// Mengambil daftar Hal Menarik (Attractions) dari subkoleksi `destinations/{id}/attractions`
  Future<List<AttractionModel>> getAttractions(dynamic destinationId) async {
    if (destinationId == null) return <AttractionModel>[];
    try {
      final subRef = _destinationsRef
          .doc(destinationId.toString())
          .collection('attractions');

      final snapshot = await subRef.get();
      if (snapshot.docs.isNotEmpty) {
        final list = snapshot.docs
            .map((doc) => AttractionModel.fromFirestore(doc))
            .toList();
        return list;
      }
    } catch (e) {
      debugPrint('[DestinationService] Error getAttractions ($destinationId): $e');
    }

    return <AttractionModel>[];
  }

  /// Mengambil daftar Tempat Menginap (Accommodations) dari subkoleksi `destinations/{id}/accommodations`
  Future<List<AccommodationModel>> getAccommodations(dynamic destinationId) async {
    if (destinationId == null) return <AccommodationModel>[];
    try {
      final subRef = _destinationsRef
          .doc(destinationId.toString())
          .collection('accommodations');

      final snapshot = await subRef.get();
      if (snapshot.docs.isNotEmpty) {
        final list = snapshot.docs
            .map((doc) => AccommodationModel.fromFirestore(doc))
            .toList();
        return list;
      }
    } catch (e) {
      debugPrint('[DestinationService] Error getAccommodations ($destinationId): $e');
    }

    return <AccommodationModel>[];
  }

  /// Mengambil daftar Kuliner Lokal (Local Foods) dari subkoleksi `destinations/{id}/local_foods`
  Future<List<LocalFoodModel>> getLocalFoods(dynamic destinationId) async {
    if (destinationId == null) return <LocalFoodModel>[];
    try {
      final subRef = _destinationsRef
          .doc(destinationId.toString())
          .collection('local_foods');

      final snapshot = await subRef.get();
      if (snapshot.docs.isNotEmpty) {
        final list = snapshot.docs
            .map((doc) => LocalFoodModel.fromFirestore(doc))
            .toList();
        return list;
      }
    } catch (e) {
      debugPrint('[DestinationService] Error getLocalFoods ($destinationId): $e');
    }

    return <LocalFoodModel>[];
  }

  /// Stream real-time seluruh destinasi dari Firestore
  Stream<List<DestinationModel>> streamDestinations() {
    return _destinationsRef.snapshots().map((snapshot) {
      final list = snapshot.docs
          .map((doc) => DestinationModel.fromFirestore(doc))
          .toList();
      list.sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0));
      return list;
    }).handleError((error) {
      debugPrint('[DestinationService] Stream error: $error');
      return <DestinationModel>[];
    });
  }
}
