import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'LoginScreen.dart';
import 'OrderHistoryScreen.dart'; // Экран истории заказов

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _id = "";
  String _avatarUrl = "https://via.placeholder.com/150"; // Ссылка по умолчанию
  String _username = ""; // Данные о пользователе будут загружены из SharedPreferences
  String _email = ""; // Почта будет загружена из SharedPreferences

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _id = prefs.getString('id') ?? ""; // Загружаем ID пользователя
      _username = prefs.getString('username') ?? ""; // Загружаем имя пользователя
      _email = prefs.getString('email') ?? ""; // Загружаем email
      _avatarUrl = prefs.getString('avatarUrl') ?? "https://via.placeholder.com/150"; // Загружаем аватар
    });
    print("Loaded user data: username = $_username, email = $_email, id = $_id");
  }

  // Выбор изображения для профиля
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _avatarUrl = image.path; // Сохраняем локальный путь изображения
      });

      // Сохраняем выбранное изображение в SharedPreferences (опционально)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('avatarUrl', image.path);
    }
  }

  // Метод выхода
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Полностью очищаем данные пользователя

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Вы вышли из аккаунта")),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Профиль", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _pickImage,  // Выбор изображения при нажатии
              child: CircleAvatar(
                radius: 60,
                backgroundImage: _avatarUrl.startsWith('http')
                    ? NetworkImage(_avatarUrl)
                    : FileImage(File(_avatarUrl)) as ImageProvider,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _username,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              _email,
              style: const TextStyle(color: Colors.black),
            ),

            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                "Выйти",
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderHistoryScreen(userId: _id), // Передаем ID пользователя
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                "История заказов",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
