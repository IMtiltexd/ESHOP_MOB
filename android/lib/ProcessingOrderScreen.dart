import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'OrderConfirmationScreen.dart';
class ProcessingOrderScreen extends StatelessWidget {
  const ProcessingOrderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OrderConfirmationScreen()),
      );
    });

    return Scaffold(
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
