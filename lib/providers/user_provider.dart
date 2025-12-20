import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction_model.dart';
import '../services/supabase_service.dart';

class UserProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  // Hardcoded User ID for demo purposes
  final String _userId = 'user_123'; 
  
  double _walletBalance = 500.0;
  double _bankBalance = 0.0;
  List<TransactionModel> _transactions = [];
  bool _isLoading = true;

  double get walletBalance => _walletBalance;
  double get bankBalance => _bankBalance;
  List<TransactionModel> get transactions => List.unmodifiable(_transactions);
  bool get isLoading => _isLoading;

  UserProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();

    _bankBalance = await _supabaseService.getBalance(_userId);
    _transactions = await _supabaseService.getTransactions(_userId);
    
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> makePayment(double amount, String receiverName) async {
    if (_bankBalance >= amount) {
      final newBalance = _bankBalance - amount;
      
      final transaction = TransactionModel(
        id: const Uuid().v4(),
        title: 'Paid to $receiverName',
        subtitle: 'Debited from Bank Account',
        amount: amount,
        date: DateTime.now(),
        type: TransactionType.debit,
        status: TransactionStatus.success,
      );
      
      // Optimistic update
      _bankBalance = newBalance;
      _transactions.insert(0, transaction);
      notifyListeners();

      try {
        await _supabaseService.updateBalance(_userId, newBalance);
        await _supabaseService.addTransaction(transaction, _userId);
        return true;
      } catch (e) {
        // Revert on failure
        _bankBalance += amount;
        _transactions.removeAt(0);
        notifyListeners();
        return false;
      }
    }
    return false;
  }

  void receiveMoney(double amount, String senderName) {
    // Implement similar logic for receiving if needed
  }
}
