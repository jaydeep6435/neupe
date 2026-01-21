import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../utils/colors.dart';
import '../utils/page_transitions.dart';
import 'home_screen.dart';
import 'wealth_screen.dart';
import 'history_screen.dart';
import 'qr_scanner_screen.dart';
import '../widgets/scan_hero_icon.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  late final AnimationController _scanFloatController;
  late final Animation<double> _scanFloatY;
  late final Animation<double> _scanFloatScale;

  final List<Widget> _screens = [
    const HomeScreen(),
    const Center(child: Text('Stores')), // Placeholder
    const SizedBox.shrink(), // Scanner opens as a modal page.
    const WealthScreen(),
    const HistoryScreen(),
  ];

  @override
  void initState() {
    super.initState();

    // Very small, premium “floating” motion for the Scan button.
    _scanFloatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    final curved = CurvedAnimation(parent: _scanFloatController, curve: Curves.easeInOut);
    _scanFloatY = Tween<double>(begin: 0.0, end: -3.0).animate(curved);
    _scanFloatScale = Tween<double>(begin: 1.0, end: 1.03).animate(curved);
  }

  @override
  void dispose() {
    _scanFloatController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    // Middle button = QR Scanner. Keep current tab selected.
    if (index == 2) {
      _scanFloatController.stop();
      Navigator.of(context)
          .push(
            colorfulScanRoute(
              (context) => const QRScannerScreen(),
            ),
          )
          .whenComplete(() {
            if (mounted) {
              _scanFloatController.repeat(reverse: true);
            }
          });
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.secondary],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 18,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white.withOpacity(0.75),
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: [
              const BottomNavigationBarItem(
                icon: FaIcon(FontAwesomeIcons.house),
                label: 'Home',
              ),
              const BottomNavigationBarItem(
                icon: FaIcon(FontAwesomeIcons.store),
                label: 'Stores',
              ),
              BottomNavigationBarItem(
                icon: AnimatedBuilder(
                  animation: _scanFloatController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _scanFloatY.value),
                      child: Transform.scale(
                        scale: _scanFloatScale.value,
                        child: child,
                      ),
                    );
                  },
                  child: Hero(
                    tag: kScanHeroTag,
                    child: const ScanHeroIcon(size: 52),
                  ),
                ),
                label: 'Scan',
              ),
              const BottomNavigationBarItem(
                icon: FaIcon(FontAwesomeIcons.rupeeSign),
                label: 'Wealth',
              ),
              const BottomNavigationBarItem(
                icon: FaIcon(FontAwesomeIcons.clockRotateLeft),
                label: 'History',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
