import 'package:flutter/material.dart';
import 'Models/Product.dart';
import 'CartManager.dart'; // Класс для управления корзиной

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Изображение товара
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                image: product.imageUrl.isNotEmpty
                    ? DecorationImage(
                  image: NetworkImage(product.imageUrl),
                  fit: BoxFit.cover,
                )
                    : const DecorationImage(
                  image: AssetImage('assets/no_image.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Название товара
            Text(
              product.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,color: Colors.black
              ),
            ),
            const SizedBox(height: 8),
            // Цена товара
            Text(
              "${product.price} ₽",
              style: const TextStyle(
                fontSize: 20,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            // Описание товара
            Text(
              product.description,
              style: const TextStyle(fontSize: 16,color: Colors.black),
            ),
            const Spacer(),
            // Кнопка добавления в корзину
            ElevatedButton(
              onPressed: () {
                CartManager.addToCart(product);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("${product.name} добавлен в корзину")),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Добавить в корзину",style: const TextStyle(color: Colors.white),),
            ),
          ],
        ),
      ),
    );
  }
}
