import 'package:flutter/material.dart';
import 'DatabaseHelper.dart';

class OrderDetailsScreen extends StatelessWidget {
  final int orderId;

  const OrderDetailsScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: DatabaseHelper.instance.fetchOrderDetails(orderId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final orderData = snapshot.data!;
        final order = orderData['order'];
        final products = orderData['products'];
        final totalSum = orderData['totalSum'];

        return Scaffold(
          backgroundColor: Colors.white, // Белый фон
          appBar: AppBar(
            title: Text("Детали заказа #${order['id']}"),
            backgroundColor: Colors.black, // Чёрная шапка
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Дата: ${order['deliveryDate']}",
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                ),
                Text(
                  "Адрес: ${order['address']}",
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                ),
                Text(
                  "Телефон: ${order['phoneNumber']}",
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Товары:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.separated(
                    itemCount: products.length,
                    separatorBuilder: (context, index) => const Divider(
                      color: Colors.grey, // Цвет полоски
                      thickness: 1.0, // Толщина полоски
                    ),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['name'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    "Количество: ${product['quantity']}",
                                    style: const TextStyle(color: Colors.black54, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              "${product['price']} ₽",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Общая сумма: $totalSum ₽",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
