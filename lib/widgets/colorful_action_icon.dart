import 'package:flutter/material.dart';

class ColorfulActionIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final List<Color> colors;
  final double size;
  final double iconSize;
  final Color labelColor;

  const ColorfulActionIcon({
    super.key,
    required this.icon,
    required this.label,
    required this.colors,
    this.onTap,
    this.size = 58,
    this.iconSize = 26,
    this.labelColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    assert(colors.length >= 2, 'Provide at least 2 gradient colors');
    final BorderRadius borderRadius = BorderRadius.circular(20);

    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  borderRadius: borderRadius,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: colors,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(89),
                      blurRadius: 16,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Soft highlight blobs for a more premium feel
                    Positioned(
                      top: -14,
                      left: -18,
                      child: Container(
                        width: size * 0.85,
                        height: size * 0.70,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(41),
                          borderRadius: BorderRadius.circular(size),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -18,
                      right: -14,
                      child: Container(
                        width: size * 0.75,
                        height: size * 0.75,
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(26),
                          borderRadius: BorderRadius.circular(size),
                        ),
                      ),
                    ),
                    Center(
                      child: Icon(
                        icon,
                        size: iconSize,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withAlpha(89),
                            blurRadius: 10,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                    ),
                    // Thin inner border
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: borderRadius,
                          border: Border.all(
                            color: Colors.white.withAlpha(36),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 94),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                    color: labelColor,
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
