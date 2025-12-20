import 'package:flutter/material.dart';
import '../../models/transaction_model.dart';
import '../../utils/colors.dart';
import 'contact_selection_screen.dart';
import 'transaction_chat_screen.dart';

/// Widget that shows recent transaction contacts (people user has transacted with).
/// Tapping a contact opens their transaction history.
/// If no recent contacts, shows "Send to new contact" button.
class RecentContactsSection extends StatelessWidget {
  final List<TransactionModel> transactions;

  const RecentContactsSection({
    required this.transactions,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Group transactions by receiver phone and name
    final contactMap = <String, Map<String, dynamic>>{};
    for (final txn in transactions) {
      // For simplicity, use phone as key; in a real app, fetch contact name from DB
      final phone = txn.id; // or extract from transaction
      contactMap.putIfAbsent(phone, () => {
        'phone': phone,
        'name': 'User', // placeholder; should be fetched from receiver's profile
        'transactions': <TransactionModel>[],
      });
      (contactMap[phone]!['transactions'] as List<TransactionModel>).add(txn);
    }

    final recentContacts = contactMap.values.toList();

    if (recentContacts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Contacts',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ContactSelectionScreen(),
                    ),
                  );
                },
                child: const Text(
                  'See All',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: recentContacts.length,
            itemBuilder: (context, index) {
              final contact = recentContacts[index];
              final name = (contact['name'] as String).split(' ').first;
              final txnList = (contact['transactions'] as List<TransactionModel>);
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TransactionChatScreen(
                        contactName: contact['name'] as String,
                        contactPhone: contact['phone'] as String,
                        transactions: txnList,
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
