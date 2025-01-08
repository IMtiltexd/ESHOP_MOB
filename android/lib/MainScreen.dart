import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'HomeScreen.dart';
import 'ProfileScreen.dart';
import 'CartScreen.dart';
import 'SettingsScreen.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late String _userRole;
  late int _selectedIndex;

  final List<Widget> _screens = [
    const HomeScreen(),
    const CartScreen(),
    const ProfileScreen(),
    const SettingsScreen(), // Вкладка "Настройки" (будет скрыта для User)
  ];

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _selectedIndex = widget.initialIndex;
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userRole = prefs.getString('role') ?? 'User'; // По умолчанию роль "User"
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Динамически создаём элементы навигации в зависимости от роли
    final items = [
      const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Главная'),
      const BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Корзина'),
      const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
      if (_userRole == 'Admin')
        const BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Настройки'),
    ];

    // Соответствующие экраны
    final screens = [
      const HomeScreen(),
      const CartScreen(),
      const ProfileScreen(),
      if (_userRole == 'Admin') const SettingsScreen(),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: items,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.black,
      ),
    );
  }
}
