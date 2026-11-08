import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/luxury_theme.dart';

enum ButtonVariant {
  number,
  operator,
  action,
  equals,
  danger, // Warm Ochre/Orange, STRICTLY ZERO RED
  secondary,
}

class AnimatedCalculatorButton extends StatefulWidget {
  final String label;
  final Widget? icon;
  final String? subLabel;
  final ButtonVariant variant;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final double flex;
  final double? height;
  final double fontSize;
  final String? tooltip;

  const AnimatedCalculatorButton({
    super.key,
    required this.label,
    this.icon,
    this.subLabel,
    this.variant = ButtonVariant.number,
    required this.onTap,
    this.onLongPress,
    this.flex = 1.0,
    this.height,
    this.fontSize = 20,
    this.tooltip,
  });

  @override
  State<AnimatedCalculatorButton> createState() => _AnimatedCalculatorButtonState();
}

class _AnimatedCalculatorButtonState extends State<AnimatedCalculatorButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeOutBack,
      ),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    _animController.forward();
    HapticFeedback.lightImpact();
    SystemSound.play(SystemSoundType.click);
  }

  void _handleTapUp(TapUpDetails _) {
    _animController.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    _animController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    Color borderColor;
    List<BoxShadow> shadows;

    switch (widget.variant) {
      case ButtonVariant.equals:
        bgColor = LuxuryTheme.emeraldPrimary;
        textColor = LuxuryTheme.isDark ? const Color(0xFF062316) : Colors.white;
        borderColor = LuxuryTheme.emeraldBright;
        shadows = [
          BoxShadow(
            color: LuxuryTheme.emeraldPrimary.withOpacity(_isHovered ? 0.6 : 0.35),
            blurRadius: _isHovered ? 16 : 10,
            spreadRadius: _isHovered ? 2 : 0,
            offset: const Offset(0, 4),
          ),
        ];
        break;

      case ButtonVariant.operator:
        bgColor = LuxuryTheme.keyOpBg;
        textColor = LuxuryTheme.goldPrimary;
        borderColor = LuxuryTheme.goldWarm.withOpacity(0.35);
        shadows = [
          if (_isHovered)
            BoxShadow(
              color: LuxuryTheme.goldPrimary.withOpacity(0.25),
              blurRadius: 10,
            ),
        ];
        break;

      case ButtonVariant.action:
        bgColor = LuxuryTheme.keyFnBg;
        textColor = LuxuryTheme.emeraldBright;
        borderColor = LuxuryTheme.emeraldPrimary.withOpacity(0.35);
        shadows = [
          if (_isHovered)
            BoxShadow(
              color: LuxuryTheme.emeraldPrimary.withOpacity(0.25),
              blurRadius: 10,
            ),
        ];
        break;

      case ButtonVariant.danger:
        // Warm Ochre/Orange, NO RED!
        bgColor = LuxuryTheme.surfaceCardElevated;
        textColor = LuxuryTheme.ochreWarm;
        borderColor = LuxuryTheme.ochreWarm.withOpacity(0.4);
        shadows = [
          if (_isHovered)
            BoxShadow(
              color: LuxuryTheme.ochreWarm.withOpacity(0.3),
              blurRadius: 10,
            ),
        ];
        break;

      case ButtonVariant.secondary:
        bgColor = LuxuryTheme.surfaceDark;
        textColor = LuxuryTheme.textMuted;
        borderColor = LuxuryTheme.borderMuted;
        shadows = [];
        break;

      case ButtonVariant.number:
        bgColor = LuxuryTheme.keyNumberBg;
        textColor = LuxuryTheme.textBright;
        borderColor = LuxuryTheme.borderMuted;
        shadows = [
          if (_isHovered)
            BoxShadow(
              color: LuxuryTheme.emeraldPrimary.withOpacity(0.12),
              blurRadius: 8,
            ),
        ];
        break;
    }

    Widget buttonContent = AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          onLongPress: widget.onLongPress,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            height: widget.height ?? 58,
            margin: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: _isHovered && widget.variant != ButtonVariant.equals
                  ? Color.lerp(bgColor, Colors.white, 0.06)
                  : bgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isHovered ? borderColor.withOpacity(0.8) : borderColor,
                width: widget.variant == ButtonVariant.equals ? 1.5 : 1.0,
              ),
              boxShadow: shadows,
            ),
            child: Center(
              child: widget.icon ??
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.subLabel != null)
                        Text(
                          widget.subLabel!,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: LuxuryTheme.goldWarm.withOpacity(0.8),
                            letterSpacing: 0.5,
                          ),
                        ),
                      Text(
                        widget.label,
                        style: TextStyle(
                          color: textColor,
                          fontSize: widget.fontSize,
                          fontWeight: widget.variant == ButtonVariant.equals
                              ? FontWeight.w800
                              : FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
            ),
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(
        message: widget.tooltip!,
        waitDuration: const Duration(milliseconds: 400),
        child: buttonContent,
      );
    }

    return buttonContent;
  }
}
