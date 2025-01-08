import 'package:flutter/material.dart';
import 'CartManager.dart';
import 'Models/Product.dart';
import 'DeliveryFormScreen.dart'; // Экран для ввода данных доставки
import 'package:shared_preferences/shared_preferences.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late Future<Map<Product, int>> _cartItemsFuture;
  String? userId;
  double totalAmount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _loadCartItems();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('id'); // Получаем ID пользователя
    });
  }

  Future<void> _loadCartItems() async {
    setState(() {
      _cartItemsFuture = CartManager.getCartItems();
    });
    final cartItems = await CartManager.getCartItems();
    setState(() {
      totalAmount = cartItems.entries
          .map((e) => e.key.price * e.value)
          .reduce((a, b) => a + b);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Корзина", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder<Map<Product, int>>(
        future: _cartItemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                "Произошла ошибка при загрузке корзины",
                style: TextStyle(color: Colors.black),
              ),
            );
          }

          final cartItems = snapshot.data ?? {};

          return cartItems.isEmpty
              ? const Center(
            child: Text(
              "Ваша корзина пуста",
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
          )
              : Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final product = cartItems.keys.elementAt(index);
                    final quantity = cartItems[product]!;

                    return Card(
                      color: Colors.black87,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            product.imageUrl.isNotEmpty
                                ? Image.network(
                              product.imageUrl,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            )
                                : Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey,
                                child: const Icon(
                                  Icons.image,
                                  color: Colors.white,
                                )),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "${product.price} ₽",
                                    style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove,
                                      color: Colors.white),
                                  onPressed: () async {
                                    await CartManager.removeOneFromCart(
                                        product);
                                    _loadCartItems();
                                  },
                                ),
                                Text(
                                  quantity.toString(),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add,
                                      color: Colors.white),
                                  onPressed: quantity < product.stock
                                      ? () async {
                                    await CartManager.addToCart(
                                        product);
                                    _loadCartItems();
                                  }
                                      : null, // Отключаем кнопку, если максимум достигнут
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () async {
                                    await CartManager.removeFromCart(
                                        product);
                                    _loadCartItems();
                                  },
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                color: Colors.black,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Итого:",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "$totalAmount ₽",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: userId != null
                          ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DeliveryFormScreen(userId: userId!),
                          ),
                        );
                      }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text("Оформить заказ"),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }}