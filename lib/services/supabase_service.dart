import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/transaction_model.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<double> getBalance(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select('bank_balance')
          .eq('id', userId)
          .single();
      
      return (response['bank_balance'] as num).toDouble();
    } catch (e) {
      // If user doesn't exist, return default
      return 25000.0;
    }
  }

  Future<void> updateBalance(String userId, double newBalance) async {
    await _client.from('profiles').upsert({
      'id': userId,
      'bank_balance': newBalance,
    });
  }

  Future<void> addTransaction(TransactionModel transaction, String userId) async {
    await _client.from('transactions').insert({
      'user_id': userId,
      'title': transaction.title,
      'subtitle': transaction.subtitle,
      'amount': transaction.amount,
      'type': transaction.type == TransactionType.credit ? 'credit' : 'debit',
      'created_at': transaction.date.toIso8601String(),
    });
  }

  Future<List<TransactionModel>> getTransactions(String userId) async {
    final response = await _client
        .from('transactions')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List).map((data) {
      return TransactionModel(
        id: data['id'].toString(),
        title: data['title'],
        subtitle: data['subtitle'],
        amount: (data['amount'] as num).toDouble(),
        date: DateTime.parse(data['created_at']),
        type: data['type'] == 'credit' ? TransactionType.credit : TransactionType.debit,
        status: TransactionStatus.success,
      );
    }).toList();
  }
}
