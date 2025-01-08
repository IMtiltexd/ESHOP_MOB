import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'Models/Order.dart';
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
    final dbPath = await getDatabasesPath(); // Путь к постоянному хранилищу
    final path = join(dbPath, fileName);    // Создаем полный путь к файлу

    return await openDatabase(
      path,   // Используем путь на устройстве
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
  CREATE TABLE users (
    id TEXT PRIMARY KEY,
    username TEXT NOT NULL UNIQUE,
    email TEXT NOT NULL UNIQUE,
    password TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT 'User' -- Роль пользователя (Admin или User)
  )
  ''');

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

    await db.execute('''
    CREATE TABLE orders (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      userId TEXT NOT NULL,
      phoneNumber TEXT NOT NULL,
      address TEXT NOT NULL,
      building TEXT NOT NULL,
      deliveryDate TEXT NOT NULL,
      status TEXT NOT NULL,
      paymentCard TEXT NOT NULL,
      FOREIGN KEY (userId) REFERENCES users (id)
    )
    ''');

    await db.execute('''
    CREATE TABLE cards (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      cardNumber TEXT NOT NULL
    )
    ''');

    await db.execute('''
    CREATE TABLE cart (
      userId TEXT NOT NULL,
      productId INTEGER NOT NULL,
      quantity INTEGER NOT NULL DEFAULT 0,
      PRIMARY KEY (userId, productId),
      FOREIGN KEY (userId) REFERENCES users (id),
      FOREIGN KEY (productId) REFERENCES products (id)
    )
    ''');

    await db.execute('''
    CREATE TABLE order_products (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      orderId INTEGER NOT NULL,
      productId INTEGER NOT NULL,
      quantity INTEGER NOT NULL,
      FOREIGN KEY (orderId) REFERENCES orders (id),
      FOREIGN KEY (productId) REFERENCES products (id)
    )
    ''');
  }

  Future<List<Map<String, dynamic>>> getCartItems(String userId) async {
    final db = await database;
    return await db.query('cart', where: 'userId = ?', whereArgs: [userId]);
  }

  Future<int> createOrderWithProducts(Map<String, dynamic> order, String userId) async {
    final db = await database;

    return await db.transaction((txn) async {
      // Вставляем заказ в таблицу orders
      final orderId = await txn.insert('orders', order);

      // Получаем товары из корзины
      final cartItems = await txn.query('cart', where: 'userId = ?', whereArgs: [userId]);

      if (cartItems.isEmpty) {
        throw Exception("Корзина пуста. Невозможно создать заказ.");
      }

      for (final item in cartItems) {
        final productId = item['productId'];
        final quantity = (item['quantity'] as int);

        // Проверка существования товара
        final product = await txn.query(
          'products',
          where: 'id = ?',
          whereArgs: [productId],
        );
        if (product.isEmpty) {
          throw Exception("Товар с ID $productId не найден.");
        }

        final stock = (product.first['stock'] as int);


// Проверяем остаток на складе
        if (stock < quantity) {
          throw Exception("Недостаточно товара с ID $productId на складе. Остаток: $stock.");
        }

// Обновляем остаток на складе
        final updatedStock = stock - quantity;
        final rowsUpdated = await txn.update(
          'products',
          {'stock': updatedStock},
          where: 'id = ?',
          whereArgs: [productId],
        );
        if (rowsUpdated == 0) {
          throw Exception("Не удалось обновить остаток для товара с ID $productId.");
        }

        // Вставляем товары в таблицу order_products
        await txn.insert('order_products', {
          'orderId': orderId,
          'productId': productId,
          'quantity': quantity,
        });
      }

      // Очищаем корзину
      await txn.delete('cart', where: 'userId = ?', whereArgs: [userId]);

      return orderId;
    });
  }




  Future<List<Map<String, dynamic>>> fetchAllUsers() async {
    final db = await database;
    return await db.query('users');
  }
  Future<int> createOrderFromCart(Map<String, dynamic> orderData, String userId) async {
    final db = await database;

    // Получаем товары из корзины
    final cartItems = await getCartItems(userId);
    if (cartItems.isEmpty) {
      throw Exception("Корзина пуста. Заказ не может быть создан.");
    }

    // Создаем транзакцию
    return await db.transaction((txn) async {
      // Вставляем данные заказа в таблицу orders
      final orderId = await txn.insert('orders', orderData);
      print("Заказ создан с ID: $orderId");

      // Переносим товары из корзины в order_products и обновляем количество на складе
      for (final item in cartItems) {
        final productId = item['productId'];
        final quantity = item['quantity'];

        // Проверяем наличие товара на складе
        final product = await txn.query(
          'products',
          where: 'id = ?',
          whereArgs: [productId],
        );

        if (product.isEmpty) {
          throw Exception("Товар с ID $productId не найден.");
        }

        final stock = product.first['stock'] as int;

        if (stock < quantity) {
          throw Exception(
            "Недостаточно товара с ID $productId на складе. Остаток: $stock.",
          );
        }

        // Обновляем количество на складе
        final updatedStock = stock - quantity;
        final rowsUpdated = await txn.update(
          'products',
          {'stock': updatedStock},
          where: 'id = ?',
          whereArgs: [productId],
        );

        if (rowsUpdated == 0) {
          throw Exception("Не удалось обновить остаток для товара с ID $productId.");
        }

        // Добавляем товар в таблицу order_products
        print("Добавляем товар в order_products: productId = $productId, quantity = $quantity");
        await txn.insert('order_products', {
          'orderId': orderId,
          'productId': productId,
          'quantity': quantity,
        });
      }

      // Очищаем корзину
      await txn.delete('cart', where: 'userId = ?', whereArgs: [userId]);

      print("Корзина очищена.");
      return orderId;
    });
  }




  Future<Map<String, dynamic>> fetchOrderDetails(int orderId) async {
    final db = await database;

    // Извлекаем данные заказа
    final orderResult = await db.query('orders', where: 'id = ?', whereArgs: [orderId]);
    if (orderResult.isEmpty) {
      throw Exception("Заказ с ID $orderId не найден.");
    }

    final order = orderResult.first;

    // Извлекаем товары, связанные с заказом
    final orderProducts = await db.rawQuery('''
    SELECT p.name, p.price, op.quantity
    FROM order_products op
    JOIN products p ON op.productId = p.id
    WHERE op.orderId = ?
  ''', [orderId]);

    // Рассчитываем общую сумму
    double totalSum = orderProducts.fold(0, (sum, item) {
      return sum + (item['price'] as double) * (item['quantity'] as int);
    });

    return {
      'order': order, // Данные заказа
      'products': orderProducts, // Список товаров
      'totalSum': totalSum, // Общая сумма
    };
  }



  Future<List<Map<String, dynamic>>> fetchOrdersByUserId(String userId) async {
    final db = await instance.database;
    final orders = await db.query(
      'orders',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    print("Orders fetched for user \$userId: \$orders");
    return orders;
  }

  Future<int> insertProduct(Product product) async {
    final db = await instance.database;
    final productId = await db.insert('products', product.toMap());
    print("Product inserted with ID: \$productId");
    return productId;
  }

  Future<List<Product>> fetchProducts() async {
    final db = await instance.database;
    final result = await db.query('products');
    print("Products fetched: \$result");
    return result.map((json) => Product.fromMap(json)).toList();
  }

  Future<void> clearCart(String userId) async {
    final db = await instance.database;
    await debugTableContents('orders'); // Просмотр данных в таблице orders
    await debugTableContents('order_products'); // Просмотр данных в таблице order_products
    await debugTableContents('cart'); // Просмотр данных в таблице cart (до очистки)

    final cleared = await db.delete('cart', where: 'userId = ?', whereArgs: [userId]);



    print("Cart cleared for user \$userId. Rows affected: \$cleared");
  }
  Future<void> debugOrdersTable() async {
    final db = await database;
    final orders = await db.query('orders');
    print('Orders table contents: $orders');
  }
  Future<void> debugCartContents() async {
    final db = await instance.database;
    final cartItems = await db.query('cart');
    print('Cart contents: \$cartItems');
  }

  Future<int> updateOrderStatus(String orderId, String status) async {
    final db = await instance.database;
    final rows = await db.update(
      'orders',
      {'status': status},
      where: 'id = ?',
      whereArgs: [orderId],
    );
    print("Order status updated for order \$orderId. Rows affected: \$rows");
    return rows;
  }

  Future<int> deleteProduct(int id) async {
    final db = await instance.database;
    final rows = await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
    print("Product with ID \$id deleted. Rows affected: \$rows");
    return rows;
  }

  Future<int> updateProduct(Product product) async {
    final db = await instance.database;
    final rows = await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
    print("Product with ID \${product.id} updated. Rows affected: \$rows");
    return rows;
  }

  Future<User?> loginUserByEmail(String email, String password) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (result.isNotEmpty) {
      print("User logged in: \${result.first}");
      return User.fromMap(result.first);
    }
    print("Login failed for email: \$email");
    return null;
  }

  Future<int> registerUser(User user) async {
    final db = await instance.database;
    final userWithRole = user.toMap()
      ..['role'] = 'User'; // Устанавливаем роль по умолчанию

    final userId = await db.insert('users', userWithRole);
    print("User registered with ID: $userId and Role: User");
    return userId;
  }
  Future<String?> getUserRole(String userId) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      columns: ['role'],
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (result.isNotEmpty) {
      return result.first['role'] as String;
    }
    return null;
  }


  Future<List<Product>> fetchProductsByCategory(String category) async {
    final db = await instance.database;
    final result = await db.query('products', where: 'category = ?', whereArgs: [category]);
    return result.map((json) => Product.fromMap(json)).toList();
  }

  // Метод для добавления карты
  Future<int> addCard(String cardNumber) async {
    final db = await instance.database;
    final cardId = await db.insert('cards', {'cardNumber': cardNumber});
    print("Card added with ID: \$cardId");
    return cardId;
  }
  Future<void> updateUserRole(String userId, String newRole) async {
    final db = await database;
    await db.update(
      'users',
      {'role': newRole},
      where: 'id = ?',
      whereArgs: [userId],
    );
    print("Role updated for user $userId to $newRole");
  }

  Future<int> insertOrder(Map<String, dynamic> order) async {
    final db = await instance.database;
    final orderId = await db.insert('orders', order);
    print("Order inserted with ID: \$orderId");
    return orderId;
  }

  // Метод для получения сохранённых карт
  Future<List<String>> fetchSavedCards() async {
    final db = await instance.database;
    final result = await db.query('cards');
    print("Saved cards fetched: \$result");
    return result.map((card) => card['cardNumber'] as String).toList();
  }
  Future<void> debugTableContents(String tableName) async {
    final db = await database;
    final results = await db.query(tableName);
    print("Contents of table $tableName: $results");
  }




}