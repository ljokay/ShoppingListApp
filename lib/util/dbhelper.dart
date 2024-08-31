import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/items.dart';
import '../models/shopping_list.dart';

class DbHelper {
  static final DbHelper _dbHelper = DbHelper._internal();
  late Database db;

  DbHelper._internal();

  factory DbHelper() {
    return _dbHelper;
  }

  final int version = 1;
  bool _isDbInitialized = false;

  Future<void> initializeDb() async {
    if (!_isDbInitialized) {
      db = await openDb();
      _isDbInitialized = true;
    }
  }

  Future<Database> openDb() async {
    return openDatabase(
      join(await getDatabasesPath(), 'shopping.db'),
      onCreate: (database, version) {
        database.execute(
          'CREATE TABLE lists(id INTEGER PRIMARY KEY, name TEXT, priority INTEGER)',
        );
        database.execute(
          'CREATE TABLE items(id INTEGER PRIMARY KEY, '
          'idList INTEGER, '
          'name  TEXT, '
          'quantity TEXT,  '
          'note TEXT, '
          'FOREIGN KEY(idList) REFERENCES lists(id))',
        );
      },
      version: version,
    );
  }

  Future<int> insertList(ShoppingList list) async {
    await initializeDb();
    int id = await db.insert(
      'lists',
      list.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  Future<int> insertItem(ListItem item) async {
    await initializeDb();
    int id = await db.insert(
      'items',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  Future<List<ShoppingList>> getLists() async {
    await initializeDb();
    final List<Map<String, dynamic>> maps = await db.query('lists');
    return List.generate(maps.length, (i) {
      return ShoppingList(
        maps[i]['id'],
        maps[i]['name'],
        maps[i]['priority'],
      );
    });
  }

  Future<void> testDb() async {
    await initializeDb();
    await db.execute('INSERT INTO lists VALUES (0, "Fruit", 2)');
    await db.execute(
        'INSERT INTO items VALUES (0, 0, "Apples", "2 Kg", "Better if they are green")');
    List lists = await db.rawQuery('select * from lists');
    List items = await db.rawQuery('select * from items');
    print(lists[0].toString());
    print(items[0].toString());
  }

  Future<List<ListItem>> getItems(int idList) async {
    await initializeDb();
    final List<Map<String, dynamic>> maps = await db.query(
      'items',
      where: 'idList = ?',
      whereArgs: [idList],
    );

    return List.generate(maps.length, (i) {
      return ListItem(
        maps[i]['id'],
        maps[i]['idList'],
        maps[i]['name'],
        maps[i]['quantity'],
        maps[i]['note'],
      );
    });
  }

  Future<int> deleteList(ShoppingList list) async {
    await initializeDb();
    int result = await db.delete("items", where: "idList = ?", whereArgs: [list.id]);
    result = await db.delete("lists", where: "id = ?", whereArgs: [list.id]);
    return result;
  }

  Future<int> deleteItem(ListItem item) async {
    int result = await db.delete("items", where: "id = ?", whereArgs: [item.id]);
    return result;
  }
}