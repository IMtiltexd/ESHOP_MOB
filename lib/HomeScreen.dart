import 'package:flutter/material.dart';
import 'Models/Product.dart';
import 'ProductDetailScreen.dart';
import 'DatabaseHelper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Map<String, List<Product>> _productsByCategory = {};
  final List<String> _categories = [
    "Видеокарта",
    "Процессор",
    "БП",
    "Кулер для ЦП",
    "Корпус",
    "Материнская плата",
    "HDD",
    "SSD",
    "Оперативная память",
    "Разное",
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  // Загружаем товары из базы данных и группируем их по категориям
  Future<void> _loadProducts() async {
    final products = await DatabaseHelper.instance.fetchProducts();
    final groupedProducts = <String, List<Product>>{};

    for (var category in _categories) {
      groupedProducts[category] =
          products.where((product) => product.category == category).toList();
    }

    setState(() {
      _productsByCategory.addAll(groupedProducts);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ESHOP"),
      ),
      body: ListView.builder(
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final products = _productsByCategory[category] ?? [];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  category,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 220, // Высота для горизонтального списка
                child: products.isEmpty
                    ? const Center(child: Text("Нет товаров в этой категории"))
                    : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: products.length,
                  itemBuilder: (context, productIndex) {
                    final product = products[productIndex];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductDetailScreen(product: product),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                image: product.imageUrl.isNotEmpty
                                    ? DecorationImage(
                                  image: NetworkImage(product.imageUrl),
                                  fit: BoxFit.cover,
                                )
                                    : const DecorationImage(
                                  image: AssetImage('assets/no_image.png'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: 120,
                              child: Text(
                                product.name,
                                style: const TextStyle(fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${product.price} ₽",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
