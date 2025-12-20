import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import 'amount_entry_screen.dart';

class ContactSelectionScreen extends StatelessWidget {
  const ContactSelectionScreen({super.key});

  final List<Map<String, String>> contacts = const [
    {'name': 'Rahul Sharma', 'phone': '9876543210'},
    {'name': 'Priya Singh', 'phone': '9876543211'},
    {'name': 'Amit Patel', 'phone': '9876543212'},
    {'name': 'Sneha Gupta', 'phone': '9876543213'},
    {'name': 'Vikram Malhotra', 'phone': '9876543214'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Contact'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final contact = contacts[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary,
              child: Text(
                contact['name']![0],
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(contact['name']!),
            subtitle: Text(contact['phone']!),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AmountEntryScreen(
                    receiverName: contact['name']!,
                    receiverPhone: contact['phone']!,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
