import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'Models/Product.dart';
import 'UserManager.dart';

class CartManager {
  static Future<Map<Product, int>> getCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = await UserManager.getUserId();
    if (userId == null) return {};

    final cartData = prefs.getString('cart_$userId');
    if (cartData != null) {
      final Map<String, dynamic> decodedData = json.decode(cartData);
      return decodedData.map((key, value) {
        final product = Product.fromMap(json.decode(key));
        return MapEntry(product, value);
      });
    }
    return {};
  }

  static Future<void> addToCart(Product product) async {
    final cartItems = await getCartItems();
    if (cartItems.containsKey(product)) {
      cartItems[product] = cartItems[product]! + 1;
    } else {
      cartItems[product] = 1;
    }
    await _saveUserCart(cartItems);
  }

  static Future<void> _saveUserCart(Map<Product, int> cartItems) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = await UserManager.getUserId();
    if (userId == null) return;

    final Map<String, dynamic> encodedData = {};
    cartItems.forEach((product, quantity) {
      encodedData[json.encode(product.toMap())] = quantity;
    });
    await prefs.setString('cart_$userId', json.encode(encodedData));
  }

  static Future<void> removeFromCart(Product product) async {
    final cartItems = await getCartItems();
    cartItems.remove(product);
    await _saveUserCart(cartItems);
  }

  static Future<void> removeOneFromCart(Product product) async {
    final cartItems = await getCartItems();
    if (cartItems.containsKey(product)) {
      if (cartItems[product]! > 1) {
        cartItems[product] = cartItems[product]! - 1;
      } else {
        cartItems.remove(product);
      }
    }
    await _saveUserCart(cartItems);
  }

  static Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = await UserManager.getUserId();
    if (userId != null) {
      await prefs.remove('cart_$userId');
    }
  }
}
