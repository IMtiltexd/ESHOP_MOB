import 'package:uuid/uuid.dart';

class User {
  final String id; // ID теперь всегда строка (UUID)
  final String username;
  final String email;
  final String password;

  // Генерация ID с помощью UUID
  User({String? id, required this.username, required this.email, required this.password})
      : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      password: map['password'],
    );
  }
}
