



class Order {
  final String id; // Уникальный идентификатор заказа
  final String userId; // ID пользователя, связанного с заказом
  final String status; // Статус заказа (например, "доставляется" или "доставлен")
  final String address; // Адрес доставки
  final String phoneNumber; // Номер телефона пользователя
  final List<Map<String, dynamic>> products; // Список товаров в заказе
  final double totalPrice; // Общая стоимость заказа
  final DateTime createdAt; // Дата создания заказа

  Order({
    required this.id,
    required this.userId,
    required this.status,
    required this.address,
    required this.phoneNumber,
    required this.products,
    required this.totalPrice,
    required this.createdAt,
  });

  // Преобразование объекта Order в Map для сохранения в базе данных
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'status': status,
      'address': address,
      'phoneNumber': phoneNumber,
      'products': products.map((product) => product.toString()).toList(),
      'totalPrice': totalPrice,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Преобразование Map в объект Order
  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      userId: map['userId'],
      status: map['status'],
      address: map['address'],
      phoneNumber: map['phoneNumber'],
      products: (map['products'] as List<dynamic>)
          .map((product) => Map<String, dynamic>.from(product as Map))
          .toList(),
      totalPrice: map['totalPrice'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
