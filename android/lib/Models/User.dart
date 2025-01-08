import 'package:uuid/uuid.dart';

class User {
  final String id;
  final String username;
  final String email;
  final String password;
  final String role; // Роль пользователя

  User({
    String? id,
    required this.username,
    required this.email,
    required this.password,
    this.role = 'User', // По умолчанию роль - User
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'role': role,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      password: map['password'],
      role: map['role'], // Парсим роль из базы данных
    );
  }
}

