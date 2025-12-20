import 'package:intl/intl.dart';

enum TransactionType { debit, credit }
enum TransactionStatus { success, failed, pending }

class TransactionModel {
  final String id;
  final String title;
  final String subtitle;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final TransactionStatus status;

  TransactionModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.date,
    required this.type,
    required this.status,
  });

  String get formattedDate {
    return DateFormat('dd MMM yyyy • hh:mm a').format(date);
  }
}
