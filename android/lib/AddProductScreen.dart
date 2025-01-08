import 'package:flutter/material.dart';
import 'DatabaseHelper.dart';
import 'AddProductForm.dart';
import 'Models/Product.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final products = await DatabaseHelper.instance.fetchProducts();
    setState(() {
      _products = products;
    });
  }

  Future<void> _navigateToAddProductForm() async {
    final newProduct = await Navigator.push<Product>(
      context,
      MaterialPageRoute(builder: (context) => const AddProductForm()),
    );
    if (newProduct != null) {
      await DatabaseHelper.instance.insertProduct(newProduct);
      _loadProducts(); // Обновление списка
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Товары")),
      body: ListView.builder(
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return ListTile(
            title: Text(product.name),
            subtitle: Text(
              "Категория: ${product.category}\nЦена: ${product.price} ₽\nНа складе: ${product.stock}",
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddProductForm,
        child: const Icon(Icons.add),
      ),
    );
  }
}
