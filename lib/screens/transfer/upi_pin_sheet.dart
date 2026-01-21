import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';
import '../../utils/colors.dart';
import '../../utils/page_transitions.dart';
import '../profile/set_upi_pin_screen.dart';

class UpiPinSheet extends StatefulWidget {
  final String receiverName;
  final String receiverId;
  final double amount;
  final VoidCallback onCancel;
  final VoidCallback onVerified;
  final bool startInBalanceCheck;
  final bool showCheckBalanceAction;
  final bool showPaymentWarning;

  const UpiPinSheet({
    super.key,
    required this.receiverName,
    required this.receiverId,
    required this.amount,
    required this.onCancel,
    required this.onVerified,
    this.startInBalanceCheck = false,
    this.showCheckBalanceAction = true,
    this.showPaymentWarning = true,
  });

  @override
  State<UpiPinSheet> createState() => _UpiPinSheetState();
}

class _UpiPinSheetState extends State<UpiPinSheet> {
  String _pin = '';
  bool _checkingBalance = false;

  @override
  void initState() {
    super.initState();
    _checkingBalance = widget.startInBalanceCheck;
  }

  void _addDigit(String digit) {
    if (_pin.length >= 4) return;
    setState(() => _pin += digit);
  }

  void _backspace() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _submit() async {
    if (_pin.length != 4) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    bool ok;
    try {
      ok = await userProvider.verifyUpiPin(_pin);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _pin = '';
        _checkingBalance = false;
      });
      return;
    }
    if (!mounted) return;

    if (!ok && !userProvider.hasUpiPin) {
      setState(() {
        _pin = '';
        _checkingBalance = false;
      });
      return;
    }

    if (!ok) {
      setState(() => _pin = '');
      return;
    }

    if (_checkingBalance) {
      final balance = userProvider.bankBalance;
      Navigator.pop<double>(context, balance);
      return;
    }

    widget.onVerified();
  }

  void _checkBalance() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (!userProvider.hasUpiPin) {
      setState(() {
        _pin = '';
        _checkingBalance = false;
      });
      return;
    }

    setState(() => _checkingBalance = true);

    if (_pin.length == 4) {
      _submit();
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasUpiPin = context.watch<UserProvider>().hasUpiPin;
    final prompt = _checkingBalance
        ? 'ENTER UPI PIN TO CHECK BALANCE'
        : 'ENTER 4-DIGIT UPI PIN';
    return SafeArea(
      child: Material(
        color: Colors.white,
        child: Column(
          children: [
            _Header(
              receiverName: widget.receiverName,
              receiverId: widget.receiverId,
              amount: widget.amount,
              onCancel: widget.onCancel,
              onCheckBalance: widget.showCheckBalanceAction ? _checkBalance : null,
            ),
            const SizedBox(height: 24),
            Text(
              prompt,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _PinDots(length: _pin.length),
            const SizedBox(height: 18),
            if (widget.showPaymentWarning)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF6D6),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFEED38D)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Color(0xFFB08900), size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'You are SENDING ₹${widget.amount.toStringAsFixed(2)} from your account to ${widget.receiverName}.',
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const Spacer(),
            if (!hasUpiPin)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      // User asked to set PIN via Profile.
                      final navigator = Navigator.of(context);
                      widget.onCancel();
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!navigator.mounted) return;
                        navigator.push(
                          smoothFadeSlideRoute(
                            (context) => const SetUpiPinScreen(),
                            beginOffset: const Offset(0, 0.10),
                          ),
                        );
                      });
                    },
                    child: const Text(
                      'SET UPI PIN IN PROFILE',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              )
            else
              _Keypad(
                onDigit: _addDigit,
                onBackspace: _backspace,
                onSubmit: _submit,
              ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String receiverName;
  final String receiverId;
  final double amount;
  final VoidCallback onCancel;
  final VoidCallback? onCheckBalance;

  const _Header({
    required this.receiverName,
    required this.receiverId,
    required this.amount,
    required this.onCancel,
    required this.onCheckBalance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE6E6E6)),
        ),
      ),
      child: Row(
        children: [
          TextButton(
            onPressed: onCancel,
            child: const Text('CANCEL'),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                receiverName,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '₹${amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          if (onCheckBalance != null)
            TextButton(
              onPressed: onCheckBalance,
              child: Text(
                'CHECK BALANCE',
                style: TextStyle(color: AppColors.primary),
              ),
            )
          else
            const SizedBox(width: 12),
        ],
      ),
    );
  }
}

class _PinDots extends StatelessWidget {
  final int length;

  const _PinDots({required this.length});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final filled = index < length;
        return Container(
          width: 14,
          height: 14,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? AppColors.primary : Colors.transparent,
            border: Border.all(color: AppColors.primary, width: 1.5),
          ),
        );
      }),
    );
  }
}

class _Keypad extends StatelessWidget {
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final VoidCallback onSubmit;

  const _Keypad({
    required this.onDigit,
    required this.onBackspace,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    const keys = <String>[
      '1', '2', '3',
      '4', '5', '6',
      '7', '8', '9',
      '⌫', '0', 'SUBMIT',
    ];

    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFE6E6E6)),
        ),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: keys.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 2.2,
        ),
        itemBuilder: (context, index) {
          final keyLabel = keys[index];

          VoidCallback? onPressed;
          if (keyLabel == '⌫') {
            onPressed = onBackspace;
          } else if (keyLabel == 'SUBMIT') {
            onPressed = onSubmit;
          } else {
            onPressed = () => onDigit(keyLabel);
          }

          final isSubmit = keyLabel == 'SUBMIT';

          return InkWell(
            onTap: onPressed,
            child: Container(
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                border: Border(
                  right: BorderSide(color: Color(0xFFE6E6E6)),
                  bottom: BorderSide(color: Color(0xFFE6E6E6)),
                ),
              ),
              child: isSubmit
                  ? Text(
                      keyLabel,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    )
                  : Text(
                      keyLabel,
                      style: TextStyle(
                        color: keyLabel == '⌫' ? Colors.black54 : Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
}
