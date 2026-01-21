import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/page_transitions.dart';
import '../../widgets/custom_numeric_keyboard.dart';
import 'amount_confirm_page.dart';

/// Page for entering amount with custom numeric keyboard
/// Opens when user swipes up from transaction chat
class AmountInputPage extends StatefulWidget {
  final String contactName;
  final String contactPhone;
  final String? initialAmount;

  const AmountInputPage({
    required this.contactName,
    required this.contactPhone,
    this.initialAmount,
    super.key,
  });

  @override
  State<AmountInputPage> createState() => _AmountInputPageState();
}

class _AmountInputPageState extends State<AmountInputPage> {
  late TextEditingController _amountController;
  String _expression = '0';
  double _evaluated = 0;
  bool _hasValidEvaluation = true;

  bool _continuePressed = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialAmount;
    _expression = (initial == null || initial.isEmpty) ? '0' : initial;
    _amountController = TextEditingController(text: _expression);
    _recompute();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _sendMoney(String amount) {
    final value = _evaluated;
    if (!_hasValidEvaluation || value <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount')),
      );
      return;
    }

    final formatted = _formatAmount(value);

    Navigator.push(
      context,
      smoothFadeSlideRoute(
        (context) => AmountConfirmPage(
          contactName: widget.contactName,
          contactPhone: widget.contactPhone,
          amount: formatted,
        ),
        beginOffset: const Offset(0, 0.10),
      ),
    );
  }

  static bool _isOperator(String c) => c == '+' || c == '-' || c == '*' || c == '/';

  void _handleKeyPressed(String key) {
    setState(() {
      if (key.isEmpty) return;

      final isOp = _isOperator(key);
      if (!isOp) {
        // Digit (or any other non-operator key) => append
        if (_expression == '0') {
          _expression = key;
        } else {
          _expression += key;
        }
      } else {
        // Operator
        if (_expression.isEmpty) {
          _expression = '0$key';
        } else if (_expression.length == 1 && _expression == '0') {
          _expression = '0$key';
        } else {
          final last = _expression[_expression.length - 1];
          if (_isOperator(last)) {
            // Replace operator (avoid ++ or *- etc.)
            _expression = _expression.substring(0, _expression.length - 1) + key;
          } else {
            _expression += key;
          }
        }
      }

      _amountController.text = _expression;
      _recompute();
    });
  }

  void _handleBackspace() {
    setState(() {
      if (_expression.isEmpty || _expression == '0') {
        _expression = '0';
      } else if (_expression.length <= 1) {
        _expression = '0';
      } else {
        _expression = _expression.substring(0, _expression.length - 1);
        if (_expression.isEmpty) _expression = '0';
      }
      _amountController.text = _expression;
      _recompute();
    });
  }

  String _formatAmount(double value) {
    if (value.isNaN || value.isInfinite) return '0';
    final rounded = value.roundToDouble();
    if ((value - rounded).abs() < 1e-9) {
      return rounded.toInt().toString();
    }
    final s = value.toStringAsFixed(2);
    return s.replaceFirst(RegExp(r'\.00$'), '').replaceFirst(RegExp(r'(\.[0-9])0$'), r'$1');
  }

  void _recompute() {
    final expr = _expression.trim();
    final trimmed = _trimTrailingOperators(expr);
    if (trimmed.isEmpty) {
      _evaluated = 0;
      _hasValidEvaluation = true;
      return;
    }
    try {
      final v = _evaluateExpression(trimmed);
      if (v.isNaN || v.isInfinite) {
        _evaluated = 0;
        _hasValidEvaluation = false;
      } else {
        _evaluated = v;
        _hasValidEvaluation = true;
      }
    } catch (_) {
      _evaluated = 0;
      _hasValidEvaluation = false;
    }
  }

  String _trimTrailingOperators(String input) {
    var s = input;
    while (s.isNotEmpty && _isOperator(s[s.length - 1])) {
      s = s.substring(0, s.length - 1).trimRight();
    }
    return s;
  }

  double _evaluateExpression(String input) {
    // Shunting-yard to handle precedence for + - * /
    final tokens = _tokenize(input);
    final output = <String>[];
    final ops = <String>[];

    int precedence(String op) => (op == '*' || op == '/') ? 2 : 1;

    for (final t in tokens) {
      if (t.isEmpty) continue;
      if (_isOperator(t)) {
        while (ops.isNotEmpty && _isOperator(ops.last) && precedence(ops.last) >= precedence(t)) {
          output.add(ops.removeLast());
        }
        ops.add(t);
      } else {
        output.add(t);
      }
    }
    while (ops.isNotEmpty) {
      output.add(ops.removeLast());
    }

    final stack = <double>[];
    for (final t in output) {
      if (!_isOperator(t)) {
        stack.add(double.parse(t));
      } else {
        if (stack.length < 2) throw const FormatException('Invalid expression');
        final b = stack.removeLast();
        final a = stack.removeLast();
        switch (t) {
          case '+':
            stack.add(a + b);
            break;
          case '-':
            stack.add(a - b);
            break;
          case '*':
            stack.add(a * b);
            break;
          case '/':
            stack.add(a / b);
            break;
        }
      }
    }
    if (stack.length != 1) throw const FormatException('Invalid expression');
    return stack.single;
  }

  List<String> _tokenize(String input) {
    final s = input.replaceAll(' ', '');
    final tokens = <String>[];
    final buf = StringBuffer();

    bool expectingNumber = true;
    for (int i = 0; i < s.length; i++) {
      final ch = s[i];
      final isDigit = ch.codeUnitAt(0) >= 48 && ch.codeUnitAt(0) <= 57;

      if (isDigit || ch == '.') {
        buf.write(ch);
        expectingNumber = false;
        continue;
      }

      if (_isOperator(ch)) {
        if (buf.isNotEmpty) {
          tokens.add(buf.toString());
          buf.clear();
        }

        // Unary minus: treat as 0 - <number>
        if (ch == '-' && expectingNumber) {
          tokens.add('0');
          tokens.add('-');
          expectingNumber = true;
          continue;
        }

        tokens.add(ch);
        expectingNumber = true;
        continue;
      }

      // Ignore unknown characters
    }

    if (buf.isNotEmpty) tokens.add(buf.toString());
    return tokens;
  }

  @override
  Widget build(BuildContext context) {
    final displayAmount = _formatAmount(_evaluated);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 210),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) {
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 18),
            child: child,
          ),
        );
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.contactName),
              Text(
                widget.contactPhone,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
              ),
            ],
          ),
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
          child: Column(
            children: [
              // Amount display section
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: Colors.white.withOpacity(0.10)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.calculate_outlined, color: Colors.white.withOpacity(0.75), size: 18),
                              const SizedBox(width: 10),
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 240),
                                child: Text(
                                  _expression,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.80),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                        Text(
                          'TOTAL',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.55),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2.4,
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
                                displayAmount,
                                style: const TextStyle(
                                  fontSize: 64,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 26),
                        AnimatedScale(
                          duration: const Duration(milliseconds: 120),
                          curve: Curves.easeOut,
                          scale: _continuePressed ? 0.985 : 1.0,
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
                                  onTapDown: (_) => setState(() => _continuePressed = true),
                                  onTapCancel: () => setState(() => _continuePressed = false),
                                  onTap: () {
                                    setState(() => _continuePressed = false);
                                    _sendMoney(_expression);
                                  },
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _hasValidEvaluation && _evaluated > 0
                                              ? 'Continue • ₹$displayAmount'
                                              : 'Continue',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                                      ],
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
              ),

              // Keyboard section
              Container(
                color: Colors.black,
                child: CustomNumericKeyboard(
                  onKeyPressed: _handleKeyPressed,
                  onBackspace: _handleBackspace,
                  onNext: () => _sendMoney(_expression),
                  showNextButton: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
