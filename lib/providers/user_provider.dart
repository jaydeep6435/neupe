import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../models/transaction_model.dart';
import '../services/supabase_service.dart';

class UserProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  final String _userId;
  
  final double _walletBalance = 500.0;
  double _bankBalance = 0.0;
  List<TransactionModel> _transactions = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _upiPinHash;

  double get walletBalance => _walletBalance;
  double get bankBalance => _bankBalance;
  List<TransactionModel> get transactions => List.unmodifiable(_transactions);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasUpiPin => _upiPinHash != null && _upiPinHash!.isNotEmpty;

  UserProvider(this._userId) {
    _loadData();
  }

  Future<void> _loadData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _bankBalance = await _supabaseService.getBalance(_userId);
      _transactions = await _supabaseService.getTransactions(_userId);
      _upiPinHash = await _supabaseService.getUpiPinHash(_userId);
    } catch (e, stack) {
      _transactions = [];
      _errorMessage = 'Failed to load history. Please try again.';
      // ignore: avoid_print
      print('Error loading user data: $e');
      // ignore: avoid_print
      print(stack);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> reload() async {
    await _loadData();
  }

  String _hashUpiPin(String pin) {
    // Salt with userId so identical PINs across users don't share hashes.
    final bytes = utf8.encode('$_userId:$pin');
    return sha256.convert(bytes).toString();
  }

  Future<void> setUpiPin(String pin) async {
    final hash = _hashUpiPin(pin);
    await _supabaseService.setUpiPinHash(_userId, hash);
    _upiPinHash = hash;
    notifyListeners();
  }

  Future<bool> verifyUpiPin(String pin) async {
    // Ensure we have the latest value (covers the case where user set PIN
    // from another screen and came back without restarting).
    _upiPinHash ??= await _supabaseService.getUpiPinHash(_userId);
    if (!hasUpiPin) return false;
    final hash = _hashUpiPin(pin);
    return hash == _upiPinHash;
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
