import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:project_tride/Database/trip_model.dart';
import 'package:project_tride/Services/destination_service.dart';

/// Service untuk mengelola fitur Perjalanan (Trips) menggunakan Cloud Firestore.
/// Data disimpan secara terisolasi per user di path: users/{uid}/trips/{tripId}
class TripService {
  final FirebaseAuth? _injectedAuth;
  final FirebaseFirestore? _injectedFirestore;

  TripService._internal({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _injectedAuth = auth,
        _injectedFirestore = firestore;

  static TripService instance = TripService._internal();

  /// Factory constructor untuk pengujian (dependency injection)
  factory TripService.custom({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) {
    return TripService._internal(auth: auth, firestore: firestore);
  }

  FirebaseAuth get _auth => _injectedAuth ?? FirebaseAuth.instance;
  FirebaseFirestore get _firestore => _injectedFirestore ?? FirebaseFirestore.instance;

  /// Mengambil Firebase UID user yang sedang login saat ini
  String? get currentUserId {
    try {
      return _auth.currentUser?.uid;
    } catch (_) {
      return null;
    }
  }

  /// Memeriksa apakah user sedang terautentikasi
  bool get isAuthenticated {
    try {
      return _auth.currentUser != null;
    } catch (_) {
      return false;
    }
  }

  /// Mendapatkan referensi subcollection `trips` untuk UID tertentu (User Isolation)
  CollectionReference<Map<String, dynamic>>? _getTripsRef([String? uid]) {
    final targetUid = uid ?? currentUserId;
    if (targetUid == null || targetUid.trim().isEmpty) {
      return null;
    }
    return _firestore.collection('users').doc(targetUid.trim()).collection('trips');
  }

  // ==================================================
  // CREATE TRIP
  // ==================================================

  /// Membuat trip baru di Cloud Firestore di path `users/{uid}/trips/{tripId}`.
  /// Memvalidasi relasi destinasi jika `destinationId` disertakan.
  Future<TripModel?> createTrip(TripModel trip, {String? uid}) async {
    try {
      final ref = _getTripsRef(uid);
      final targetUid = uid ?? currentUserId;

      if (ref == null || targetUid == null || targetUid.isEmpty) {
        debugPrint('[TripService] User belum login / UID tidak valid. Gagal membuat trip.');
        return null;
      }

      // Validasi relasi destinasi (Destination Relation)
      String? destName = trip.destinationName;
      String? destLocation = trip.destinationLocation;
      String? destImage = trip.imageUrl;

      if (trip.destinationId != null) {
        try {
          final destination = await DestinationService.instance.getDestinationById(trip.destinationId);
          if (destination != null) {
            destName ??= destination.name;
            destLocation ??= destination.location;
            destImage ??= destination.image;
          }
        } catch (_) {
          // Tetap lanjutkan jika katalog destinasi offline
        }
      }

      final docRef = trip.id != null && trip.id!.isNotEmpty
          ? ref.doc(trip.id)
          : ref.doc();

      final assignedId = docRef.id;
      final tripToSave = trip.copyWith(
        id: assignedId,
        userId: targetUid,
        destinationName: destName,
        destinationLocation: destLocation,
        imageUrl: destImage,
        createdAt: trip.createdAt.isNotEmpty ? trip.createdAt : DateTime.now().toIso8601String(),
        updatedAt: FieldValue.serverTimestamp(),
      );

      await docRef.set(tripToSave.toFirestore());
      return tripToSave;
    } on FirebaseException catch (e) {
      debugPrint('[TripService] Firebase error saat createTrip: ${e.message} (${e.code})');
      return null;
    } catch (e) {
      debugPrint('[TripService] Error tidak terduga saat createTrip: $e');
      return null;
    }
  }

  // ==================================================
  // READ TRIPS
  // ==================================================

  /// Mengambil semua trip milik user dari Firestore (`users/{uid}/trips`)
  Future<List<TripModel>> getTrips({String? uid}) async {
    try {
      final ref = _getTripsRef(uid);
      if (ref == null) return <TripModel>[];

      final snapshot = await ref.orderBy('start_date', descending: false).get();
      return snapshot.docs.map((doc) => TripModel.fromFirestore(doc)).toList();
    } on FirebaseException catch (e) {
      debugPrint('[TripService] Firebase error getTrips: ${e.message}');
      try {
        final ref = _getTripsRef(uid);
        if (ref == null) return <TripModel>[];
        final snapshot = await ref.get();
        final list = snapshot.docs.map((doc) => TripModel.fromFirestore(doc)).toList();
        list.sort((a, b) => a.startDate.compareTo(b.startDate));
        return list;
      } catch (_) {
        return <TripModel>[];
      }
    } catch (e) {
      debugPrint('[TripService] Error tidak terduga saat getTrips: $e');
      return <TripModel>[];
    }
  }

  /// Mengambil satu trip berdasarkan ID dari `users/{uid}/trips/{tripId}`
  Future<TripModel?> getTripById(String tripId, {String? uid}) async {
    try {
      final ref = _getTripsRef(uid);
      if (ref == null || tripId.isEmpty) return null;

      final doc = await ref.doc(tripId).get();
      if (doc.exists && doc.data() != null) {
        return TripModel.fromFirestore(doc);
      }
    } catch (e) {
      debugPrint('[TripService] Error getTripById ($tripId): $e');
    }
    return null;
  }

  /// Mengambil trip terdekat yang akan datang (upcoming trip) untuk user
  Future<TripModel?> getUpcomingTrip({String? uid}) async {
    try {
      final trips = await getTrips(uid: uid);
      if (trips.isEmpty) return null;

      final now = DateTime.now();
      final todayStr = "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      // Cari trip dengan status 'upcoming' atau tanggal selesai >= hari ini
      for (final trip in trips) {
        if (trip.status == 'upcoming' || trip.endDate.compareTo(todayStr) >= 0) {
          return trip;
        }
      }

      return trips.first;
    } catch (e) {
      debugPrint('[TripService] Error getUpcomingTrip: $e');
      return null;
    }
  }

  /// Stream real-time seluruh trip milik user
  Stream<List<TripModel>> streamTrips({String? uid}) {
    final ref = _getTripsRef(uid);
    if (ref == null) {
      return Stream.value(<TripModel>[]);
    }

    return ref.snapshots().map((snapshot) {
      final list = snapshot.docs.map((doc) => TripModel.fromFirestore(doc)).toList();
      list.sort((a, b) => a.startDate.compareTo(b.startDate));
      return list;
    }).handleError((error) {
      debugPrint('[TripService] Stream error on streamTrips: $error');
      return <TripModel>[];
    });
  }

  /// Stream real-time untuk Upcoming Trip milik user
  Stream<TripModel?> streamUpcomingTrip({String? uid}) {
    return streamTrips(uid: uid).map((trips) {
      if (trips.isEmpty) return null;
      final now = DateTime.now();
      final todayStr = "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      for (final trip in trips) {
        if (trip.status == 'upcoming' || trip.endDate.compareTo(todayStr) >= 0) {
          return trip;
        }
      }
      return trips.first;
    });
  }

  // ==================================================
  // UPDATE TRIP
  // ==================================================

  /// Memperbarui trip yang sudah ada di `users/{uid}/trips/{tripId}`
  Future<bool> updateTrip(TripModel trip, {String? uid}) async {
    try {
      final ref = _getTripsRef(uid);
      if (ref == null || trip.id == null || trip.id!.isEmpty) {
        debugPrint('[TripService] User belum login / Trip ID kosong saat updateTrip.');
        return false;
      }

      final data = trip.toFirestore();
      data['updated_at'] = FieldValue.serverTimestamp();

      await ref.doc(trip.id).set(data, SetOptions(merge: true));
      return true;
    } on FirebaseException catch (e) {
      debugPrint('[TripService] Firebase error saat updateTrip: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('[TripService] Error tidak terduga saat updateTrip: $e');
      return false;
    }
  }

  // ==================================================
  // DELETE TRIP
  // ==================================================

  /// Menghapus trip dari Firestore `users/{uid}/trips/{tripId}`
  /// serta cascade delete subcollection `expenses` secara aman
  Future<bool> deleteTrip(String tripId, {String? uid, String? tripName}) async {
    try {
      final cleanTripId = tripId.trim();
      final authUid = currentUserId;

      debugPrint('''
=== DELETE TRIP TRACE ===
Auth UID: ${authUid ?? 'NULL / Unauthenticated'}
Passed UID: ${uid ?? 'N/A'}
Trip Model ID: $cleanTripId
Trip Model ID type: ${tripId.runtimeType}
Trip Name: ${tripName ?? 'N/A'}
''');

      if (cleanTripId.isEmpty) {
        debugPrint('[TripService] Trip ID kosong saat deleteTrip.');
        return false;
      }

      // Prioritaskan currentUserId (Firebase Auth UID)
      String? targetUid = authUid;

      // Jika currentUserId tidak ada (misal pada unit test mock), gunakan parameter uid jika valid (bukan ID integer lokal)
      if (targetUid == null || targetUid.trim().isEmpty) {
        if (uid != null && uid.trim().isNotEmpty && int.tryParse(uid.trim()) == null) {
          targetUid = uid.trim();
        }
      }

      if (targetUid == null || targetUid.trim().isEmpty) {
        debugPrint('[TripService] User belum login / target UID tidak valid saat deleteTrip.');
        return false;
      }

      final ref = _firestore.collection('users').doc(targetUid.trim()).collection('trips');
      final tripDocRef = ref.doc(cleanTripId);

      debugPrint('Firestore parent UID: $targetUid');
      debugPrint('document path = ${tripDocRef.path}');

      // 3. CEK DOCUMENT SEBELUM DELETE (CASE B Check)
      DocumentSnapshot<Map<String, dynamic>>? beforeSnap;
      try {
        beforeSnap = await tripDocRef.get();
      } catch (e) {
        debugPrint('[TripService] Catatan pre-delete check get(): $e');
      }

      final beforeExists = beforeSnap?.exists ?? false;
      debugPrint('beforeDelete.exists = $beforeExists');

      if (beforeSnap != null && !beforeExists) {
        debugPrint('STOP: Document does not exist at path ${tripDocRef.path}. Cannot delete non-existent document.');
        return false;
      }

      // 4. DELETE ACTUAL (Cascade delete subcollection expenses + parent document)
      final batch = _firestore.batch();

      try {
        final expensesSnap = await tripDocRef.collection('expenses').get();
        for (final doc in expensesSnap.docs) {
          batch.delete(doc.reference);
        }
      } catch (e) {
        debugPrint('[TripService] Catatan subcollection expenses: $e');
      }

      batch.delete(tripDocRef);
      await batch.commit();

      // Verify after delete (CASE E Check)
      DocumentSnapshot<Map<String, dynamic>>? afterSnap;
      try {
        afterSnap = await tripDocRef.get();
      } catch (e) {
        debugPrint('[TripService] Catatan post-delete check get(): $e');
      }

      final afterExists = afterSnap?.exists ?? false;
      debugPrint('afterDelete.exists = $afterExists');

      if (afterExists) {
        debugPrint('[TripService] FAIL: Document still exists at path ${tripDocRef.path} after delete batch commit.');
        return false;
      }

      debugPrint('[TripService] SUCCESS: Document ${tripDocRef.path} successfully deleted (before=$beforeExists, after=$afterExists).');
      return true;
    } on FirebaseException catch (e) {
      debugPrint('''
=== FIREBASE EXCEPTION CAPTURED ===
FirebaseException.code = ${e.code}
FirebaseException.message = ${e.message}
FirebaseException.plugin = ${e.plugin}
error.toString() = ${e.toString()}
''');
      if (e.code == 'no-app') return false;
      rethrow;
    } catch (e) {
      debugPrint('[TripService] Error tidak terduga saat deleteTrip: $e');
      return false;
    }
  }

  // ==================================================
  // ITINERARY CRUD
  // ==================================================

  /// Memperbarui list `itinerary_days` pada trip di Cloud Firestore (`users/{uid}/trips/{tripId}`).
  /// Menggunakan atomic merge update tanpa menyentuh field trip lainnya (budget, destination, dsb).
  Future<bool> updateItineraryDays(
    String tripId,
    List<Map<String, dynamic>> itineraryDays, {
    String? uid,
  }) async {
    try {
      final cleanTripId = tripId.trim();
      if (cleanTripId.isEmpty) {
        debugPrint('[TripService] Trip ID kosong saat updateItineraryDays.');
        return false;
      }

      final ref = _getTripsRef(uid);
      if (ref == null) {
        debugPrint('[TripService] User belum login / target UID tidak valid saat updateItineraryDays.');
        return false;
      }

      await ref.doc(cleanTripId).set({
        'itinerary_days': itineraryDays,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return true;
    } on FirebaseException catch (e) {
      debugPrint('[TripService] Firebase error saat updateItineraryDays: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('[TripService] Error tidak terduga saat updateItineraryDays: $e');
      return false;
    }
  }

  /// Menambahkan item aktivitas baru ke dalam itinerary trip di Firestore
  Future<bool> addItineraryItem(
    String tripId, {
    required int dayIndex,
    required Map<String, dynamic> activity,
    String? newDayTitle,
    String? uid,
  }) async {
    final trip = await getTripById(tripId, uid: uid);
    if (trip == null) return false;

    final List<Map<String, dynamic>> days = List<Map<String, dynamic>>.from(
      (trip.itineraryDays ?? []).map((e) => Map<String, dynamic>.from(e)),
    );

    if (dayIndex >= 0 && dayIndex < days.length) {
      final dayMap = Map<String, dynamic>.from(days[dayIndex]);
      final rawActs = dayMap['activities'] ?? dayMap['schedule'] ?? dayMap['items'];
      final List activitiesList = rawActs is List ? List.from(rawActs) : [];
      activitiesList.add(activity);
      dayMap['activities'] = activitiesList;
      days[dayIndex] = dayMap;
    } else {
      final dayNum = days.length + 1;
      final dayNumber = 'D ${dayNum.toString().padLeft(2, '0')}';
      final title = (newDayTitle != null && newDayTitle.trim().isNotEmpty)
          ? newDayTitle.trim()
          : 'Hari $dayNum';
      days.add({
        'day': title,
        'title': title,
        'dayNumber': dayNumber,
        'dayDate': title,
        'activities': [activity],
      });
    }

    return updateItineraryDays(tripId, days, uid: uid);
  }

  /// Memperbarui item aktivitas yang ada di itinerary trip di Firestore
  Future<bool> updateItineraryItem(
    String tripId, {
    required int dayIndex,
    required int activityIndex,
    required Map<String, dynamic> updatedActivity,
    String? uid,
  }) async {
    final trip = await getTripById(tripId, uid: uid);
    if (trip == null) return false;

    final List<Map<String, dynamic>> days = List<Map<String, dynamic>>.from(
      (trip.itineraryDays ?? []).map((e) => Map<String, dynamic>.from(e)),
    );

    if (dayIndex >= 0 && dayIndex < days.length) {
      final dayMap = Map<String, dynamic>.from(days[dayIndex]);
      final rawActs = dayMap['activities'] ?? dayMap['schedule'] ?? dayMap['items'];
      final List activitiesList = rawActs is List ? List.from(rawActs) : [];

      if (activityIndex >= 0 && activityIndex < activitiesList.length) {
        activitiesList[activityIndex] = updatedActivity;
        dayMap['activities'] = activitiesList;
        days[dayIndex] = dayMap;
        return updateItineraryDays(tripId, days, uid: uid);
      }
    }

    return false;
  }

  /// Menghapus item aktivitas tertentu dari itinerary trip di Firestore
  Future<bool> deleteItineraryItem(
    String tripId, {
    required int dayIndex,
    required int activityIndex,
    String? uid,
  }) async {
    final trip = await getTripById(tripId, uid: uid);
    if (trip == null) return false;

    final List<Map<String, dynamic>> days = List<Map<String, dynamic>>.from(
      (trip.itineraryDays ?? []).map((e) => Map<String, dynamic>.from(e)),
    );

    if (dayIndex >= 0 && dayIndex < days.length) {
      final dayMap = Map<String, dynamic>.from(days[dayIndex]);
      final rawActs = dayMap['activities'] ?? dayMap['schedule'] ?? dayMap['items'];
      final List activitiesList = rawActs is List ? List.from(rawActs) : [];

      if (activityIndex >= 0 && activityIndex < activitiesList.length) {
        activitiesList.removeAt(activityIndex);
        dayMap['activities'] = activitiesList;
        days[dayIndex] = dayMap;
        return updateItineraryDays(tripId, days, uid: uid);
      }
    }

    return false;
  }
}

