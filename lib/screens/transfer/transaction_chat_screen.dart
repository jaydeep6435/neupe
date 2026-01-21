import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/transaction_model.dart';
import '../../utils/colors.dart';
import '../../utils/page_transitions.dart';
import 'amount_input_page.dart';

/// Screen showing transaction history (chat-like) with a specific contact.
/// User can send money via the slide-up sheet at the bottom.
class TransactionChatScreen extends StatefulWidget {
  final String contactName;
  final String contactPhone;
  final List<TransactionModel> transactions;

  const TransactionChatScreen({
    required this.contactName,
    required this.contactPhone,
    required this.transactions,
    super.key,
  });

  @override
  State<TransactionChatScreen> createState() => _TransactionChatScreenState();
}

class _TransactionChatScreenState extends State<TransactionChatScreen>
    with SingleTickerProviderStateMixin {
  late DraggableScrollableController _sheetScrollController;
  bool _isOpeningAmountInput = false;
  bool _amountInputArmed = true;

  late final Map<DateTime, List<TransactionModel>> _groupedByDay;
  late final List<DateTime> _sortedDays;
  late final String _heroTag;
  late final DateFormat _timeFormat;

  Timer? _rubberBandTimer;
  late final AnimationController _hintController;
  late final Animation<double> _hintOffset;

  static const double _minSheetSize = 0.08;
  static const double _openThreshold = 0.3;
  static const Duration _snapBackDelay = Duration(milliseconds: 40);
  static const Duration _snapBackDuration = Duration(milliseconds: 180);

  @override
  void initState() {
    super.initState();
    _sheetScrollController = DraggableScrollableController();

    // Precompute expensive work once to keep route transitions smooth.
    _groupedByDay = <DateTime, List<TransactionModel>>{};
    for (final txn in widget.transactions) {
      final d = DateTime(txn.date.year, txn.date.month, txn.date.day);
      _groupedByDay.putIfAbsent(d, () => []).add(txn);
    }
    _sortedDays = _groupedByDay.keys.toList()..sort((a, b) => b.compareTo(a));
    _heroTag = 'contactHero:${(widget.contactPhone.trim().isNotEmpty ? widget.contactPhone : widget.contactName).trim().toLowerCase()}';
    _timeFormat = DateFormat('h:mm a');

    _hintController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _hintOffset = Tween<double>(begin: 0, end: -6).animate(
      CurvedAnimation(parent: _hintController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _rubberBandTimer?.cancel();
    _hintController.dispose();
    _sheetScrollController.dispose();
    super.dispose();
  }

  void _scheduleRubberBandSnapBack() {
    _rubberBandTimer?.cancel();
    if (_isOpeningAmountInput) return;

    _rubberBandTimer = Timer(_snapBackDelay, () {
      if (!mounted || _isOpeningAmountInput) return;
      final size = _sheetScrollController.size;
      if (size >= _openThreshold) return;
      if (size > _minSheetSize + 0.01) {
        _sheetScrollController.animateTo(
          _minSheetSize,
          duration: _snapBackDuration,
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  PageRoute<void> _amountInputRoute() {
    return smoothFadeSlideRoute<void>(
      (context) => AmountInputPage(
        contactName: widget.contactName,
        contactPhone: widget.contactPhone,
      ),
      beginOffset: const Offset(0, 0.12),
      duration: const Duration(milliseconds: 240),
      reverseDuration: const Duration(milliseconds: 210),
    );
  }

  Future<void> _openAmountInput() async {
    if (_isOpeningAmountInput) return;
    _isOpeningAmountInput = true;
    _amountInputArmed = false;
    _rubberBandTimer?.cancel();

    // Lock the sheet at the threshold so the page transition feels continuous.
    try {
      unawaited(
        _sheetScrollController.animateTo(
          _openThreshold,
          duration: const Duration(milliseconds: 110),
          curve: Curves.easeOutCubic,
        ),
      );
    } catch (_) {
      // ignore (controller might not be attached yet)
    }

    if (!mounted) {
      _isOpeningAmountInput = false;
      return;
    }

    try {
      await Navigator.of(context).push(_amountInputRoute());
    } finally {
      if (!mounted) return;
      _isOpeningAmountInput = false;
      // Collapse the sheet when returning
      _sheetScrollController.animateTo(
        _minSheetSize,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary.withOpacity(0.08),
      appBar: AppBar(
        backgroundColor: AppColors.primary.withOpacity(0.22),
        foregroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 56,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ],
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Hero(
                  tag: _heroTag,
                  child: Material(
                    type: MaterialType.transparency,
                    child: CircleAvatar(
                      radius: 16,
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
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.contactName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.contactPhone.trim().isNotEmpty)
                        Text(
                          widget.contactPhone,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: Colors.white),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.help_outline, color: Colors.white),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Transaction history
          widget.transactions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.history, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No transactions yet',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 140, top: 6),
                  itemCount: _sortedDays.length,
                  itemBuilder: (context, index) {
                    final day = _sortedDays[index];
                    final dayTransactions = _groupedByDay[day]!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DateDivider(label: _formatDate(day)),
                        ...dayTransactions.map((txn) => _buildTransactionCard(txn)),
                      ],
                    );
                  },
                ),

          // Draggable send money sheet
          NotificationListener<DraggableScrollableNotification>(
            onNotification: (notification) {
              // Re-arm only after the sheet is mostly collapsed.
              if (notification.extent <= 0.12) {
                _amountInputArmed = true;
              }

              // Open amount flow when dragged past threshold
              if (notification.extent >= _openThreshold && _amountInputArmed && !_isOpeningAmountInput) {
                // Fire and forget; keeps notification handler synchronous.
                unawaited(_openAmountInput());
                return true;
              }

              // Rubber-band behavior: if user releases below half, snap back down.
              if (notification.extent < _openThreshold && notification.extent > _minSheetSize + 0.01) {
                _scheduleRubberBandSnapBack();
              }
              return false;
            },
            child: DraggableScrollableSheet(
              controller: _sheetScrollController,
              initialChildSize: _minSheetSize,
              minChildSize: _minSheetSize,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.primary.withOpacity(0.16),
                        Colors.black,
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    border: Border(
                      top: BorderSide(color: Colors.white.withOpacity(0.10), width: 1),
                    ),
                  ),
                  child: ListView(
                    controller: scrollController,
                    children: [
                      // Drag handle
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 12),
                        child: Center(
                          child: Container(
                            width: 50,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.35),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                      // Collapsed view - "Slide up to send money"
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: AnimatedBuilder(
                          animation: _hintController,
                          builder: (context, _) {
                            return Transform.translate(
                              offset: Offset(0, _hintOffset.value),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.arrow_upward,
                                    color: AppColors.primary.withOpacity(0.95),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Slide up to send money',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.90),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(TransactionModel txn) {
    final isCredit = txn.type == TransactionType.credit;
    final timeText = _timeFormat.format(txn.date);

    final base = isCredit ? const Color(0xFF2B2B2B) : AppColors.primary;
    final base2 = isCredit ? const Color(0xFF1F1F1F) : const Color(0xFF4A1F7C);
    final label = isCredit ? 'RECEIVED' : 'PAID';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      child: Align(
        alignment: isCredit ? Alignment.centerLeft : Alignment.centerRight,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 285),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [base, base2],
                    ),
                    border: isCredit
                        ? null
                        : Border.all(
                            color: AppColors.secondary.withOpacity(0.35),
                            width: 1,
                          ),
                  ),
                ),
                Positioned.fill(
                  child: CustomPaint(
                    painter: _WavesPainter(
                      color: Colors.white.withOpacity(isCredit ? 0.10 : 0.16),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '₹${txn.amount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            width: 18,
                            height: 18,
                            decoration: const BoxDecoration(
                              // Paid/Received distinction
                              color: Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: isCredit ? AppColors.green : AppColors.secondary,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Icon(
                                  isCredit ? Icons.check : Icons.arrow_outward,
                                  size: 12,
                                  color: isCredit ? Colors.black : Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            label,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.60),
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2.2,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_forward,
                              color: Colors.white.withOpacity(0.85),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Spacer(),
                          Text(
                            timeText,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.45),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else {
      return '${_monthName(date.month)} ${date.day}, ${date.year}';
    }
  }

  String _monthName(int month) {
    const names = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return names[month - 1];
  }
}

class _DateDivider extends StatelessWidget {
  final String label;

  const _DateDivider({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.55),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _WavesPainter extends CustomPainter {
  final Color color;

  const _WavesPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Simple repeating wave pattern
    const amplitude = 6.0;
    const gap = 10.0;
    for (double y = 8; y < size.height + gap; y += gap) {
      final path = Path();
      path.moveTo(0, y);
      for (double x = 0; x <= size.width; x += 12) {
        final dy = amplitude * (x % 24 == 0 ? 1 : -1);
        path.quadraticBezierTo(x + 6, y + dy, x + 12, y);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WavesPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
