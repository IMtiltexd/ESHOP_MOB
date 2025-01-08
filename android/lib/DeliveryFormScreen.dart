import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'PaymentScreen.dart';

class DeliveryFormScreen extends StatefulWidget {
  final String userId;

  const DeliveryFormScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _DeliveryFormScreenState createState() => _DeliveryFormScreenState();
}

class _DeliveryFormScreenState extends State<DeliveryFormScreen> {
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController buildingController = TextEditingController();
  final TextEditingController apartmentController = TextEditingController();
  List<String> suggestions = [];
  DateTime? selectedDate;

  Future<void> fetchAddressSuggestions(String input) async {
    if (input.isEmpty) return;

    const String apiKey = '9bff77d3a3f2941ff98d17782f64e2d6245c71fc';
    const String apiUrl =
        'https://suggestions.dadata.ru/suggestions/api/4_1/rs/suggest/address';

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $apiKey',
      },
      body: json.encode({
        'query': input,
        'count': 5,
        'locations': [{'city': 'Владимир'}],
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        suggestions = (data['suggestions'] as List)
            .map((item) => item['value'] as String)
            .toList();
      });
    } else {
      setState(() {
        suggestions = [];
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Доставка", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white), // Стрелочка "назад"
      ),
      body: Container(
        color: Colors.grey[900],
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              controller: phoneController,
              labelText: "Номер телефона",
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: addressController,
              labelText: "Адрес доставки",
              onChanged: fetchAddressSuggestions,
            ),
            const SizedBox(height: 16),
            if (suggestions.isNotEmpty)
              Container(
                color: Colors.grey[850],
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: suggestions.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        suggestions[index],
                        style: const TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        addressController.text = suggestions[index];
                        setState(() {
                          suggestions.clear();
                        });
                      },
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: buildingController,
              labelText: "Номер подъезда",
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: apartmentController,
              labelText: "Номер квартиры",
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDate == null
                      ? "Выберите дату доставки"
                      : "Дата доставки: ${selectedDate?.toLocal().toString().split(' ')[0]}",
                  style: const TextStyle(color: Colors.white),
                ),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    foregroundColor: Colors.white, // Белый текст
                  ),
                  child: const Text("Выбрать дату"),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                if (phoneController.text.isNotEmpty &&
                    addressController.text.isNotEmpty &&
                    buildingController.text.isNotEmpty &&
                    apartmentController.text.isNotEmpty &&
                    selectedDate != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentScreen(
                        phoneNumber: phoneController.text,
                        address: addressController.text,
                        building: buildingController.text,
                        deliveryDate: selectedDate!,
                        userId: widget.userId,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Заполните все поля")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                foregroundColor: Colors.white, // Белый текст
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Далее"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType? keyboardType,
    void Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white70),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
    );
  }
}
