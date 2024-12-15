import 'package:flutter/material.dart';
import 'DatabaseHelper.dart';
import 'Models/Product.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;
  const EditProductScreen({Key? key, required this.product}) : super(key: key);

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late String _imageUrl;
  String? _selectedCategory;

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
    _nameController = TextEditingController(text: widget.product.name);
    _descriptionController = TextEditingController(text: widget.product.description);
    _priceController = TextEditingController(text: widget.product.price.toString());
    _stockController = TextEditingController(text: widget.product.stock.toString());
    _imageUrl = widget.product.imageUrl;
    _selectedCategory = widget.product.category;
  }

  // Функция для обновления товара в базе данных
  Future<void> _updateProduct() async {
    final updatedProduct = Product(
      id: widget.product.id,
      name: _nameController.text,
      description: _descriptionController.text,
      imageUrl: _imageUrl,
      price: double.parse(_priceController.text),
      stock: int.parse(_stockController.text),
      category: _selectedCategory ?? "Разное",
    );

    await DatabaseHelper.instance.updateProduct(updatedProduct);
    Navigator.pop(context); // Закрываем экран редактирования
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Редактировать товар"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Название товара'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Описание'),
            ),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Цена'),
            ),
            TextField(
              controller: _stockController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Количество на складе'),
            ),
            DropdownButton<String>(
              value: _selectedCategory,
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _updateProduct,
              child: const Text("Обновить товар"),
            ),
          ],
        ),
      ),
    );
  }
}
