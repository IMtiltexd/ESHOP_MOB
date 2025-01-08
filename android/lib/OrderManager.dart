import 'CartManager.dart';
import 'DatabaseHelper.dart';
import 'Models/Product.dart';

class OrderManager {
  /// Получение информации о конкретном заказе
  static Future<Map<String, dynamic>> getOrderDetails(int orderId) async {
    try {
      final orderDetails = await DatabaseHelper.instance.fetchOrderDetails(orderId);
      print("Order details fetched for order ID $orderId: $orderDetails");
      return orderDetails;
    } catch (e) {
      print("Error fetching order details: $e");
      throw e;
    }
  }

  /// Получение списка заказов для конкретного пользователя
  static Future<List<Map<String, dynamic>>> getUserOrders(String userId) async {
    try {
      final orders = await DatabaseHelper.instance.fetchOrdersByUserId(userId);
      print("Orders fetched for user ID $userId: $orders");
      return orders;
    } catch (e) {
      print("Error fetching user orders: $e");
      throw e;
    }
  }

  /// Создание нового заказа
  static Future<int> createOrder(String userId, String phoneNumber, String address, String building, DateTime deliveryDate, String paymentCard) async {
    try {
      final cartItems = await CartManager.getCartItems();
      if (cartItems.isEmpty) {
        throw Exception("Cannot create order: Cart is empty.");
      }

      final orderData = {
        'userId': userId,
        'phoneNumber': phoneNumber,
        'address': address,
        'building': building,
        'deliveryDate': deliveryDate.toIso8601String(),
        'status': 'Processing',
        'paymentCard': paymentCard,
      };

      final products = cartItems.entries.map((entry) {
        return {
          'productId': entry.key.id,
          'quantity': entry.value,
        };
      }).toList();

      final orderId = await DatabaseHelper.instance.createOrderWithProducts(orderData, userId);
      print("Order created with ID: $orderId");
      return orderId;
    } catch (e) {
      print("Error creating order: $e");
      throw e;
    }
  }

  /// Обновление статуса заказа
  static Future<void> updateOrderStatus(int orderId, String status) async {
    try {
      final updatedRows = await DatabaseHelper.instance.updateOrderStatus(orderId.toString(), status);
      print("Order status updated for order ID $orderId. Rows affected: $updatedRows");
    } catch (e) {
      print("Error updating order status: $e");
      throw e;
    }
  }
}
