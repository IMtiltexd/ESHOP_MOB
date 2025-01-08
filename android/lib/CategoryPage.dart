import 'package:flutter/material.dart';
import 'Models/Product.dart';
import 'DatabaseHelper.dart';

class CategoryPage extends StatefulWidget {
  final String category;

  const CategoryPage({Key? key, required this.category}) : super(key: key);

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List<Product> _products = [];
  double _minPrice = 0;
  double _maxPrice = double.infinity;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _loadCategoryProducts();
  }

  Future<void> _loadCategoryProducts() async {
    final allProducts = await DatabaseHelper.instance.fetchProducts();
    setState(() {
      _products = allProducts.where((p) => p.category == widget.category).toList();
    });
  }

  void _applyFilterAndSort() {
    setState(() {
      _products = _products
          .where((p) => p.price >= _minPrice && p.price <= _maxPrice)
          .toList()
        ..sort((a, b) => _sortAscending ? a.price.compareTo(b.price) : b.price.compareTo(a.price));
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        double tempMinPrice = _minPrice;
        double tempMaxPrice = _maxPrice;
        return AlertDialog(
          title: const Text("Фильтры"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: "Минимальная цена"),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  tempMinPrice = double.tryParse(value) ?? 0;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: "Максимальная цена"),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  tempMaxPrice = double.tryParse(value) ?? double.infinity;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _minPrice = tempMinPrice;
                  _maxPrice = tempMaxPrice;
                  _applyFilterAndSort();
                });
                Navigator.pop(context);
              },
              child: const Text("Применить"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
        actions: [
          IconButton(
            icon: Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
            onPressed: () {
              setState(() {
                _sortAscending = !_sortAscending;
                _applyFilterAndSort();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return ListTile(
            leading: product.imageUrl.isNotEmpty
                ? Image.network(product.imageUrl, width: 50, height: 50, fit: BoxFit.cover)
                : const Icon(Icons.image),
            title: Text(product.name),
            subtitle: Text("${product.price} ₽"),
            onTap: () {
              // Navigate to product detail
            },
          );
        },
      ),
    );
  }
}
