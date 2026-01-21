import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../services/supabase_service.dart';
import '../utils/page_transitions.dart';
import 'profile/set_upi_pin_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final SupabaseService _supabaseService;
  Future<UserProfile>? _profileFuture;

  static const _bgTop = Color(0xFF050816);
  static const _card = Color(0xFF13162B);
  static const _card2 = Color(0xFF1E2142);

  @override
  void initState() {
    super.initState();
    _supabaseService = SupabaseService();
  }

  void _loadProfile() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.userId;
    if (userId == null) {
      setState(() {
        _profileFuture = Future.error('Not logged in');
      });
      return;
    }
    setState(() {
      _profileFuture = _supabaseService.getUserProfile(
        userId,
        loginMobile: auth.mobile,
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_profileFuture == null) {
      _loadProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgTop,
      appBar: AppBar(
        backgroundColor: _bgTop,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Profile & Settings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: 0.2,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.7, -0.8),
            radius: 1.1,
            colors: [Color(0x1A7C4DFF), Color(0x00050816)],
          ),
        ),
        child: FutureBuilder<UserProfile>(
          future: _profileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError && !snapshot.hasData) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Something went wrong',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _loadProfile,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (!snapshot.hasData) {
              return const Center(
                child: Text(
                  'No profile data available',
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }

            final profile = snapshot.data!;
            final upiUrl =
                'upi://pay?pa=${Uri.encodeComponent(profile.upiId)}&pn=${Uri.encodeComponent(profile.name)}';

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeaderSection(profile, upiUrl),
                  const SizedBox(height: 16),
                  _buildSecurityCard(),
                  const SizedBox(height: 16),
                  _buildSettingsList(),
                  const SizedBox(height: 24),
                  _buildLogoutButton(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderSection(UserProfile profile, String upiUrl) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(18)),
        color: _card,
        border: Border.all(color: Colors.white.withOpacity(0.06)),
        gradient: const LinearGradient(
          colors: [Color(0xFF13162B), Color(0xFF0B0F22)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: Colors.white.withOpacity(0.10),
                child: Text(
                  profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (profile.mobile.isNotEmpty)
                      Text(
                        '+91 ${profile.mobile}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _card2,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your QR',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Scan to pay instantly',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: const Color(0xFF0B0F22),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(18),
                            ),
                          ),
                          builder: (ctx) {
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                16,
                                16,
                                24,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    height: 4,
                                    width: 44,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.18),
                                      borderRadius: BorderRadius.circular(99),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  const Text(
                                    'Your QR',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: QrImageView(
                                      data: upiUrl,
                                      size: 260,
                                      backgroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: const Text(
                        'EXPAND',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: QrImageView(
                      data: upiUrl,
                      size: 200,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityCard() {
    final hasUpiPin =
        Provider.of<UserProvider?>(context, listen: true)?.hasUpiPin ?? false;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: _card,
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _card2,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: const Icon(Icons.security, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Security',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasUpiPin ? 'UPI PIN is set' : 'UPI PIN not set',
                  style: TextStyle(
                    color: hasUpiPin ? Colors.white70 : Colors.white60,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                smoothFadeSlideRoute(
                  (context) => const SetUpiPinScreen(),
                ),
              );
            },
            child: Text(
              hasUpiPin ? 'CHANGE' : 'SET',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsList() {
    final hasUpiPin =
        Provider.of<UserProvider?>(context, listen: true)?.hasUpiPin ?? false;
    final items = [
      _SettingsItem(
        icon: Icons.password,
        title: hasUpiPin ? 'Change UPI PIN' : 'Set UPI PIN',
        subtitle: hasUpiPin
            ? 'Update your UPI PIN'
            : 'Create a UPI PIN for payments',
        onTap: () {
          Navigator.push(
            context,
            smoothFadeSlideRoute(
              (context) => const SetUpiPinScreen(),
            ),
          );
        },
      ),
      const _SettingsItem(
        icon: Icons.tune,
        title: 'Preferences',
        subtitle: 'Language, alerts & more',
      ),
      const _SettingsItem(
        icon: Icons.security,
        title: 'Security',
        subtitle: 'Screen lock, privacy & more',
      ),
      const _SettingsItem(
        icon: Icons.card_giftcard,
        title: 'Refer & Get',
        subtitle: 'Invite friends and earn rewards',
      ),
      const _SettingsItem(
        icon: Icons.help_outline,
        title: 'Help & Support',
        subtitle: 'FAQs, chat with us',
      ),
      const _SettingsItem(
        icon: Icons.info_outline,
        title: 'About',
        subtitle: 'App info, terms & privacy',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: _card,
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++)
            Column(
              children: [
                _buildSettingsTile(items[i]),
                if (i != items.length - 1)
                  const Divider(
                    height: 1,
                    color: Color(0xFF252849),
                    indent: 56,
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(_SettingsItem item) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _card2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Icon(item.icon, color: Colors.white, size: 22),
      ),
      title: Text(
        item.title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14.5,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        item.subtitle,
        style: const TextStyle(color: Colors.white60, fontSize: 12),
      ),
      trailing: item.onTap == null
          ? null
          : const Icon(Icons.chevron_right, color: Colors.white54),
      onTap: item.onTap,
    );
  }

  Widget _buildLogoutButton() {
    return InkWell(
      onTap: () {
        final auth = Provider.of<AuthProvider>(context, listen: false);
        auth.logout();
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withOpacity(0.04),
          border: Border.all(color: Colors.redAccent.withOpacity(0.30)),
        ),
        child: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.14),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.redAccent.withOpacity(0.28)),
              ),
              child: const Icon(Icons.logout, color: Colors.redAccent),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Logout',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.redAccent.withOpacity(0.9)),
          ],
        ),
      ),
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });
}
