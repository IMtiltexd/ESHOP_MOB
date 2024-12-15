import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String url = "https://docs.flutter.dev/assets/images/flutter-logo-sharing.png";

  void _changeImage() {
    setState(() {
      url = "https://source.unsplash.com/random/800x600";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Смените изображение нажатием на кнопку'),
            ElevatedButton(
              onPressed: _changeImage,
              child: const Text("Сменить изображение"),
            ),
            Center(
              child: Container(
                constraints: const BoxConstraints(minHeight: 200, minWidth: 300),
                child: FittedBox(
                  child: Image.network(
                    url,
                    errorBuilder: (context, error, stackTrace) {
                      return const Text('Не удалось загрузить изображение');
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}