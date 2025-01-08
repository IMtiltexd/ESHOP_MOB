import 'package:flutter/material.dart';
import 'DatabaseHelper.dart';
import 'Models/Product.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<Product> _products = [];
  List<Map<String, dynamic>> _users = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadUsers(); // Загрузка пользователей
  }

  // Загружаем товары из базы данных
  Future<void> _loadProducts() async {
    final products = await DatabaseHelper.instance.fetchProducts();
    setState(() {
      _products = products;
    });
  }

  // Загружаем пользователей из базы данных
  Future<void> _loadUsers() async {
    final users = await DatabaseHelper.instance.fetchAllUsers();
    setState(() {
      _users = users;
    });
  }

  // Удаляем товар из базы данных
  Future<void> _deleteProduct(int? id) async {
    if (id == null) return;
    await DatabaseHelper.instance.deleteProduct(id);
    _loadProducts();
  }

// Изменение роли пользователя
  Future<void> _changeUserRole(String userId, String currentRole) async {
    final newRole = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Изменить роль пользователя"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text("User"),
                value: "User",
                groupValue: currentRole,
                onChanged: (value) {
                  Navigator.of(context).pop(value);
                },
              ),
              RadioListTile<String>(
                title: const Text("Admin"),
                value: "Admin",
                groupValue: currentRole,
                onChanged: (value) {
                  Navigator.of(context).pop(value);
                },
              ),
            ],
          ),
        );
      },
    );

    // Проверяем, была ли выбрана новая роль, и обновляем базу данных
    if (newRole != null && newRole != currentRole) {
      await DatabaseHelper.instance.updateUserRole(userId, newRole); // Обновляем роль в базе данных
      await _loadUsers(); // Обновляем список пользователей
      setState(() {}); // Перерисовываем экран
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Роль пользователя успешно изменена на $newRole")),
      );
    }
  }
  void _showEditProductDialog(Product product) {
    final TextEditingController nameController = TextEditingController(text: product.name);
    final TextEditingController descriptionController = TextEditingController(text: product.description);
    final TextEditingController imageUrlController = TextEditingController(text: product.imageUrl);
    final TextEditingController priceController = TextEditingController(text: product.price.toString());
    final TextEditingController stockController = TextEditingController(text: product.stock.toString());

    final List<String> categories = [
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

    String selectedCategory = product.category;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Редактировать товар"),
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
              child: Column(
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Название товара"),
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: "Описание"),
                  ),
                  TextField(
                    controller: imageUrlController,
                    decoration: const InputDecoration(labelText: "Ссылка на изображение"),
                  ),
                  TextField(
                    controller: priceController,
                    decoration: const InputDecoration(labelText: "Цена"),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: stockController,
                    decoration: const InputDecoration(labelText: "Количество на складе"),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(labelText: "Категория"),
                    items: categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        selectedCategory = value;
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Отмена"),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedProduct = Product(
                  id: product.id,
                  name: nameController.text,
                  description: descriptionController.text,
                  imageUrl: imageUrlController.text,
                  price: double.tryParse(priceController.text) ?? 0.0,
                  stock: int.tryParse(stockController.text) ?? 0,
                  category: selectedCategory,
                );

                await DatabaseHelper.instance.updateProduct(updatedProduct);
                _loadProducts(); // Обновляем список товаров
                Navigator.of(context).pop();
              },
              child: const Text("Сохранить"),
            ),
          ],
        );
      },
    );
  }
  void _showAddProductDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController imageUrlController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    final TextEditingController stockController = TextEditingController();

    final List<String> categories = [
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

    String selectedCategory = categories[0];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Добавить товар"),
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
              child: Column(
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Название товара"),
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: "Описание"),
                  ),
                  TextField(
                    controller: imageUrlController,
                    decoration: const InputDecoration(labelText: "Ссылка на изображение"),
                  ),
                  TextField(
                    controller: priceController,
                    decoration: const InputDecoration(labelText: "Цена"),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: stockController,
                    decoration: const InputDecoration(labelText: "Количество на складе"),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(labelText: "Категория"),
                    items: categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        selectedCategory = value;
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Отмена"),
            ),
            ElevatedButton(
              onPressed: () async {
                final product = Product(
                  name: nameController.text,
                  description: descriptionController.text,
                  imageUrl: imageUrlController.text,
                  price: double.tryParse(priceController.text) ?? 0.0,
                  stock: int.tryParse(stockController.text) ?? 0,
                  category: selectedCategory,
                );

                await DatabaseHelper.instance.insertProduct(product);
                _loadProducts();
                Navigator.of(context).pop();
              },
              child: const Text("Добавить"),
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
        title: const Text("Настройки"),
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: _showUsersDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 0.7,
              ),
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];

                // Добавили логику обрезки названия, если оно слишком длинное
                final String truncatedName = product.name.length > 30
                    ? product.name.substring(0, 30) + '...'
                    : product.name;

                return Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      product.imageUrl.isNotEmpty
                          ? Image.network(
                        product.imageUrl,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      )
                          : const Icon(Icons.image_not_supported, size: 100),
                      const SizedBox(height: 8),

                      // Выводим обрезанное название
                      Text(
                        truncatedName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text("${product.price} ₽"),
                      const SizedBox(height: 8),
                      Text("${product.stock} шт"),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                _showEditProductDialog(product); // Передаём текущий продукт
                },
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProductDialog,
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Добавить товар',
      ),
    );
  }

  void _showUsersDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Пользователи системы"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                return ListTile(
                  title: Text(user['username']),
                  subtitle: Text("Роль: ${user['role']}"),
                  trailing: ElevatedButton(
                    onPressed: () {
                      _changeUserRole(user['id'], user['role']);
                    },
                    child: const Text("Изменить роль"),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Закрыть"),
            ),
          ],
        );
      },
    );
  }
}
