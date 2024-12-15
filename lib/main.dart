import 'package:flutter/material.dart';
import 'LoginScreen.dart';
import 'MainScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MyApp(startScreen: isLoggedIn ? const MainScreen() : const LoginScreen()));
}

class MyApp extends StatelessWidget {
  final Widget startScreen;

  const MyApp({Key? key, required this.startScreen}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: startScreen,
    );
  }
}
