class Product {
  final int? id;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final int stock;
  final String category;

  Product({
    this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.stock,
    required this.category,
  });

  // Преобразуем объект Product в Map для сохранения в базе данных
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'price': price,
      'stock': stock,
      'category': category,
    };
  }

  // Преобразуем Map в объект Product
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      imageUrl: map['imageUrl'],
      price: map['price'],
      stock: map['stock'],
      category: map['category'],
    );
  }

  // Переопределение оператора == для корректного сравнения объектов Product
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.id == id;
  }

  // Переопределение hashCode для корректной работы в коллекциях
  @override
  int get hashCode => id.hashCode;
}
