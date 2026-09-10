import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:project_tride/Database/expense_model.dart';

/// Service untuk mengelola fitur Pengeluaran / Anggaran (Budget/Expense) menggunakan Cloud Firestore.
/// Data disimpan secara terisolasi per user dan per trip di path:
/// `users/{uid}/trips/{tripId}/expenses/{expenseId}`
class BudgetService {
  final FirebaseAuth? _injectedAuth;
  final FirebaseFirestore? _injectedFirestore;

  BudgetService._internal({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _injectedAuth = auth,
        _injectedFirestore = firestore;

  static BudgetService instance = BudgetService._internal();

  /// Factory constructor untuk pengujian (dependency injection)
  factory BudgetService.custom({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) {
    return BudgetService._internal(auth: auth, firestore: firestore);
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

  /// Mendapatkan referensi subcollection `expenses` untuk UID dan TripId tertentu (User & Trip Isolation)
  CollectionReference<Map<String, dynamic>>? _getExpensesRef(String tripId, {String? uid}) {
    try {
      final targetUid = uid ?? currentUserId;
      if (targetUid == null || targetUid.trim().isEmpty || tripId.trim().isEmpty) {
        return null;
      }
      return _firestore
          .collection('users')
          .doc(targetUid.trim())
          .collection('trips')
          .doc(tripId.trim())
          .collection('expenses');
    } catch (_) {
      return null;
    }
  }

  /// Mendapatkan referensi dokumen `trip` untuk UID dan TripId tertentu
  DocumentReference<Map<String, dynamic>>? _getTripDocRef(String tripId, {String? uid}) {
    try {
      final targetUid = uid ?? currentUserId;
      if (targetUid == null || targetUid.trim().isEmpty || tripId.trim().isEmpty) {
        return null;
      }
      return _firestore
          .collection('users')
          .doc(targetUid.trim())
          .collection('trips')
          .doc(tripId.trim());
    } catch (_) {
      return null;
    }
  }

  // ==================================================
  // 1. CREATE EXPENSE
  // ==================================================

  /// Menambahkan expense baru ke Firestore pada `users/{uid}/trips/{tripId}/expenses/{expenseId}`
  Future<ExpenseModel?> addExpense(
    String tripId,
    ExpenseModel expense, {
    String? uid,
  }) async {
    try {
      final ref = _getExpensesRef(tripId, uid: uid);
      final targetUid = uid ?? currentUserId;

      if (ref == null || targetUid == null || targetUid.isEmpty) {
        debugPrint('[BudgetService] User belum login / UID atau Trip ID tidak valid. Gagal menambah expense.');
        return null;
      }

      final docRef = expense.id != null && expense.id!.isNotEmpty
          ? ref.doc(expense.id)
          : ref.doc();

      final assignedId = docRef.id;
      final expenseToSave = expense.copyWith(
        id: assignedId,
        tripId: tripId,
        createdAt: expense.createdAt.isNotEmpty
            ? expense.createdAt
            : DateTime.now().toIso8601String(),
        updatedAt: FieldValue.serverTimestamp(),
      );

      await docRef.set(expenseToSave.toFirestore());

      // Sinkronisasi spent_budget pada dokumen trip
      await syncTripSpentBudget(tripId, uid: targetUid);

      return expenseToSave;
    } on FirebaseException catch (e) {
      debugPrint('[BudgetService] Firebase error saat addExpense: ${e.message} (${e.code})');
      return null;
    } catch (e) {
      debugPrint('[BudgetService] Error tidak terduga saat addExpense: $e');
      return null;
    }
  }

  // ==================================================
  // 2. READ EXPENSES
  // ==================================================

  /// Mengambil semua expense untuk trip tertentu dari `users/{uid}/trips/{tripId}/expenses`
  Future<List<ExpenseModel>> getExpenses(String tripId, {String? uid}) async {
    try {
      final ref = _getExpensesRef(tripId, uid: uid);
      if (ref == null) return <ExpenseModel>[];

      final snapshot = await ref.orderBy('created_at', descending: true).get();
      return snapshot.docs.map((doc) => ExpenseModel.fromFirestore(doc)).toList();
    } on FirebaseException catch (e) {
      debugPrint('[BudgetService] Firebase error getExpenses: ${e.message}');
      try {
        final ref = _getExpensesRef(tripId, uid: uid);
        if (ref == null) return <ExpenseModel>[];
        final snapshot = await ref.get();
        final list = snapshot.docs.map((doc) => ExpenseModel.fromFirestore(doc)).toList();
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return list;
      } catch (_) {
        return <ExpenseModel>[];
      }
    } catch (e) {
      debugPrint('[BudgetService] Error tidak terduga saat getExpenses: $e');
      return <ExpenseModel>[];
    }
  }

  /// Stream real-time seluruh expense untuk trip tertentu
  Stream<List<ExpenseModel>> streamExpenses(String tripId, {String? uid}) {
    final ref = _getExpensesRef(tripId, uid: uid);
    if (ref == null) {
      return Stream.value(<ExpenseModel>[]);
    }

    return ref.snapshots().map((snapshot) {
      final list = snapshot.docs.map((doc) => ExpenseModel.fromFirestore(doc)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    }).handleError((error) {
      debugPrint('[BudgetService] Stream error on streamExpenses: $error');
      return <ExpenseModel>[];
    });
  }

  // ==================================================
  // 3. UPDATE EXPENSE
  // ==================================================

  /// Memperbarui expense pada `users/{uid}/trips/{tripId}/expenses/{expense.id}`
  Future<bool> updateExpense(
    String tripId,
    ExpenseModel expense, {
    String? uid,
  }) async {
    try {
      final ref = _getExpensesRef(tripId, uid: uid);
      if (ref == null || expense.id == null || expense.id!.isEmpty) {
        debugPrint('[BudgetService] UID/Trip ID/Expense ID tidak valid saat updateExpense.');
        return false;
      }

      final data = expense.toFirestore();
      data['updated_at'] = FieldValue.serverTimestamp();

      await ref.doc(expense.id).set(data, SetOptions(merge: true));

      // Sinkronisasi spent_budget pada dokumen trip
      final targetUid = uid ?? currentUserId;
      await syncTripSpentBudget(tripId, uid: targetUid);

      return true;
    } on FirebaseException catch (e) {
      debugPrint('[BudgetService] Firebase error saat updateExpense: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('[BudgetService] Error tidak terduga saat updateExpense: $e');
      return false;
    }
  }

  // ==================================================
  // 4. DELETE EXPENSE
  // ==================================================

  /// Menghapus expense dari Firestore `users/{uid}/trips/{tripId}/expenses/{expenseId}`
  Future<bool> deleteExpense(
    String tripId,
    String expenseId, {
    String? uid,
  }) async {
    try {
      final ref = _getExpensesRef(tripId, uid: uid);
      if (ref == null || expenseId.isEmpty) {
        debugPrint('[BudgetService] UID/Trip ID/Expense ID tidak valid saat deleteExpense.');
        return false;
      }

      await ref.doc(expenseId).delete();

      // Sinkronisasi spent_budget pada dokumen trip
      final targetUid = uid ?? currentUserId;
      await syncTripSpentBudget(tripId, uid: targetUid);

      return true;
    } on FirebaseException catch (e) {
      debugPrint('[BudgetService] Firebase error saat deleteExpense: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('[BudgetService] Error tidak terduga saat deleteExpense: $e');
      return false;
    }
  }

  // ==================================================
  // 5. CALCULATION & SYNC HELPERS
  // ==================================================

  /// Menghitung total pengeluaran dari list expenses
  double calculateTotalSpent(List<ExpenseModel> expenses) {
    return expenses.fold<double>(0.0, (total, item) => total + item.amount.toDouble());
  }

  /// Menghitung sisa anggaran berdasarkan Trip Budget dan Total Spent
  double calculateRemainingBudget(double tripBudget, double totalSpent) {
    return tripBudget - totalSpent;
  }

  /// Menghitung total pengeluaran per kategori
  Map<String, double> calculateCategorySpent(List<ExpenseModel> expenses) {
    final Map<String, double> map = {};
    for (final exp in expenses) {
      final cat = exp.category.trim();
      if (cat.isNotEmpty) {
        map[cat] = (map[cat] ?? 0.0) + exp.amount.toDouble();
      }
    }
    return map;
  }

  /// Menghitung persentase pengeluaran per kategori (0.0 - 100.0)
  Map<String, double> calculateCategoryPercentages(List<ExpenseModel> expenses) {
    final total = calculateTotalSpent(expenses);
    final categorySpent = calculateCategorySpent(expenses);
    final Map<String, double> percentages = {};

    if (total <= 0) {
      for (final key in categorySpent.keys) {
        percentages[key] = 0.0;
      }
      return percentages;
    }

    for (final entry in categorySpent.entries) {
      percentages[entry.key] = ((entry.value / total) * 100.0);
    }
    return percentages;
  }

  /// Menyinkronkan nilai `spent_budget` pada dokumen Trip di Firestore
  Future<void> syncTripSpentBudget(String tripId, {String? uid}) async {
    try {
      final tripDoc = _getTripDocRef(tripId, uid: uid);
      if (tripDoc == null) return;

      final expenses = await getExpenses(tripId, uid: uid);
      final totalSpent = calculateTotalSpent(expenses).toInt();

      await tripDoc.set({
        'spent_budget': totalSpent,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('[BudgetService] Warning saat sinkronisasi spent_budget trip: $e');
    }
  }
}
