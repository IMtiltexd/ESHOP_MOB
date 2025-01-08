import 'dart:convert';
import 'DatabaseHelper.dart';
import 'Models/Product.dart';
import 'UserManager.dart';

class CartManager {
  /// Получение элементов корзины из базы данных
  static Future<Map<Product, int>> getCartItems() async {
    final userId = await UserManager.getUserId();
    if (userId == null) return {};

    final dbCartItems = await DatabaseHelper.instance.getCartItems(userId);
    final Map<Product, int> cartItems = {};

    for (var item in dbCartItems) {
      final product = await DatabaseHelper.instance.getProductById(item['productId']);
      if (product != null) {
        cartItems[product] = item['quantity'] as int;
      }
    }

    return cartItems;
  }

  /// Добавление товара в корзину
  static Future<void> addToCart(Product product) async {
    final userId = await UserManager.getUserId();
    if (userId == null) return;

    await DatabaseHelper.instance.addToCart(product, userId);
  }

  /// Удаление товара из корзины
  static Future<void> removeFromCart(Product product) async {
    final userId = await UserManager.getUserId();
    if (userId == null || product.id == null) {
      // Обработать случай, когда userId или product.id равны null
      print("Ошибка: userId или product.id равны null");
      return;
    }

    await DatabaseHelper.instance.removeFromCart(product.id!, userId);
  }

  /// Уменьшение количества товара в корзине на единицу
  static Future<void> removeOneFromCart(Product product) async {
    final userId = await UserManager.getUserId();
    if (userId == null || product.id == null) {
      // Обработать случай, когда userId или product.id равны null
      print("Ошибка: userId или product.id равны null");
      return;
    }

    await DatabaseHelper.instance.decreaseCartItem(product.id!, userId);
  }


  /// Очистка корзины
  static Future<void> clearCart() async {
    final userId = await UserManager.getUserId();
    if (userId == null) return;

    await DatabaseHelper.instance.clearCart(userId);
  }
}

// Добавим новые методы в DatabaseHelper
extension DatabaseHelperExtensions on DatabaseHelper {
  Future<List<Map<String, dynamic>>> getCartItems(String userId) async {
    final db = await database;
    return await db.query('cart', where: 'userId = ?', whereArgs: [userId]);
  }

  Future<Product?> getProductById(int productId) async {
    final db = await database;
    final result = await db.query('products', where: 'id = ?', whereArgs: [productId]);
    if (result.isNotEmpty) {
      return Product.fromMap(result.first);
    }
    return null;
  }

  Future<void> addToCart(Product product, String userId) async {
    final db = await database;

    final existingItem = await db.query(
      'cart',
      where: 'userId = ? AND productId = ?',
      whereArgs: [userId, product.id],
    );

    if (existingItem.isNotEmpty) {
      await db.update(
        'cart',
        {
          'quantity': (existingItem.first['quantity'] as int) + 1,
        },
        where: 'userId = ? AND productId = ?',
        whereArgs: [userId, product.id],
      );
    } else {
      await db.insert('cart', {
        'userId': userId,
        'productId': product.id,
        'quantity': 1,
      });
    }
  }

  Future<void> removeFromCart(int productId, String userId) async {
    final db = await database;
    await db.delete('cart', where: 'userId = ? AND productId = ?', whereArgs: [userId, productId]);
  }

  Future<void> decreaseCartItem(int productId, String userId) async {
    final db = await database;

    final existingItem = await db.query(
      'cart',
      where: 'userId = ? AND productId = ?',
      whereArgs: [userId, productId],

    );

    if (existingItem.isNotEmpty) {
      final currentQuantity = existingItem.first['quantity'] as int;

      if (currentQuantity > 1) {
        await db.update(
          'cart',
          {
            'quantity': currentQuantity - 1,
          },
          where: 'userId = ? AND productId = ?',
          whereArgs: [userId, productId],
        );
      } else {
        await debugTableContents('orders'); // Просмотр данных в таблице orders
        await debugTableContents('order_products'); // Просмотр данных в таблице order_products
        await debugTableContents('cart'); // Просмотр данных в таблице cart (до очистки)

        await db.delete('cart', where: 'userId = ? AND productId = ?', whereArgs: [userId, productId]);
      }
    }
  }
}
