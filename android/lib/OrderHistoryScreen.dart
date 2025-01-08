import 'package:flutter/material.dart';
import 'DatabaseHelper.dart';
import 'MainScreen.dart';
import 'OrderDetailsScreen.dart';

class OrderHistoryScreen extends StatefulWidget {
  final String userId;

  const OrderHistoryScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  late Future<List<Map<String, dynamic>>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    setState(() {
      _ordersFuture = DatabaseHelper.instance.fetchOrdersByUserId(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("История заказов"),
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Произошла ошибка: ${snapshot.error}"));
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return const Center(child: Text("У вас нет заказов"));
          } else {
            final orders = snapshot.data ?? [];

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      final isDelivered = order['status'] == "Доставлен";
                      final isCanceled = order['status'] == "Отменён";

                      return Card(
                        color: Colors.white,
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: ListTile(
                          title: Text("Заказ #${order['id']}", style: const TextStyle(color: Colors.black)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Дата: ${order['deliveryDate']}", style: const TextStyle(color: Colors.black54)),
                              Text("Адрес: ${order['address']}", style: const TextStyle(color: Colors.black54)),
                              Text("Телефон: ${order['phoneNumber']}", style: const TextStyle(color: Colors.black54)),
                              Text("Статус: ${order['status']}", style: const TextStyle(color: Colors.black54)),
                            ],
                          ),
                          trailing: isDelivered
                              ? const Text(
                            "Доставлен",
                            style: TextStyle(color: Colors.green),
                          )
                              : isCanceled
                              ? const Text(
                            "Отменён",
                            style: TextStyle(color: Colors.red),
                          )
                              : Column(
                            mainAxisSize: MainAxisSize.min, // Минимальный размер для Column
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    await DatabaseHelper.instance.updateOrderStatus(
                                      order['id'].toString(),
                                      "Доставлен",
                                    );
                                    _loadOrders();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                  ),
                                  child: const Text(
                                    "Подтвердить доставку",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    await DatabaseHelper.instance.updateOrderStatus(
                                      order['id'].toString(),
                                      "Отменён",
                                    );
                                    _loadOrders();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  child: const Text(
                                    "Отменить",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrderDetailsScreen(orderId: order['id']),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => MainScreen(initialIndex: 2)),
                            (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                    child: const Text("Вернуться в профиль", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
