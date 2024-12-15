import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'Models/Product.dart';
import 'Models/User.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app_database.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Таблица пользователей
    await db.execute('''
 CREATE TABLE users (
  id TEXT PRIMARY KEY,
  username TEXT NOT NULL UNIQUE,
  email TEXT NOT NULL UNIQUE,
  password TEXT NOT NULL
);

    ''');

    // Таблица продуктов
    await db.execute('''
    CREATE TABLE products (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      description TEXT NOT NULL,
      imageUrl TEXT NOT NULL,
      price REAL NOT NULL,
      stock INTEGER NOT NULL,
      category TEXT NOT NULL
    )
    ''');
  }

  // Регистрация пользователя
  Future<int> registerUser(User user) async {
    final db = await instance.database;
    return await db.insert('users', user.toMap());
  }

  // Проверка логина пользователя
  Future<User?> loginUserByEmail(String email, String password) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  /// Добавление товара
  Future<int> insertProduct(Product product) async {
    final db = await instance.database;
    final id = await db.insert('products', product.toMap());
    print('Product inserted with ID: $id'); // Debug
    return id;
  }

  /// Получение списка всех товаров
  Future<List<Product>> fetchProducts() async {
    final db = await instance.database;
    final result = await db.query('products');
    print('Fetched products: $result'); // Debug
    return result.map((json) => Product.fromMap(json)).toList();
  }

  /// Обновление товара
  Future<int> updateProduct(Product product) async {
    final db = await instance.database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  /// Удаление товара
  Future<int> deleteProduct(int id) async {
    final db = await instance.database;
    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Закрытие базы данных
  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
