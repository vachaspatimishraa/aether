import 'package:flutter/material.dart';
import '../theme/luxury_theme.dart';

class GlowingBadge extends StatelessWidget {
  final String text;
  final bool isActive;
  final VoidCallback? onTap;
  final Color? activeColor;
  final IconData? icon;

  const GlowingBadge({
    super.key,
    required this.text,
    this.isActive = true,
    this.onTap,
    this.activeColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveActiveColor = activeColor ?? LuxuryTheme.emeraldPrimary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? effectiveActiveColor.withOpacity(0.15) : LuxuryTheme.surfaceDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? effectiveActiveColor.withOpacity(0.7) : LuxuryTheme.borderMuted,
            width: 1.0,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: effectiveActiveColor.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 13,
                color: isActive ? activeColor : LuxuryTheme.textMuted,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              text,
              style: TextStyle(
                color: isActive ? activeColor : LuxuryTheme.textMuted,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                fontSize: 12,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

