class DatabaseTables {
  static const String tableUsers = 'users';
  static const String tableDestinations = 'destinations';
  static const String tableTrips = 'trips';
  static const String tableItineraries = 'itineraries';
  static const String tableExpenses = 'expenses';
  static const String tableFavorites = 'favorites';

  static const String createUsersTable = '''
    CREATE TABLE $tableUsers (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      email TEXT NOT NULL UNIQUE,
      password TEXT NOT NULL,
      profile_image TEXT NULL,
      created_at TEXT NOT NULL
    )
  ''';

  static const String createDestinationsTable = '''
    CREATE TABLE $tableDestinations (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      location TEXT NOT NULL,
      description TEXT NOT NULL,
      image TEXT NOT NULL,
      category TEXT NOT NULL,
      rating REAL DEFAULT 0,
      estimated_budget INTEGER DEFAULT 0,
      best_time TEXT NULL,
      latitude REAL NULL,
      longitude REAL NULL
    )
  ''';

  static const String createTripsTable = '''
    CREATE TABLE $tableTrips (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      trip_name TEXT NOT NULL,
      destination_id INTEGER NULL,
      start_date TEXT NOT NULL,
      end_date TEXT NOT NULL,
      budget INTEGER DEFAULT 0,
      travel_style TEXT NULL,
      notes TEXT NULL,
      status TEXT DEFAULT 'upcoming',
      created_at TEXT NOT NULL,
      FOREIGN KEY (user_id) REFERENCES $tableUsers (id) ON DELETE CASCADE,
      FOREIGN KEY (destination_id) REFERENCES $tableDestinations (id) ON DELETE SET NULL
    )
  ''';

  static const String createItinerariesTable = '''
    CREATE TABLE $tableItineraries (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      trip_id INTEGER NOT NULL,
      day INTEGER NOT NULL,
      title TEXT NOT NULL,
      location TEXT NOT NULL,
      start_time TEXT NOT NULL,
      duration INTEGER DEFAULT 0,
      category TEXT NOT NULL,
      transportation TEXT NULL,
      estimated_cost INTEGER DEFAULT 0,
      notes TEXT NULL,
      FOREIGN KEY (trip_id) REFERENCES $tableTrips (id) ON DELETE CASCADE
    )
  ''';

  static const String createExpensesTable = '''
    CREATE TABLE $tableExpenses (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      trip_id INTEGER NOT NULL,
      category TEXT NOT NULL,
      amount INTEGER NOT NULL,
      date TEXT NOT NULL,
      description TEXT NULL,
      FOREIGN KEY (trip_id) REFERENCES $tableTrips (id) ON DELETE CASCADE
    )
  ''';

  static const String createFavoritesTable = '''
    CREATE TABLE $tableFavorites (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      destination_id INTEGER NOT NULL,
      created_at TEXT NOT NULL,
      FOREIGN KEY (user_id) REFERENCES $tableUsers (id) ON DELETE CASCADE,
      FOREIGN KEY (destination_id) REFERENCES $tableDestinations (id) ON DELETE CASCADE,
      UNIQUE (user_id, destination_id)
    )
  ''';
}
