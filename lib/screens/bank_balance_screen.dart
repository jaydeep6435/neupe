import 'package:flutter/material.dart';

import '../utils/colors.dart';

class BankBalanceScreen extends StatefulWidget {
  final double balance;

  const BankBalanceScreen({super.key, required this.balance});

  @override
  State<BankBalanceScreen> createState() => _BankBalanceScreenState();
}

class _BankBalanceScreenState extends State<BankBalanceScreen> {
  Offset _dragOffset = Offset.zero;
  DateTime _asOf = DateTime.now();
  int _animSeed = 0;

  void _refresh() {
    setState(() {
      _asOf = DateTime.now();
      _animSeed++;
      _dragOffset = Offset.zero;
    });
  }

  String _formatAsOf(DateTime t) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(t.hour)}:${two(t.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final balance = widget.balance;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Bank balance'),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: AppColors.background,
              ),
            ),
            Positioned(
              top: -90,
              right: -70,
              child: _BgBlob(size: 220, opacity: 0.10),
            ),
            Positioned(
              top: 120,
              left: -90,
              child: _BgBlob(size: 240, opacity: 0.08),
            ),
            Positioned(
              bottom: -110,
              right: -80,
              child: _BgBlob(size: 280, opacity: 0.08),
            ),
            Column(
              children: [
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Updated ${_formatAsOf(_asOf)}',
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _refresh,
                        child: const Text(
                          'REFRESH',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: GestureDetector(
                          onPanUpdate: (details) {
                            setState(() {
                              _dragOffset += details.delta;
                              _dragOffset = Offset(
                                _dragOffset.dx.clamp(-22, 22),
                                _dragOffset.dy.clamp(-22, 22),
                              );
                            });
                          },
                          onPanEnd: (_) => setState(() => _dragOffset = Offset.zero),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeOut,
                            transform: Matrix4.identity()..translate(_dragOffset.dx, _dragOffset.dy),
                            padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(26),
                              border: Border.all(color: AppColors.primary.withOpacity(0.10)),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _BalancePulse(
                                  key: ValueKey('pulse_$_animSeed'),
                                ),
                                const SizedBox(height: 14),
                                const Text(
                                  'Bank balance',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TweenAnimationBuilder<double>(
                                  key: ValueKey('amount_$_animSeed'),
                                  tween: Tween<double>(begin: 0, end: balance),
                                  duration: const Duration(milliseconds: 900),
                                  curve: Curves.easeOutCubic,
                                  builder: (context, value, _) {
                                    final text = '₹${value.toStringAsFixed(2)}';
                                    return Text(
                                      text,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 38,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.06),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: const Text(
                                    'Available balance',
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Tip: drag this card',
                                  style: TextStyle(
                                    color: Colors.black.withOpacity(0.35),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'DONE',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BgBlob extends StatelessWidget {
  final double size;
  final double opacity;

  const _BgBlob({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(opacity),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _BalancePulse extends StatefulWidget {
  const _BalancePulse({super.key});

  @override
  State<_BalancePulse> createState() => _BalancePulseState();
}

class _BalancePulseState extends State<_BalancePulse> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(_controller.value);
        final ringOpacity = 0.20 + (0.18 * t);
        final ringSize = 70 + (10 * t);
        return SizedBox(
          height: 84,
          width: 84,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: ringSize,
                height: ringSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withOpacity(ringOpacity),
                    width: 2,
                  ),
                ),
              ),
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
