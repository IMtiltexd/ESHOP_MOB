import 'package:flutter/material.dart';
import 'CartManager.dart';
import 'Models/Product.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late Future<Map<Product, int>> _cartItemsFuture;

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    setState(() {
      _cartItemsFuture = CartManager.getCartItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Корзина"),
      ),
      body: FutureBuilder<Map<Product, int>>(
        future: _cartItemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Произошла ошибка при загрузке корзины"));
          }

          final cartItems = snapshot.data ?? {};

          return cartItems.isEmpty
              ? const Center(child: Text("Ваша корзина пуста"))
              : ListView.builder(
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final product = cartItems.keys.elementAt(index);
              final quantity = cartItems[product]!;

              return ListTile(
                leading: product.imageUrl.isNotEmpty
                    ? Image.network(product.imageUrl, width: 50, height: 50)
                    : const Icon(Icons.image),
                title: Text(product.name),
                subtitle: Text("${product.price} ₽ x $quantity = ${product.price * quantity} ₽"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () async {
                        await CartManager.removeOneFromCart(product);
                        _loadCartItems();
                      },
                    ),
                    Text(quantity.toString(), style: const TextStyle(fontSize: 16)),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () async {
                        await CartManager.addToCart(product);
                        _loadCartItems();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        await CartManager.removeFromCart(product);
                        _loadCartItems();
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
