import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'DatabaseHelper.dart';
import 'Models/User.dart';
import 'LoginScreen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  Future<void> _registerUser() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Пожалуйста, заполните все поля")),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Пароли не совпадают")),
      );
      return;
    }

    final user = User(username: name, email: email, password: password); // ID создаётся автоматически

    final result = await DatabaseHelper.instance.registerUser(user);

    if (result > 0) {
      // Сохранение данных в SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', name); // Сохранить имя пользователя
      await prefs.setString('email', email);  // Сохранить email
      await prefs.setString('id', user.id);   // Сохранить ID пользователя

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ошибка при регистрации")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Регистрация")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Имя"),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Почта"),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: "Пароль"),
              obscureText: true,
            ),
            TextField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(labelText: "Подтвердите пароль"),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _registerUser,
              child: const Text("Зарегистрироваться"),
            ),
          ],
        ),
      ),
    );
  }
}
