import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/transaction_model.dart';

class UserProfile {
  final String name;
  final String mobile;
  final String upiId;

  UserProfile({
    required this.name,
    required this.mobile,
    required this.upiId,
  });
}

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
    try {
      final response = await _client
          .from('transactions')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final rawList = response as List;
      return rawList.map((data) {
        final createdAt = data['created_at'];
        DateTime parsedDate;
        if (createdAt is String) {
          parsedDate = DateTime.tryParse(createdAt) ?? DateTime.now();
        } else if (createdAt is DateTime) {
          parsedDate = createdAt;
        } else {
          parsedDate = DateTime.now();
        }

        return TransactionModel(
          id: data['id'].toString(),
          title: data['title'] ?? '',
          subtitle: data['subtitle'] ?? '',
          amount: (data['amount'] as num).toDouble(),
          date: parsedDate,
          type: data['type'] == 'credit' ? TransactionType.credit : TransactionType.debit,
          status: TransactionStatus.success,
        );
      }).toList();
    } catch (e, stack) {
      // Log and return an empty list so the UI can show a graceful
      // "No transactions yet" state instead of getting stuck.
      // You can inspect these logs in the debug console.
      // ignore: avoid_print
      print('Error fetching transactions: $e');
      // ignore: avoid_print
      print(stack);
      return [];
    }
  }

  Future<UserProfile> getUserProfile(
    String userId, {
    String? loginMobile,
  }) async {
    try {
      final data = await _client.from('app_users').select('mobile, upi_id').eq('id', userId).maybeSingle();
      // Also fetch the profiles row (may contain full name or display name)
      final profile = await _client.from('profiles').select('*').eq('id', userId).maybeSingle();

      // Prefer the mobile number the user just logged in with, if available.
      final dynamic rawMobileFromDb = data?['mobile'];
      final dbMobile = rawMobileFromDb == null ? '' : rawMobileFromDb.toString();
      final mobile =
          (loginMobile != null && loginMobile.isNotEmpty) ? loginMobile : dbMobile;
      // Determine a reasonable display name from profiles or app_users if available
      String name = '';
      if (profile != null) {
        name = (profile['full_name'] ?? profile['name'] ?? profile['display_name'] ?? '') as String;
      }
      // fallback to app_users 'name' if it ever exists
      if (name.isEmpty) {
        name = (data?['name'] ?? '') as String;
      }

      var upiId = (data?['upi_id'] ?? '') as String;

      const suffix = '@axl';

      if (mobile.isNotEmpty) {
        // Always derive UPI directly from the mobile number.
        final desiredUpi = '$mobile$suffix';
        upiId = desiredUpi;

        // Ensure the database row is updated/created with the latest mobile
        // and UPI ID so future sessions stay consistent.
        if (data != null) {
          await _client
              .from('app_users')
              .update({
                'mobile': mobile,
                'upi_id': upiId,
              })
              .eq('id', userId);
        } else {
          await _client.from('app_users').insert({
            'id': userId,
            'mobile': mobile,
            'upi_id': upiId,
          });
        }
      } else if (upiId.isEmpty) {
        // No mobile available and no stored UPI: fall back to a stable prefix.
        final base = userId.isNotEmpty && userId.length >= 8
            ? userId.substring(0, 8)
            : 'user';
        upiId = '$base$suffix';
        if (data != null) {
          await _client
              .from('app_users')
              .update({'upi_id': upiId})
              .eq('id', userId);
        }
      }

      return UserProfile(
        name: name.isEmpty ? 'User' : name,
        mobile: mobile,
        upiId: upiId,
      );
    } catch (e, stack) {
      // Fallback profile so UI never completely fails.
      // ignore: avoid_print
      print('Error loading profile for $userId: $e');
      // ignore: avoid_print
      print(stack);
      const suffix = '@axl';
      final mobileFallback =
          (loginMobile != null && loginMobile.isNotEmpty) ? loginMobile : '';
      final base = mobileFallback.isNotEmpty
          ? mobileFallback
          : (userId.isNotEmpty && userId.length >= 8
              ? userId.substring(0, 8)
              : 'user');
      return UserProfile(
        name: 'User',
        mobile: mobileFallback,
        upiId: '$base$suffix',
      );
    }
  }
}
