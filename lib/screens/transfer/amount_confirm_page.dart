import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/colors.dart';
import '../../utils/page_transitions.dart';
import 'payment_success_screen.dart';
import 'upi_pin_sheet.dart';

class AmountConfirmPage extends StatefulWidget {
  final String contactName;
  final String contactPhone;
  final String amount;

  const AmountConfirmPage({
    required this.contactName,
    required this.contactPhone,
    required this.amount,
    super.key,
  });

  @override
  State<AmountConfirmPage> createState() => _AmountConfirmPageState();
}

class _AmountConfirmPageState extends State<AmountConfirmPage> {
  bool _payPressed = false;

  void _initiatePayment() async {
    final parsedAmount = double.tryParse(widget.amount);
    if (parsedAmount == null || parsedAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.bankBalance < parsedAmount) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Insufficient Bank Balance')),
        );
        return;
      }

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.92,
            child: UpiPinSheet(
              receiverName: widget.contactName,
              receiverId: widget.contactPhone,
              amount: parsedAmount,
              showCheckBalanceAction: false,
              onCancel: () => Navigator.pop(context),
              onVerified: () {
                Navigator.pop(context);
                // Defer heavy work to next frame so the bottom-sheet close animation stays smooth.
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  _processPayment(parsedAmount);
                });
              },
            ),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _processPayment(double amount) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.pop(context);
      final success = await Provider.of<UserProvider>(context, listen: false)
          .makePayment(amount, widget.contactName);

      if (success && mounted) {
        Navigator.pushReplacement(
          context,
          smoothFadeSlideRoute(
            (context) => PaymentSuccessScreen(
              amount: amount,
              receiverName: widget.contactName,
            ),
            beginOffset: const Offset(0, 0.08),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Confirm Payment'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.75),
            radius: 1.25,
            colors: [
              AppColors.secondary.withOpacity(0.16),
              AppColors.primary.withOpacity(0.10),
              Colors.black,
            ],
            stops: const [0.0, 0.45, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'REVIEW',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.55),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2.4,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'You are sending',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.70),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '₹',
                              style: TextStyle(
                                fontSize: 52,
                                fontWeight: FontWeight.w900,
                                color: Colors.white.withOpacity(0.92),
                              ),
                            ),
                            const SizedBox(width: 10),
                            ShaderMask(
                              shaderCallback: (rect) => LinearGradient(
                                colors: [
                                  AppColors.secondary.withOpacity(0.95),
                                  AppColors.primary.withOpacity(0.95),
                                ],
                              ).createShader(rect),
                              child: Text(
                                widget.amount,
                                style: const TextStyle(
                                  fontSize: 64,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.10)),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: AppColors.primary.withOpacity(0.35),
                                child: Text(
                                  widget.contactName.trim().isNotEmpty
                                      ? widget.contactName.trim()[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.contactName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      widget.contactPhone,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.70),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white.withOpacity(0.85),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 120),
                  curve: Curves.easeOut,
                  scale: _payPressed ? 0.985 : 1.0,
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.secondary.withOpacity(0.95),
                              AppColors.primary.withOpacity(0.95),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.25),
                              blurRadius: 18,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTapDown: (_) => setState(() => _payPressed = true),
                          onTapCancel: () => setState(() => _payPressed = false),
                          onTap: () {
                            setState(() => _payPressed = false);
                            _initiatePayment();
                          },
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'PAY • ₹${widget.amount}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Icon(Icons.lock_outline, color: Colors.white, size: 18),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
