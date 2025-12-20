import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import '../utils/colors.dart';
import '../widgets/action_icon.dart';
import '../widgets/section_header.dart';
import 'transfer/contact_selection_screen.dart';
import '../providers/user_provider.dart';
import 'qr_scanner_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMoneyTransferSection(context),
            _buildUPIIdSection(),
            const SizedBox(height: 10),
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
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: const Icon(Icons.person, color: AppColors.primary),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Add Address',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            'Bangalore, Karnataka',
            style: TextStyle(fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const QRScannerScreen()),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.help_outline, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildMoneyTransferSection(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Transfer Money',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ActionIcon(
                icon: Icons.person_outline,
                label: 'To Mobile\nNumber',
                backgroundColor: AppColors.primary,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ContactSelectionScreen(),
                    ),
                  );
                },
              ),
              const ActionIcon(
                icon: Icons.account_balance,
                label: 'To Bank/\nUPI ID',
                backgroundColor: AppColors.primary,
              ),
              const ActionIcon(
                icon: Icons.refresh,
                label: 'To Self\nAccount',
                backgroundColor: AppColors.primary,
              ),
              ActionIcon(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Check\nBalance',
                backgroundColor: AppColors.primary,
                onTap: () {
                  final balance = Provider.of<UserProvider>(context, listen: false).bankBalance;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Bank Balance: ₹ $balance')),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUPIIdSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFe8f0fe),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        children: [
          const Text(
            'UPI ID: 9876543210@ybl',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          const Icon(Icons.copy, size: 16, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildRechargeSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          SectionHeader(title: 'Recharge & Pay Bills', onViewAll: () {}),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const ActionIcon(
                icon: Icons.phone_android,
                label: 'Mobile\nRecharge',
                backgroundColor: Colors.transparent,
                iconColor: AppColors.primary,
              ),
              const ActionIcon(
                icon: Icons.satellite_alt,
                label: 'DTH',
                backgroundColor: Colors.transparent,
                iconColor: AppColors.primary,
              ),
              const ActionIcon(
                icon: Icons.lightbulb_outline,
                label: 'Electricity',
                backgroundColor: Colors.transparent,
                iconColor: AppColors.primary,
              ),
              const ActionIcon(
                icon: Icons.credit_card,
                label: 'Credit Card\nBill',
                backgroundColor: Colors.transparent,
                iconColor: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const ActionIcon(
                icon: FontAwesomeIcons.houseUser,
                label: 'Rent\nPayment',
                backgroundColor: Colors.transparent,
                iconColor: AppColors.primary,
              ),
              const ActionIcon(
                icon: Icons.local_gas_station,
                label: 'Loan\nRepayment',
                backgroundColor: Colors.transparent,
                iconColor: AppColors.primary,
              ),
              const ActionIcon(
                icon: Icons.school_outlined,
                label: 'Education\nFees',
                backgroundColor: Colors.transparent,
                iconColor: AppColors.primary,
              ),
              const ActionIcon(
                icon: Icons.arrow_forward_ios,
                label: 'See All',
                backgroundColor: AppColors.primary,
                iconColor: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSponsoredLinks() {
    final List<String> banners = [
      'https://via.placeholder.com/600x150/5f259f/ffffff?text=PhonePe+Offer+1',
      'https://via.placeholder.com/600x150/00baf2/ffffff?text=PhonePe+Offer+2',
      'https://via.placeholder.com/600x150/00b050/ffffff?text=PhonePe+Offer+3',
    ];

    return Container(
      color: Colors.white,
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
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    i,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade300,
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
    );
  }

  Widget _buildInsuranceSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          SectionHeader(title: 'Insurance', onViewAll: () {}),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const ActionIcon(
                icon: FontAwesomeIcons.motorcycle,
                label: 'Bike',
                backgroundColor: Colors.transparent,
                iconColor: AppColors.primary,
              ),
              const ActionIcon(
                icon: FontAwesomeIcons.car,
                label: 'Car',
                backgroundColor: Colors.transparent,
                iconColor: AppColors.primary,
              ),
              const ActionIcon(
                icon: FontAwesomeIcons.heartPulse,
                label: 'Health',
                backgroundColor: Colors.transparent,
                iconColor: AppColors.primary,
              ),
              const ActionIcon(
                icon: FontAwesomeIcons.personWalking,
                label: 'Accident',
                backgroundColor: Colors.transparent,
                iconColor: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
