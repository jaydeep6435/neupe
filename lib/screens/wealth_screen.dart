import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../utils/colors.dart';
import '../widgets/action_icon.dart';
import '../widgets/section_header.dart';

class WealthScreen extends StatelessWidget {
  const WealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'Wealth Management',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildPortfolioCard(),
            const SizedBox(height: 10),
            _buildInvestmentCategories(),
            const SizedBox(height: 10),
            _buildTopPicks(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPortfolioCard() {
    return Container(
      color: AppColors.primary,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My Portfolio',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          const Text(
            '₹ 1,25,000',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              Icon(Icons.arrow_upward, color: AppColors.green, size: 16),
              SizedBox(width: 4),
              Text(
                '₹ 5,000 (4.2%)',
                style: TextStyle(color: AppColors.green, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 8),
              Text(
                '1 Day Returns',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInvestmentCategories() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          SectionHeader(title: 'Investment Ideas', onViewAll: () {}),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const ActionIcon(
                icon: FontAwesomeIcons.coins,
                label: 'Gold',
                backgroundColor: Colors.transparent,
                iconColor: Color(0xFFFFD700),
              ),
              const ActionIcon(
                icon: FontAwesomeIcons.chartLine,
                label: 'Top\nCompanies',
                backgroundColor: Colors.transparent,
                iconColor: AppColors.primary,
              ),
              const ActionIcon(
                icon: FontAwesomeIcons.piggyBank,
                label: 'Tax\nSaving',
                backgroundColor: Colors.transparent,
                iconColor: AppColors.primary,
              ),
              const ActionIcon(
                icon: FontAwesomeIcons.handHoldingDollar,
                label: 'Start\nSIP',
                backgroundColor: Colors.transparent,
                iconColor: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopPicks() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trending Funds',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildFundItem('HDFC Top 100 Fund', '24.5%', 'Very High Risk'),
          const Divider(),
          _buildFundItem('SBI Small Cap Fund', '32.1%', 'High Risk'),
          const Divider(),
          _buildFundItem('Axis Bluechip Fund', '18.2%', 'Moderate Risk'),
        ],
      ),
    );
  }

  Widget _buildFundItem(String name, String returnRate, String risk) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                risk,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                returnRate,
                style: const TextStyle(
                  color: AppColors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const Text(
                '3Y Returns',
                style: TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
