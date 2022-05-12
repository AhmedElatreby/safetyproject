import '../contact/personal_emergency_contacts_model.dart';
import 'package:path/path.dart' show join;
import 'package:sqflite/sqflite.dart';
import 'dart:io' as io;
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory;

class DBHelper {
  static Database? _db;
  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    }
    _db = await initDatabase();
    return _db!;
  }

  initDatabase() async {
    io.Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, 'EmergencyContacts.db');
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  _onCreate(Database db, int version) async {
    await db.execute(
        'CREATE TABLE contacts (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, contactNo TEXT, primaryContact BOOLEAN)');
  }

  Future<PersonalEmergency> add(PersonalEmergency contacts) async {
    var dbClient = await db;
    var name = contacts.name;
    var contactNo = contacts.contactNo;
    var primaryContact = contacts.primaryContact;
    dbClient.rawInsert(
        "INSERT into contacts(name,contactNo,primaryContact)"
        "VALUES(?, ?, ?)",
        [name, contactNo, primaryContact]);
    return contacts;
  }

  Future<List<PersonalEmergency>> getContacts() async {
    final dbClient = await db;
    List<Map> maps =
        await dbClient.query('contacts',
            orderBy: 'id DESC',
            columns: ['id', 'name', 'contactNo']);
    List<PersonalEmergency> contacts = [];
    if (maps.isNotEmpty) {
      for (int i = 0; i < maps.length; i++) {
        contacts.add(PersonalEmergency.fromMap(maps[i]));
      }
    }

    return contacts;
  }

  Future<void> delete(int id) async {
    var dbClient = await db;
    await dbClient.delete(
      'contacts',
      where: 'id == ?',
      whereArgs: [id],
    );
  }

  Future<int> update(PersonalEmergency contacts) async {
    var dbClient = await db;
    return await dbClient.update(
      'contacts',
      contacts.toMap(),
      where: 'id = ?',
      whereArgs: [contacts.id],
    );
  }

  Future close() async {
    var dbClient = await db;
    dbClient.close();
  }
}
