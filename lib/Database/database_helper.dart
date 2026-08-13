import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:project_tride/Models/user_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('project_tride.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';

    await db.execute('''
      CREATE TABLE users (
        id $idType,
        nama $textType,
        email $textType UNIQUE,
        password $textType
      )
    ''');
  }

  /// Register a new user.
  /// Returns the inserted row id, or -1 if the email is already registered.
  Future<int> registerUser(UserModel user) async {
    final db = await instance.database;

    // Check if email already exists
    final existingUser = await getUserByEmail(user.email);
    if (existingUser != null) {
      return -1; // Email already registered
    }

    return await db.insert('users', user.toMap());
  }

  /// Check if user exists by email
  Future<UserModel?> getUserByEmail(String email) async {
    final db = await instance.database;

    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (result.isNotEmpty) {
      return UserModel.fromMap(result.first);
    }
    return null;
  }

  /// Verify login credentials.
  /// Returns [UserModel] if credentials are correct, null otherwise.
  Future<UserModel?> loginUser(String email, String password) async {
    final db = await instance.database;

    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (result.isNotEmpty) {
      return UserModel.fromMap(result.first);
    }
    return null;
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
