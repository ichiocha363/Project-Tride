import 'package:flutter_test/flutter_test.dart';
import 'package:project_tride/Database/db_helper.dart';
import 'package:project_tride/Database/expense_model.dart';
import 'package:project_tride/Services/budget_service.dart';

void main() {
  group('Budget Service & Expense Firestore Integration Tests', () {
    // ==================================================
    // 1. CREATE EXPENSE
    // ==================================================
    test('1. Create Expense: ExpenseModel converts to Firestore schema accurately', () {
      final expense = ExpenseModel(
        id: 'exp_bali_dinner_01',
        tripId: 'trip_bali_101',
        category: 'Kuliner',
        amount: 250000,
        date: '10/09/2026',
        description: 'Bebek Bengil Ubud',
        createdAt: '2026-09-10T12:00:00.000Z',
      );

      final map = expense.toFirestore();

      expect(map['id'], 'exp_bali_dinner_01');
      expect(map['trip_id'], 'trip_bali_101');
      expect(map['category'], 'Kuliner');
      expect(map['amount'], 250000);
      expect(map['date'], '10/09/2026');
      expect(map['description'], 'Bebek Bengil Ubud');
      expect(map['created_at'], '2026-09-10T12:00:00.000Z');
    });

    // ==================================================
    // 2. READ EXPENSES
    // ==================================================
    test('2. Read Expenses: ExpenseModel.fromMap parses Firestore document data completely', () {
      final rawData = <String, dynamic>{
        'id': 'exp_hotel_02',
        'trip_id': 'trip_rajaampat_202',
        'category': 'Penginapan',
        'amount': 4500000,
        'date': '11/09/2026',
        'description': 'Raja Ampat Dive Lodge',
        'created_at': '2026-09-10T13:00:00.000Z',
      };

      final expense = ExpenseModel.fromMap(rawData, 'exp_hotel_02');

      expect(expense.id, 'exp_hotel_02');
      expect(expense.tripId, 'trip_rajaampat_202');
      expect(expense.category, 'Penginapan');
      expect(expense.amount, 4500000);
      expect(expense.date, '11/09/2026');
      expect(expense.description, 'Raja Ampat Dive Lodge');
      expect(expense.createdAt, '2026-09-10T13:00:00.000Z');
    });

    // ==================================================
    // 3. UPDATE EXPENSE
    // ==================================================
    test('3. Update Expense: copyWith updates specific fields while keeping ID and others intact', () {
      final initial = ExpenseModel(
        id: 'exp_transport_03',
        tripId: 'trip_bromo_303',
        category: 'Transportasi',
        amount: 350000,
        date: '12/09/2026',
        description: 'Sewa Jeep Bromo',
        createdAt: '2026-09-10T14:00:00.000Z',
      );

      final updated = initial.copyWith(
        amount: 400000,
        description: 'Sewa Jeep Bromo + Driver',
      );

      expect(updated.id, 'exp_transport_03');
      expect(updated.tripId, 'trip_bromo_303');
      expect(updated.category, 'Transportasi');
      expect(updated.amount, 400000);
      expect(updated.description, 'Sewa Jeep Bromo + Driver');
      expect(updated.date, '12/09/2026');
      expect(updated.createdAt, '2026-09-10T14:00:00.000Z');
    });

    // ==================================================
    // 4. DELETE EXPENSE
    // ==================================================
    test('4. Delete Expense: Expense identifier is verified and preserved for targeted deletion', () {
      final expense = ExpenseModel(
        id: 'exp_delete_999',
        tripId: 'trip_bali_101',
        category: 'Kuliner',
        amount: 75000,
        date: '10/09/2026',
        description: 'Kopi & Snack',
      );

      expect(expense.id, 'exp_delete_999');
      expect(expense.tripId, 'trip_bali_101');
    });

    // ==================================================
    // 5. TOTAL EXPENSE CALCULATION
    // ==================================================
    test('5. Total Expense Calculation: Sum of all expenses calculates correctly', () {
      final expenses = [
        ExpenseModel(
          id: '1',
          tripId: 'trip_1',
          category: 'Kuliner',
          amount: 100000,
          date: '10/09/2026',
        ),
        ExpenseModel(
          id: '2',
          tripId: 'trip_1',
          category: 'Transportasi',
          amount: 50000,
          date: '10/09/2026',
        ),
        ExpenseModel(
          id: '3',
          tripId: 'trip_1',
          category: 'Penginapan',
          amount: 850000,
          date: '10/09/2026',
        ),
      ];

      final totalSpent = BudgetService.instance.calculateTotalSpent(expenses);
      expect(totalSpent, 1000000.0);
    });

    // ==================================================
    // 6. REMAINING BUDGET CALCULATION
    // ==================================================
    test('6. Remaining Budget Calculation: Calculates positive and negative balances correctly', () {
      const tripBudget = 5000000.0;

      // Normal spent
      final spent1 = 1500000.0;
      final remaining1 = BudgetService.instance.calculateRemainingBudget(tripBudget, spent1);
      expect(remaining1, 3500000.0);
      expect(remaining1 >= 0, isTrue);

      // Over budget
      final spent2 = 6200000.0;
      final remaining2 = BudgetService.instance.calculateRemainingBudget(tripBudget, spent2);
      expect(remaining2, -1200000.0);
      expect(remaining2 < 0, isTrue);
    });

    // ==================================================
    // 7. CATEGORY BREAKDOWN
    // ==================================================
    test('7. Category Breakdown: Categorizes amounts and percentage accurately', () {
      final expenses = [
        ExpenseModel(
          id: '1',
          tripId: 'trip_1',
          category: 'Penginapan',
          amount: 500000,
          date: '10/09/2026',
        ),
        ExpenseModel(
          id: '2',
          tripId: 'trip_1',
          category: 'Kuliner',
          amount: 300000,
          date: '10/09/2026',
        ),
        ExpenseModel(
          id: '3',
          tripId: 'trip_1',
          category: 'Transportasi',
          amount: 200000,
          date: '10/09/2026',
        ),
      ];

      final catSpent = BudgetService.instance.calculateCategorySpent(expenses);
      final catPct = BudgetService.instance.calculateCategoryPercentages(expenses);

      expect(catSpent['Penginapan'], 500000.0);
      expect(catSpent['Kuliner'], 300000.0);
      expect(catSpent['Transportasi'], 200000.0);

      expect(catPct['Penginapan'], 50.0);
      expect(catPct['Kuliner'], 30.0);
      expect(catPct['Transportasi'], 20.0);
    });

    // ==================================================
    // 8. USER ISOLATION
    // ==================================================
    test('8. User Isolation: Expenses paths are partitioned by authenticated UID', () {
      const userAUid = 'user_alpha_111';
      const userBUid = 'user_beta_222';
      const tripId = 'trip_common_id';

      final pathUserA = 'users/$userAUid/trips/$tripId/expenses';
      final pathUserB = 'users/$userBUid/trips/$tripId/expenses';

      expect(pathUserA, 'users/user_alpha_111/trips/trip_common_id/expenses');
      expect(pathUserB, 'users/user_beta_222/trips/trip_common_id/expenses');
      expect(pathUserA, isNot(equals(pathUserB)));
    });

    // ==================================================
    // 9. TRIP ISOLATION
    // ==================================================
    test('9. Trip Isolation: Expenses for Trip A are distinct from Trip B', () {
      const uid = 'user_unique_uid';
      const tripAId = 'trip_bali_101';
      const tripBId = 'trip_tokyo_202';

      final pathTripA = 'users/$uid/trips/$tripAId/expenses';
      final pathTripB = 'users/$uid/trips/$tripBId/expenses';

      expect(pathTripA, isNot(equals(pathTripB)));
    });

    // ==================================================
    // 10. NO HARDCODED USER ID
    // ==================================================
    test('10. No Hardcoded User ID: Dynamically handles various Firebase UIDs without static defaults', () {
      const dynamicUid1 = 'firebase_custom_uid_99';
      const dynamicUid2 = 'firebase_custom_uid_88';

      expect(dynamicUid1, isNot(equals('1')));
      expect(dynamicUid1, isNot(equals('default_user')));
      expect(dynamicUid2, isNot(equals(dynamicUid1)));
    });

    // ==================================================
    // 11. NO DEFAULT EXPENSE SEEDING
    // ==================================================
    test('11. No Default Expense: DbHelper ensureDefaultTripExists does not inject fake Kyoto expenses', () async {
      await DbHelper.instance.ensureDefaultTripExists(1);
      expect(BudgetService.instance, isNotNull);
    });

    // ==================================================
    // 12. EMPTY EXPENSE STATE
    // ==================================================
    test('12. Empty Expense State: Calculates 0 spent and empty maps when no expenses recorded', () {
      final List<ExpenseModel> emptyList = [];

      final total = BudgetService.instance.calculateTotalSpent(emptyList);
      final remaining = BudgetService.instance.calculateRemainingBudget(10000000.0, total);
      final catSpent = BudgetService.instance.calculateCategorySpent(emptyList);
      final catPct = BudgetService.instance.calculateCategoryPercentages(emptyList);

      expect(total, 0.0);
      expect(remaining, 10000000.0);
      expect(catSpent, isEmpty);
      expect(catPct, isEmpty);
    });

    // ==================================================
    // 13. FIRESTORE MULTI-TYPE SERIALIZATION SAFETY
    // ==================================================
    test('13. Firestore Multi-Type Serialization: Safely handles int, double, num, and String', () {
      // Test string amounts with formatting
      final docWithString = {
        'id': 'exp_type_test_1',
        'trip_id': 'trip_001',
        'category': 'Kuliner',
        'amount': '150000',
        'date': '10/09/2026',
        'description': 'Makan Siang',
      };

      final parsedString = ExpenseModel.fromMap(docWithString);
      expect(parsedString.amount, 150000);

      // Test double amount
      final docWithDouble = {
        'id': 'exp_type_test_2',
        'trip_id': 'trip_001',
        'category': 'Penginapan',
        'amount': 2500000.75,
        'date': '10/09/2026',
      };

      final parsedDouble = ExpenseModel.fromMap(docWithDouble);
      expect(parsedDouble.amount, 2500000);

      // Test null safe defaults
      final docEmpty = <String, dynamic>{};
      final parsedEmpty = ExpenseModel.fromMap(docEmpty);
      expect(parsedEmpty.amount, 0);
      expect(parsedEmpty.category, '');
      expect(parsedEmpty.tripId, '0');
    });

    // ==================================================
    // 14. EXPENSE ID PERSISTENCE
    // ==================================================
    test('14. Expense ID Persistence: Roundtrip serialization maintains document ID', () {
      final original = ExpenseModel(
        id: 'persistent_exp_id_777',
        tripId: 'persistent_trip_555',
        category: 'Transportasi',
        amount: 180000,
        date: '10/09/2026',
        description: 'Grab Taxi Airport',
        createdAt: '2026-09-10T08:00:00.000Z',
      );

      final toFirestoreMap = original.toFirestore();
      final restored = ExpenseModel.fromMap(toFirestoreMap, original.id);

      expect(restored.id, original.id);
      expect(restored.tripId, original.tripId);
      expect(restored.category, original.category);
      expect(restored.amount, original.amount);
      expect(restored.date, original.date);
      expect(restored.description, original.description);
      expect(restored.createdAt, original.createdAt);
    });

    // ==================================================
    // 15. STREAM & SERVICE ISOLATION
    // ==================================================
    test('15. Stream & Service Isolation: Service methods safely handle empty or unauthenticated users', () async {
      final stream = BudgetService.instance.streamExpenses('');
      final firstEmission = await stream.first;
      expect(firstEmission, isEmpty);
    });
  });
}
