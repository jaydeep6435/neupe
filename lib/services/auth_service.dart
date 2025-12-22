import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/password_utils.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<String> signUpWithMobile(String mobile, String password) async {
    final hashed = hashPassword(password);

    final existing = await _client
        .from('app_users')
        .select('id')
        .eq('mobile', mobile)
        .maybeSingle();

    if (existing != null) {
      throw Exception('Mobile already registered. Please log in instead.');
    }

    final inserted = await _client
        .from('app_users')
        .insert({
          'mobile': mobile,
          'password_hash': hashed,
        })
        .select('id')
        .single();

    final userId = inserted['id'] as String;

    await _client.from('profiles').insert({'id': userId});

    return userId;
  }

  Future<String> loginWithMobile(String mobile, String password) async {
    final hashed = hashPassword(password);

    final user = await _client
        .from('app_users')
        .select('id, password_hash')
        .eq('mobile', mobile)
        .maybeSingle();

    if (user == null) {
      throw Exception('No account found for this mobile number.');
    }

    if (user['password_hash'] != hashed) {
      throw Exception('Incorrect password.');
    }

    return user['id'] as String;
  }
}
