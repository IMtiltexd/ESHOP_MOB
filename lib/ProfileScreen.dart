import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'LoginScreen.dart';

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
      _id = prefs.getString('id') ?? ""; // Загружаем id
      _username = prefs.getString('username') ?? ""; // Загружаем имя
      _email = prefs.getString('email') ?? "";      // Загружаем email
      _avatarUrl = prefs.getString('avatarUrl') ?? "https://via.placeholder.com/150"; // Загружаем аватар
    });
    print("Loaded user data: username = $_username, email = $_email, avatarUrl = $_avatarUrl, id = $_id");
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

    // Удаляем только сессионные данные


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
      appBar: AppBar(title: const Text("Профиль")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,  // Выбор изображения при нажатии
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _avatarUrl.startsWith('http')
                    ? NetworkImage(_avatarUrl)
                    : FileImage(File(_avatarUrl)) as ImageProvider,
              ),
            ),
            const SizedBox(height: 16),
            Text("Имя: $_username"),
            Text("Email: $_email"),
            Text("ID: $_id"),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _logout,
              child: const Text("Выйти"),
            ),
          ],
        ),
      ),
    );
  }
}
