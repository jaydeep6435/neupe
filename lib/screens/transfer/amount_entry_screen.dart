import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../../providers/user_provider.dart';
import 'payment_success_screen.dart';

class AmountEntryScreen extends StatefulWidget {
  final String receiverName;
  final String receiverPhone;

  const AmountEntryScreen({
    super.key,
    required this.receiverName,
    required this.receiverPhone,
  });

  @override
  State<AmountEntryScreen> createState() => _AmountEntryScreenState();
}

class _AmountEntryScreenState extends State<AmountEntryScreen> {
  final TextEditingController _amountController = TextEditingController();

  void _initiatePayment() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.bankBalance < amount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insufficient Bank Balance')),
      );
      return;
    }

    // Simulate PIN entry and processing
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _buildPinPad(amount),
    );
  }

  Widget _buildPinPad(double amount) {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'Enter UPI PIN',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          const TextField(
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 4,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, letterSpacing: 10),
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              counterText: '',
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                Navigator.pop(context); // Close PIN pad
                _processPayment(amount);
              },
              child: const Text('SUBMIT', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  void _processPayment(double amount) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    await Future.delayed(const Duration(seconds: 2)); // Simulate network

    if (mounted) {
      Navigator.pop(context); // Close loading
      final success = await Provider.of<UserProvider>(context, listen: false)
          .makePayment(amount, widget.receiverName);

      if (success && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentSuccessScreen(
              amount: amount,
              receiverName: widget.receiverName,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.receiverName, style: const TextStyle(fontSize: 16)),
            Text(widget.receiverPhone, style: const TextStyle(fontSize: 12)),
          ],
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('To: ${widget.receiverName}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('Banking Name: ${widget.receiverName.toUpperCase()}'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                prefixText: '₹ ',
                hintText: '0',
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 10),
            const Text('Debited from Bank Account'),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _initiatePayment,
                child: const Text('PAY', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
