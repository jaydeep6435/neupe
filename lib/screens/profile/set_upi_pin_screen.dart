import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';
import '../../utils/colors.dart';

class SetUpiPinScreen extends StatefulWidget {
  const SetUpiPinScreen({super.key});

  @override
  State<SetUpiPinScreen> createState() => _SetUpiPinScreenState();
}

class _SetUpiPinScreenState extends State<SetUpiPinScreen> {
  String _pin = '';
  String _confirmPin = '';
  bool _confirmStep = false;
  bool _saving = false;
  String? _error;

  void _addDigit(String digit) {
    if (!_confirmStep) {
      if (_pin.length >= 4) return;
      setState(() {
        _error = null;
        _pin += digit;
      });
      if (_pin.length == 4) {
        setState(() => _confirmStep = true);
      }
      return;
    }

    if (_confirmPin.length >= 4) return;
    setState(() {
      _error = null;
      _confirmPin += digit;
    });
  }

  void _backspace() {
    if (!_confirmStep) {
      if (_pin.isEmpty) return;
      setState(() {
        _error = null;
        _pin = _pin.substring(0, _pin.length - 1);
      });
      return;
    }

    if (_confirmPin.isNotEmpty) {
      setState(() {
        _error = null;
        _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
      });
      return;
    }

    // Go back to first step if confirm is empty
    setState(() {
      _error = null;
      _confirmStep = false;
    });
  }

  Future<void> _save() async {
    if (_pin.length != 4 || _confirmPin.length != 4) {
      setState(() => _error = 'Enter a 4-digit PIN and confirm it');
      return;
    }
    if (_pin != _confirmPin) {
      setState(() {
        _error = 'PINs do not match. Try again.';
        _confirmPin = '';
      });
      return;
    }

    setState(() {
      _error = null;
      _saving = true;
    });
    try {
      await Provider.of<UserProvider>(context, listen: false).setUpiPin(_pin);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      final message = e.toString();
      final isDns =
          message.contains('Failed host lookup') ||
          message.contains('No address associated with hostname') ||
          message.contains('Network/DNS error');
      setState(() {
        _error = isDns
            ? 'Network/DNS error. Check internet/Private DNS/VPN, then retry.'
            : 'Failed to set PIN. Please try again.';
      });
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final prompt = _confirmStep
        ? 'Confirm 4-digit UPI PIN'
        : 'Create 4-digit UPI PIN';
    final filled = _confirmStep ? _confirmPin.length : _pin.length;

    return Scaffold(
      backgroundColor: const Color(0xFF050816),
      appBar: AppBar(
        backgroundColor: const Color(0xFF050816),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'UPI PIN',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF13162B),
                borderRadius: BorderRadius.circular(18),
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
                  Text(
                    prompt.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (i) {
                      final isFilled = i < filled;
                      return Container(
                        width: 14,
                        height: 14,
                        margin: const EdgeInsets.symmetric(horizontal: 7),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isFilled ? Colors.white : Colors.transparent,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.28),
                            width: 1.4,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: _error == null
                        ? const SizedBox(height: 18)
                        : Text(
                            _error!,
                            key: ValueKey(_error),
                            style: TextStyle(
                              color: Colors.redAccent.withOpacity(0.95),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            _Keypad(
              enabled: !_saving,
              onDigit: _addDigit,
              onBackspace: _backspace,
              onSubmit: _saving ? null : _save,
              submitLabel: _confirmStep ? 'SAVE' : 'NEXT',
            ),
          ],
        ),
      ),
    );
  }
}

class _Keypad extends StatelessWidget {
  final bool enabled;
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final VoidCallback? onSubmit;
  final String submitLabel;

  const _Keypad({
    required this.enabled,
    required this.onDigit,
    required this.onBackspace,
    required this.onSubmit,
    required this.submitLabel,
  });

  @override
  Widget build(BuildContext context) {
    final keys = <String>[
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '⌫',
      '0',
      submitLabel,
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0B0F22),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.06))),
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
          final label = keys[index];
          final isSubmit = label == submitLabel;

          VoidCallback? onTap;
          if (!enabled) {
            onTap = null;
          } else if (label == '⌫') {
            onTap = onBackspace;
          } else if (isSubmit) {
            onTap = onSubmit;
          } else {
            onTap = () => onDigit(label);
          }

          return InkWell(
            onTap: onTap,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: Colors.white.withOpacity(0.06)),
                  bottom: BorderSide(color: Colors.white.withOpacity(0.06)),
                ),
              ),
              child: isSubmit
                  ? Text(
                      label,
                      style: TextStyle(
                        color: enabled ? Colors.white : Colors.white38,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    )
                  : Text(
                      label,
                      style: TextStyle(
                        color: enabled ? Colors.white : Colors.white38,
                        fontWeight: FontWeight.w700,
                        fontSize: label == '⌫' ? 18 : 16,
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
}
