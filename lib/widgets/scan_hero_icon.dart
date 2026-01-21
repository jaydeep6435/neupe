import 'package:flutter/material.dart';

const String kScanHeroTag = 'scan-hero';

class ScanHeroIcon extends StatelessWidget {
  const ScanHeroIcon({super.key, this.size = 52});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF00E5FF), Color(0xFF7C4DFF), Color(0xFFFFD54F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.qr_code_scanner,
          color: Colors.black,
          size: size * 0.5,
        ),
      ),
    );
  }
}
