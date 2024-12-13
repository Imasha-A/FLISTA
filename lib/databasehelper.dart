import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  static Database? _database;

  DBHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'flights.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
  CREATE TABLE flights(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    origin_country_code TEXT,
    destination_country_code TEXT,
    selected_date TEXT,
    ul_number TEXT,
    scheduled_time TEXT
  )
''');
  }

  Future<void> insertFlight(Map<String, dynamic> flight) async {
    final db = await database;
    await db.insert('flights', flight);
  }

  Future<List<Map<String, dynamic>>> getFlights() async {
    final db = await database;
    return await db.query('flights');
  }

  Future<void> clearFlights() async {
    final db = await database;
    await db.delete('flights');
  }

  Future<void> deleteFlight(String flightKey) async {
    final db = await database;

    // Split the flightKey into its components
    List<String> keyParts = flightKey.split('_');
    String ulNumber = keyParts[0];
    String originCountryCode = keyParts[1];
    String destinationCountryCode = keyParts[2];
    String selectedDate = keyParts[3];
    String scheduledTime = keyParts[4];

    // Delete the flight using the extracted components
    await db.delete(
      'flights',
      where:
          'ul_number = ? AND origin_country_code = ? AND destination_country_code = ? AND selected_date = ? AND scheduled_time = ?',
      whereArgs: [
        ulNumber,
        originCountryCode,
        destinationCountryCode,
        selectedDate,
        scheduledTime,
      ],
    );
  }
}
