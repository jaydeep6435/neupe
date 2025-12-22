import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  static const _keyUserId = 'auth_user_id';
  static const _keyMobile = 'auth_mobile';

  String? _userId;
  String? _mobile;
  bool _isInitialized = false;

  AuthProvider() {
    _loadFromPrefs();
  }

  String? get userId => _userId;
  String? get mobile => _mobile;
  bool get isLoggedIn => _userId != null;
  bool get isInitialized => _isInitialized;

  void setUser(String id, {String? mobile}) {
    _userId = id;
    _mobile = mobile;
    notifyListeners();
    _saveToPrefs();
  }

  void logout() {
    _userId = null;
    _mobile = null;
    notifyListeners();
    _clearPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString(_keyUserId);
    _mobile = prefs.getString(_keyMobile);
    // If we have an old saved session without a mobile number,
    // force a fresh login so we can correctly derive UPI from mobile.
    if (_userId != null && (_mobile == null || _mobile!.isEmpty)) {
      _userId = null;
    }
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (_userId != null) {
      await prefs.setString(_keyUserId, _userId!);
    }
    if (_mobile != null) {
      await prefs.setString(_keyMobile, _mobile!);
    }
  }

  Future<void> _clearPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyMobile);
  }
}
