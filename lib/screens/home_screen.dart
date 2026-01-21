import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import '../utils/colors.dart';
import '../widgets/colorful_action_icon.dart';
import 'transfer/contact_selection_screen.dart';
import 'transfer/upi_pin_sheet.dart';
import 'transfer/recent_contacts_widget.dart';
import '../providers/user_provider.dart';
import '../providers/auth_provider.dart';
import '../services/supabase_service.dart';
import 'bank_balance_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const Color _homeBg = Color(0xFF070A10);
  static const Color _homeCard = Color(0xFF0E1424);
  static const Color _homeCardBorder = Color(0xFF1C2744);
  static const Color _textPrimary = Colors.white;
  static const Color _textSecondary = Color(0xFFB8C3D6);

  Future<void> _openCheckBalance(BuildContext context) async {
    final balance = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return UpiPinSheet(
          receiverName: 'Check balance',
          receiverId: '',
          amount: 0,
          startInBalanceCheck: true,
          showCheckBalanceAction: false,
          showPaymentWarning: false,
          onCancel: () => Navigator.pop(sheetContext),
          onVerified: () {},
        );
      },
    );

    if (balance == null || !context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BankBalanceScreen(balance: balance),
      ),
    );
  }

  Widget _cardSection({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      child: Container(
        decoration: BoxDecoration(
          color: _homeCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _homeCardBorder.withAlpha(153)),
        ),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _homeBg,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopHeader(context),
            _buildMoneyTransferSection(context),
            _buildUPIIdSection(context),
            const SizedBox(height: 10),
            // Recent Contacts Section
            Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                return RecentContactsSection(
                  transactions: userProvider.transactions,
                );
              },
            ),
            _buildRechargeSection(),
            const SizedBox(height: 10),
            _buildSponsoredLinks(),
            const SizedBox(height: 10),
            _buildInsuranceSection(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      toolbarHeight: 0,
      automaticallyImplyLeading: false,
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0B1020), Color(0xFF141A2E)],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF11162A),
            AppColors.primary.withAlpha(235),
            AppColors.secondary.withAlpha(204),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(41),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(36),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withAlpha(89)),
                    ),
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Welcome back',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                    ),
                  ),
                ),
                _miniTopIcon(
                  icon: Icons.notifications_none,
                  onTap: () {},
                ),
                const SizedBox(width: 8),
                _miniTopIcon(
                  icon: Icons.help_outline,
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniTopIcon({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.white.withAlpha(36),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }

  Widget _buildMoneyTransferSection(BuildContext context) {
    return _cardSection(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Transfer Money',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: _textPrimary,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _openCheckBalance(context),
                    child: const Text(
                      'CHECK BALANCE',
                      style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    return ColorfulActionIcon(
                      icon: Icons.person_outline,
                      label: 'To Mobile\nNumber',
                      colors: const [Color(0xFF7C3AED), Color(0xFF06B6D4)],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ContactSelectionScreen(
                              transactions: userProvider.transactions,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                ColorfulActionIcon(
                  icon: Icons.account_balance,
                  label: 'To Bank/\nUPI ID',
                  colors: [Color(0xFF22C55E), Color(0xFF14B8A6)],
                ),
                ColorfulActionIcon(
                  icon: Icons.refresh,
                  label: 'To Self\nAccount',
                  colors: [Color(0xFFF59E0B), Color(0xFFEC4899)],
                ),
                ColorfulActionIcon(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Check\nBalance',
                  colors: const [Color(0xFF0EA5E9), Color(0xFF2563EB)],
                  onTap: () => _openCheckBalance(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUPIIdSection(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.userId;

    if (userId == null) {
      return const SizedBox.shrink();
    }

    final supabaseService = SupabaseService();

    return FutureBuilder<UserProfile>(
      future: supabaseService.getUserProfile(
        userId,
        loginMobile: auth.mobile,
      ),
      builder: (context, snapshot) {
        String label;

        if (snapshot.connectionState == ConnectionState.waiting) {
          label = 'Fetching UPI ID...';
        } else if (snapshot.hasError || !snapshot.hasData) {
          label = 'UPI ID not available';
        } else {
          final profile = snapshot.data!;
          label = 'UPI ID: ${profile.upiId}';
        }

        return _cardSection(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(26),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.verified_user, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (snapshot.hasData && snapshot.data!.upiId.isNotEmpty)
                  IconButton(
                    onPressed: () {
                      final upi = snapshot.data!.upiId;
                      Clipboard.setData(ClipboardData(text: upi));
                    },
                    icon: Icon(Icons.copy, size: 18, color: Colors.white.withAlpha(179)),
                  )
                else
                  Icon(Icons.copy, size: 18, color: Colors.white.withAlpha(64)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _darkSectionHeader(String title, {VoidCallback? onViewAll}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: _textPrimary,
            ),
          ),
          if (onViewAll != null)
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: onViewAll,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(26),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withAlpha(26)),
                ),
                child: const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRechargeSection() {
    return _cardSection(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          children: [
            _darkSectionHeader('Recharge & Pay Bills', onViewAll: () {}),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ColorfulActionIcon(
                  icon: Icons.phone_android,
                  label: 'Mobile\nRecharge',
                  colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
                ),
                ColorfulActionIcon(
                  icon: Icons.satellite_alt,
                  label: 'DTH',
                  colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
                ),
                ColorfulActionIcon(
                  icon: Icons.lightbulb_outline,
                  label: 'Electricity',
                  colors: [Color(0xFFF59E0B), Color(0xFFF97316)],
                ),
                ColorfulActionIcon(
                  icon: Icons.credit_card,
                  label: 'Credit Card\nBill',
                  colors: [Color(0xFF22C55E), Color(0xFF10B981)],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ColorfulActionIcon(
                  icon: FontAwesomeIcons.houseUser,
                  label: 'Rent\nPayment',
                  colors: [Color(0xFFEC4899), Color(0xFF8B5CF6)],
                ),
                ColorfulActionIcon(
                  icon: Icons.local_gas_station,
                  label: 'Loan\nRepayment',
                  colors: [Color(0xFF0EA5E9), Color(0xFF14B8A6)],
                ),
                ColorfulActionIcon(
                  icon: Icons.school_outlined,
                  label: 'Education\nFees',
                  colors: [Color(0xFFF97316), Color(0xFFEF4444)],
                ),
                ColorfulActionIcon(
                  icon: Icons.arrow_forward_ios,
                  label: 'See All',
                  colors: [Color(0xFF334155), Color(0xFF0F172A)],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSponsoredLinks() {
    final List<String> banners = [
      'https://via.placeholder.com/600x150/5f259f/ffffff?text=PhonePe+Offer+1',
      'https://via.placeholder.com/600x150/00baf2/ffffff?text=PhonePe+Offer+2',
      'https://via.placeholder.com/600x150/00b050/ffffff?text=PhonePe+Offer+3',
    ];

    return _cardSection(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: CarouselSlider(
        options: CarouselOptions(
          height: 150.0,
          autoPlay: true,
          enlargeCenterPage: true,
          viewportFraction: 0.9,
          aspectRatio: 16 / 9,
          initialPage: 0,
        ),
        items: banners.map((i) {
          return Builder(
            builder: (BuildContext context) {
              return Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.symmetric(horizontal: 5.0),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withAlpha(20)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    i,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.white.withAlpha(20),
                        child: const Center(
                          child: Icon(Icons.image_not_supported, color: Colors.grey),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    ),
    );
  }

  Widget _buildInsuranceSection() {
    return _cardSection(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          children: [
            _darkSectionHeader('Insurance', onViewAll: () {}),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ColorfulActionIcon(
                  icon: FontAwesomeIcons.motorcycle,
                  label: 'Bike',
                  colors: [Color(0xFF06B6D4), Color(0xFF2563EB)],
                ),
                ColorfulActionIcon(
                  icon: FontAwesomeIcons.car,
                  label: 'Car',
                  colors: [Color(0xFFA855F7), Color(0xFFEC4899)],
                ),
                ColorfulActionIcon(
                  icon: FontAwesomeIcons.heartPulse,
                  label: 'Health',
                  colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
                ),
                ColorfulActionIcon(
                  icon: FontAwesomeIcons.personWalking,
                  label: 'Accident',
                  colors: [Color(0xFFF59E0B), Color(0xFFF97316)],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
