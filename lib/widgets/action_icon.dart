import 'package:flutter/material.dart';
import '../utils/colors.dart';

class ActionIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? iconColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  // Nullable on purpose: some call sites pass `size: null`.
  final double? size;
  final double? iconSize;
  final bool compact;

  const ActionIcon({
    super.key,
    required this.icon,
    required this.label,
    this.iconColor,
    this.backgroundColor,
    this.onTap,
    this.size = 58,
    this.iconSize = 26,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final double resolvedSize = size ?? 58;
    final double resolvedIconSize = iconSize ?? 26;
    final Color resolvedIconColor = iconColor ?? AppColors.primary;
    final Color resolvedBackground =
        backgroundColor ?? AppColors.primary.withOpacity(0.10);

    final bool softBackground = resolvedBackground.opacity < 0.35;
    final bool prefersLightText = resolvedIconColor.computeLuminance() > 0.7;
    final Color resolvedLabelColor = prefersLightText
      ? Colors.white
      : (softBackground ? const Color(0xFF1D1D1F) : Colors.white);
    final BorderRadius borderRadius = BorderRadius.circular(18);

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
                width: resolvedSize,
                height: resolvedSize,
                decoration: BoxDecoration(
                  borderRadius: borderRadius,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: softBackground
                        ? [
                            resolvedBackground,
                            resolvedBackground.withOpacity(
                              (resolvedBackground.opacity + 0.12)
                                  .clamp(0.0, 1.0),
                            ),
                          ]
                        : [
                            resolvedBackground,
                            resolvedBackground.withOpacity(
                              (resolvedBackground.opacity - 0.10)
                                  .clamp(0.0, 1.0),
                            ),
                          ],
                  ),
                  border: Border.all(
                    color: softBackground
                        ? resolvedIconColor.withOpacity(0.14)
                        : Colors.white.withOpacity(0.16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 14,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -10,
                      left: -18,
                      child: Container(
                        width: resolvedSize * 0.9,
                        height: resolvedSize * 0.7,
                        decoration: BoxDecoration(
                          color: Colors.white
                              .withOpacity(softBackground ? 0.22 : 0.12),
                          borderRadius: BorderRadius.circular(resolvedSize),
                        ),
                      ),
                    ),
                    Center(
                      child: Icon(
                        icon,
                        color: resolvedIconColor,
                        size: resolvedIconSize,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: compact ? 6 : 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 90),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: compact ? 11 : 12,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                    color: resolvedLabelColor,
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
