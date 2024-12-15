import 'package:flutter/material.dart';
import 'AddProductForm.dart';
import 'DatabaseHelper.dart';
import 'Models/Product.dart';
import 'AddProductScreen.dart';
import 'EditProductScreen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  // Загружаем товары из базы данных
  Future<void> _loadProducts() async {
    final products = await DatabaseHelper.instance.fetchProducts();
    setState(() {
      _products = products;
    });
  }

  // Удаляем товар из базы данных
  Future<void> _deleteProduct(int? id) async {
    if (id == null) {
      return;
    }
    await DatabaseHelper.instance.deleteProduct(id);
    _loadProducts(); // Перезагружаем список товаров
  }

  // Открытие экрана для редактирования товара
  void _editProduct(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProductScreen(product: product),
      ),
    ).then((_) => _loadProducts()); // Обновляем список товаров после редактирования
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Настройки"),
      ),
      body: _products.isEmpty
          ? const Center(child: CircularProgressIndicator()) // Индикатор загрузки
          : GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 карточки в строке
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: 0.7, // Чтобы карточки были квадратными
        ),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Изображение товара
                product.imageUrl.isNotEmpty
                    ? Image.network(
                  product.imageUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                )
                    : const Icon(Icons.image_not_supported, size: 100),
                const SizedBox(height: 8),
                // Название товара
                Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                // Цена товара
                Text("${product.price} ₽"),
                const SizedBox(height: 8),
                // Кнопки редактирования и удаления
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editProduct(product),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteProduct(product.id),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProductForm()), // Перенаправляем на форму добавления товара
          ).then((newProduct) {
            // Если возвращен новый продукт, добавляем его в базу данных
            if (newProduct != null) {
              DatabaseHelper.instance.insertProduct(newProduct);
              _loadProducts(); // Перезагружаем список товаров после добавления
            }
          });
        },
        child: const Icon(Icons.add),
        tooltip: 'Добавить товар',
      ),

    );
  }
}
