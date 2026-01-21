import 'package:flutter/material.dart';
import '../../models/transaction_model.dart';
import '../../utils/colors.dart';
import '../../utils/page_transitions.dart';
import '../../widgets/section_header.dart';
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

  String _extractDisplayName(TransactionModel txn) {
    final t = txn.title.trim();
    final lower = t.toLowerCase();

    const paidPrefix = 'paid to ';
    if (lower.startsWith(paidPrefix)) {
      final name = t.substring(paidPrefix.length).trim();
      return name.isEmpty ? 'User' : name;
    }

    const receivedPrefix = 'received from ';
    if (lower.startsWith(receivedPrefix)) {
      final name = t.substring(receivedPrefix.length).trim();
      return name.isEmpty ? 'User' : name;
    }

    return t.isEmpty ? 'User' : t;
  }

  @override
  Widget build(BuildContext context) {
    // Group transactions by contact name (best effort based on title)
    final contactMap = <String, Map<String, dynamic>>{};
    for (final txn in transactions) {
      final fullName = _extractDisplayName(txn);
      final key = fullName.trim().toLowerCase();
      contactMap.putIfAbsent(key, () => {
        'phone': '',
        'name': fullName,
        'transactions': <TransactionModel>[],
      });
      (contactMap[key]!['transactions'] as List<TransactionModel>).add(txn);
    }

    final recentContacts = contactMap.values.toList();

    if (recentContacts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.primary.withOpacity(0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Recent Contacts',
              onViewAll: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ContactSelectionScreen(),
                  ),
                );
              },
            ),
            SizedBox(
              height: 132,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: recentContacts.length,
                itemBuilder: (context, index) {
                  final contact = recentContacts[index];
                  final fullName = (contact['name'] as String);
                  final first = fullName.trim().isEmpty
                      ? 'User'
                      : fullName.trim().split(' ').first;
                  final initial = first.isNotEmpty ? first[0].toUpperCase() : '?';
                  final txnList = (contact['transactions'] as List<TransactionModel>);
                  final heroTag = 'contactHero:${fullName.trim().toLowerCase()}';

                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _RecentContactTile(
                      name: first,
                      initial: initial,
                      colorSeed: fullName,
                      heroTag: heroTag,
                      activityCount: txnList.length,
                      onTap: () {
                        Navigator.push(
                          context,
                          smoothFadeScaleRoute(
                            (context) => TransactionChatScreen(
                              contactName: fullName,
                              contactPhone: contact['phone'] as String,
                              transactions: txnList,
                            ),
                            contentFadeInStart: 0.42,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentContactTile extends StatelessWidget {
  final String name;
  final String initial;
  final String colorSeed;
  final String heroTag;
  final int activityCount;
  final VoidCallback onTap;

  const _RecentContactTile({
    required this.name,
    required this.initial,
    required this.colorSeed,
    required this.heroTag,
    required this.activityCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final avatarColor = (colorSeed.hashCode % 2 == 0) ? AppColors.primary : AppColors.secondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          width: 108,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withOpacity(0.08)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Hero(
                      tag: heroTag,
                      child: Material(
                        type: MaterialType.transparency,
                        child: Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: avatarColor,
                          ),
                          child: Center(
                            child: Text(
                              initial,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (activityCount > 0)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: avatarColor,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Text(
                            activityCount > 99 ? '99+' : activityCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
