import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'OrderHistoryScreen.dart';
import 'DatabaseHelper.dart';

class PaymentScreen extends StatefulWidget {
  final String phoneNumber;
  final String address;
  final String building;
  final DateTime deliveryDate;
  final String userId;

  const PaymentScreen({
    Key? key,
    required this.phoneNumber,
    required this.address,
    required this.building,
    required this.deliveryDate,
    required this.userId,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  List<String> savedCards = [];
  String? selectedCard;
  bool isLoading = false;
  bool isPaymentSuccessful = false;

  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();
  final TextEditingController expiryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedCards();
  }

  Future<void> _loadSavedCards() async {
    final cards = await DatabaseHelper.instance.fetchSavedCards();
    setState(() {
      savedCards = cards;
    });
  }

  Future<void> _processOrder() async {
    if (selectedCard == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Выберите карту для оплаты")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      isLoading = false;
      isPaymentSuccessful = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    await DatabaseHelper.instance.createOrderFromCart({
      'userId': widget.userId,
      'phoneNumber': widget.phoneNumber,
      'address': widget.address,
      'building': widget.building,
      'deliveryDate': widget.deliveryDate.toIso8601String(),
      'status': 'Processing', // Статус заказа
      'paymentCard': selectedCard, // Выбранная карта
    }, widget.userId);



    await DatabaseHelper.instance.clearCart(widget.userId);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => OrderHistoryScreen(userId: widget.userId),
      ),
          (route) => false,
    );
  }

  void _addNewCard() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[850],
        title: const Text("Добавить карту", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCardField(cardNumberController, "Номер карты", "XXXX-XXXX-XXXX-XXXX", [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(19),
              CardNumberFormatter(),
            ]),
            const SizedBox(height: 8),
            _buildCardField(cvvController, "CVV", "XXX", [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(3),
            ]),
            const SizedBox(height: 8),
            _buildCardField(expiryController, "Срок действия", "MM/YY", [
              LengthLimitingTextInputFormatter(5),
              ExpiryDateFormatter(),
            ]),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Отмена", style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () async {
              final newCard = cardNumberController.text;
              if (newCard.isNotEmpty) {
                await DatabaseHelper.instance.addCard(newCard);
                _loadSavedCards();
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[700]),
            child: const Text("Добавить", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildCardField(TextEditingController controller, String label, String hint, List<TextInputFormatter> inputFormatters) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white70),
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white70),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
      style: const TextStyle(color: Colors.white),
      inputFormatters: inputFormatters,
      keyboardType: TextInputType.number,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Оплата", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: Colors.grey[900],
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 6.0,
          ),
        )
            : isPaymentSuccessful
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.check_circle, color: Colors.green, size: 120),
              SizedBox(height: 16),
              Text(
                "Оплата прошла успешно!",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ],
          ),
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Сохранённые карты", style: TextStyle(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 16),
            Expanded(
              child: savedCards.isEmpty
                  ? const Center(
                child: Text("Нет доступных карт", style: TextStyle(color: Colors.white)),
              )
                  : ListView.builder(
                itemCount: savedCards.length,
                itemBuilder: (context, index) {
                  final cardNumber = savedCards[index];
                  final lastFourDigits = cardNumber.substring(cardNumber.length - 4);

                  return Card(
                    color: Colors.grey[800],
                    child: ListTile(
                      title: Text(
                        "**** **** **** $lastFourDigits",
                        style: const TextStyle(color: Colors.white),
                      ),
                      leading: const Icon(Icons.credit_card, color: Colors.white),
                      onTap: () {
                        setState(() {
                          selectedCard = savedCards[index];
                        });
                      },
                      selected: savedCards[index] == selectedCard,
                      selectedTileColor: Colors.grey[700],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addNewCard,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800]),
              child: const Text("Добавить новую карту", style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _processOrder,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800]),
              child: const Text("Оплатить", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text.replaceAll("-", "").replaceAll(" ", "");

    if (newText.length > 16) {
      newText = newText.substring(0, 16);
    }

    final buffer = StringBuffer();
    for (int i = 0; i < newText.length; i++) {
      buffer.write(newText[i]);
      if ((i + 1) % 4 == 0 && i + 1 != newText.length) {
        buffer.write("-");
      }
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.toString().length),
    );
  }
}

class ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text.replaceAll("/", "");
    if (newText.length > 4) newText = newText.substring(0, 4);
    final buffer = StringBuffer();
    for (int i = 0; i < newText.length; i++) {
      buffer.write(newText[i]);
      if (i == 1 && i + 1 != newText.length) {
        buffer.write("/");
      }
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.toString().length),
    );
  }
}
