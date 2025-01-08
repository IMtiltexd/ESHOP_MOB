import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Заказ подтвержден")),
      body: const Center(
        child: Text("Заказ успешно оплачен! Ожидайте доставку."),
      ),
    );
  }
}
