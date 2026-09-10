import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'database_tables.dart';
import 'destination_model.dart';
import 'expense_model.dart';
import 'favorite_model.dart';
import 'itinerary_model.dart';
import 'trip_model.dart';
import 'user_model.dart';

class DbHelper {
  static final DbHelper instance = DbHelper._init();
  static Database? _database;

  DbHelper._init();

  Future<Database> get database async {
    if (_database != null && _database!.isOpen) return _database!;
    _database = await _initDB('project_tride.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onConfigure: _onConfigure,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute(DatabaseTables.createUsersTable);
    await db.execute(DatabaseTables.createDestinationsTable);
    await db.execute(DatabaseTables.createTripsTable);
    await db.execute(DatabaseTables.createItinerariesTable);
    await db.execute(DatabaseTables.createExpensesTable);
    await db.execute(DatabaseTables.createFavoritesTable);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE ${DatabaseTables.tableDestinations} ADD COLUMN ${DestinationColumns.placeType} TEXT',
      );
    }
  }

  Future<void> closeDatabase() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
    }
  }

  // ==================================================
  // USERS CRUD
  // ==================================================

  Future<int> insertUser(UserModel user) async {
    final db = await database;
    return await db.insert(
      DatabaseTables.tableUsers,
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
  }

  Future<int> registerUser(UserModel user) async {
    final existingUser = await getUserByEmail(user.email);
    if (existingUser != null) {
      return -1;
    }
    return await insertUser(user);
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final db = await database;
    final result = await db.query(
      DatabaseTables.tableUsers,
      where: 'email = ?',
      whereArgs: [email],
    );

    if (result.isNotEmpty) {
      return UserModel.fromMap(result.first);
    }
    return null;
  }

  Future<List<UserModel>> getUsers() async {
    final db = await database;
    final result = await db.query(DatabaseTables.tableUsers);
    return result.map((json) => UserModel.fromMap(json)).toList();
  }

  Future<UserModel?> getUserById(int id) async {
    final db = await database;
    final result = await db.query(
      DatabaseTables.tableUsers,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return UserModel.fromMap(result.first);
    }
    return null;
  }

  Future<UserModel?> loginUser(String email, String password) async {
    final db = await database;
    final result = await db.query(
      DatabaseTables.tableUsers,
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (result.isNotEmpty) {
      return UserModel.fromMap(result.first);
    }
    return null;
  }

  Future<int> updateUser(UserModel user) async {
    final db = await database;
    if (user.id == null) return 0;
    return await db.update(
      DatabaseTables.tableUsers,
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete(
      DatabaseTables.tableUsers,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================================================
  // DESTINATIONS CRUD
  // ==================================================

  Future<int> insertDestination(DestinationModel destination) async {
    final db = await database;
    return await db.insert(
      DatabaseTables.tableDestinations,
      destination.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> ensureDestinationExists(DestinationModel destination) async {
    if (destination.id == null) return;
    final existing = await getDestinationById(destination.id!);
    if (existing == null) {
      await insertDestination(destination);
    } else if (existing.placeType == null && destination.placeType != null) {
      await updateDestination(destination);
    }
  }

  Future<List<DestinationModel>> getDestinations() async {
    final db = await database;
    final result = await db.query(DatabaseTables.tableDestinations);
    return result.map((json) => DestinationModel.fromMap(json)).toList();
  }

  Future<DestinationModel?> getDestinationById(int id) async {
    final db = await database;
    final result = await db.query(
      DatabaseTables.tableDestinations,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return DestinationModel.fromMap(result.first);
    }
    return null;
  }

  Future<int> updateDestination(DestinationModel destination) async {
    final db = await database;
    if (destination.id == null) return 0;
    return await db.update(
      DatabaseTables.tableDestinations,
      destination.toMap(),
      where: 'id = ?',
      whereArgs: [destination.id],
    );
  }

  Future<int> deleteDestination(int id) async {
    final db = await database;
    return await db.delete(
      DatabaseTables.tableDestinations,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================================================
  // TRIPS CRUD
  // ==================================================

  Future<int> insertTrip(TripModel trip) async {
    final db = await database;
    return await db.insert(
      DatabaseTables.tableTrips,
      trip.toMap(),
    );
  }

  Future<List<TripModel>> getTripsByUser(int userId) async {
    final db = await database;
    final result = await db.query(
      DatabaseTables.tableTrips,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'start_date ASC',
    );
    return result.map((json) => TripModel.fromMap(json)).toList();
  }

  Future<TripModel?> getTripById(int id) async {
    final db = await database;
    final result = await db.query(
      DatabaseTables.tableTrips,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return TripModel.fromMap(result.first);
    }
    return null;
  }

  Future<int> updateTrip(TripModel trip) async {
    final db = await database;
    if (trip.sqliteId == null) return 0;
    return await db.update(
      DatabaseTables.tableTrips,
      trip.toMap(),
      where: 'id = ?',
      whereArgs: [trip.sqliteId],
    );
  }

  Future<int> deleteTrip(int id) async {
    final db = await database;
    return await db.delete(
      DatabaseTables.tableTrips,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================================================
  // ITINERARIES CRUD
  // ==================================================

  Future<int> insertItinerary(ItineraryModel itinerary) async {
    final db = await database;
    return await db.insert(
      DatabaseTables.tableItineraries,
      itinerary.toMap(),
    );
  }

  Future<List<ItineraryModel>> getItinerariesByTrip(int tripId) async {
    final db = await database;
    final result = await db.query(
      DatabaseTables.tableItineraries,
      where: 'trip_id = ?',
      whereArgs: [tripId],
      orderBy: 'day ASC, start_time ASC',
    );
    return result.map((json) => ItineraryModel.fromMap(json)).toList();
  }

  Future<int> updateItinerary(ItineraryModel itinerary) async {
    final db = await database;
    if (itinerary.id == null) return 0;
    return await db.update(
      DatabaseTables.tableItineraries,
      itinerary.toMap(),
      where: 'id = ?',
      whereArgs: [itinerary.id],
    );
  }

  Future<int> deleteItinerary(int id) async {
    final db = await database;
    return await db.delete(
      DatabaseTables.tableItineraries,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================================================
  // EXPENSES CRUD
  // ==================================================

  Future<void> ensureDefaultTripExists([int tripId = 1]) async {
    // Fake/default trip creation removed as Firestore is now the source of truth for Trips.
  }

  Future<int> insertExpense(ExpenseModel expense) async {
    await ensureDefaultTripExists(expense.tripIdAsInt);
    final db = await database;
    return await db.insert(
      DatabaseTables.tableExpenses,
      expense.toMap(),
    );
  }

  Future<List<ExpenseModel>> getExpensesByTrip(int tripId) async {
    final db = await database;
    final result = await db.query(
      DatabaseTables.tableExpenses,
      where: 'trip_id = ?',
      whereArgs: [tripId],
      orderBy: 'date DESC',
    );
    return result.map((json) => ExpenseModel.fromMap(json)).toList();
  }

  Future<List<ExpenseModel>> getAllExpenses() async {
    final db = await database;
    final result = await db.query(
      DatabaseTables.tableExpenses,
      orderBy: 'id DESC',
    );
    return result.map((json) => ExpenseModel.fromMap(json)).toList();
  }

  Future<int> updateExpense(ExpenseModel expense) async {
    final db = await database;
    if (expense.id == null) return 0;
    return await db.update(
      DatabaseTables.tableExpenses,
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> deleteExpense(int id) async {
    final db = await database;
    return await db.delete(
      DatabaseTables.tableExpenses,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================================================
  // FAVORITES CRUD
  // ==================================================

  Future<int> addFavorite(FavoriteModel favorite) async {
    final db = await database;
    return await db.insert(
      DatabaseTables.tableFavorites,
      favorite.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<List<FavoriteModel>> getFavoritesByUser(int userId) async {
    final db = await database;
    final result = await db.query(
      DatabaseTables.tableFavorites,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return result.map((json) => FavoriteModel.fromMap(json)).toList();
  }

  Future<bool> isFavorite(int userId, int destinationId) async {
    final db = await database;
    final result = await db.query(
      DatabaseTables.tableFavorites,
      where: 'user_id = ? AND destination_id = ?',
      whereArgs: [userId, destinationId],
    );
    return result.isNotEmpty;
  }

  Future<int> removeFavorite(int userId, int destinationId) async {
    final db = await database;
    return await db.delete(
      DatabaseTables.tableFavorites,
      where: 'user_id = ? AND destination_id = ?',
      whereArgs: [userId, destinationId],
    );
  }
}

/// Compatibility alias
typedef DatabaseHelper = DbHelper;
