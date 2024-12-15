import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'DatabaseHelper.dart';
import 'MainScreen.dart';
import 'RegisterScreen.dart'; // Экран регистрации

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController(); // Почта
  final TextEditingController _passwordController = TextEditingController();
  bool _stayLoggedIn = false;

  // Логика входа
  Future<void> _loginUser() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Введите почту и пароль")),
      );
      return;
    }

    final user = await DatabaseHelper.instance.loginUserByEmail(email, password);

    if (user != null) {
      if (_stayLoggedIn) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('email', email); // Сохраняем email
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Неверная почта или пароль")),
      );
    }
  }

  // Переход на экран регистрации
  void _navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Вход")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
            Row(
              children: [
                Checkbox(
                  value: _stayLoggedIn,
                  onChanged: (value) {
                    setState(() {
                      _stayLoggedIn = value ?? false;
                    });
                  },
                ),
                const Text("Оставаться в системе"),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loginUser,
              child: const Text("Войти"),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _navigateToRegister,
              child: const Text("Нет аккаунта? Зарегистрироваться"),
            ),
          ],
        ),
      ),
    );
  }
}
