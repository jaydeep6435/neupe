import 'package:flutter/material.dart';
import '../utils/colors.dart';

/// Custom numeric keyboard with numbers, operators (+, -, *, /), and backspace
class CustomNumericKeyboard extends StatelessWidget {
  final Function(String) onKeyPressed;
  final VoidCallback onBackspace;
  final VoidCallback? onNext;
  final bool showNextButton;

  const CustomNumericKeyboard({
    required this.onKeyPressed,
    required this.onBackspace,
    this.onNext,
    this.showNextButton = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(8),
      child: GridView.count(
        crossAxisCount: 4,
        childAspectRatio: 1.2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // Row 1: 1, 2, 3, Backspace
          _buildKey('1'),
          _buildKey('2'),
          _buildKey('3'),
          _buildBackspaceButton(),
          
          // Row 2: 4, 5, 6, Next
          _buildKey('4'),
          _buildKey('5'),
          _buildKey('6'),
          showNextButton 
              ? _buildNextButton() 
              : _buildKey('+'),
          
          // Row 3: 7, 8, 9, +/-
          _buildKey('7'),
          _buildKey('8'),
          _buildKey('9'),
          _buildOperatorButton('+'),
          
          // Row 4: *, 0, /, -
          _buildOperatorButton('*'),
          _buildKey('0'),
          _buildOperatorButton('/'),
          _buildOperatorButton('-'),
        ],
      ),
    );
  }

  Widget _buildKey(String key) {
    return GestureDetector(
      onTap: () => onKeyPressed(key),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Center(
          child: Text(
            key,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOperatorButton(String operator) {
    return GestureDetector(
      onTap: () => onKeyPressed(operator),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.18),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primary.withOpacity(0.30)),
        ),
        child: Center(
          child: Text(
            operator,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return GestureDetector(
      onTap: onBackspace,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Center(
          child: Icon(
            Icons.backspace_outlined,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return GestureDetector(
      onTap: onNext,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Center(
          child: Text(
            'Next',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
