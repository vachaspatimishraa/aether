import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/luxury_theme.dart';
import 'glowing_badge.dart';

class DisplayScreen extends StatefulWidget {
  final String expression;
  final String? liveResult;
  final bool isDegree;
  final VoidCallback onToggleDegree;
  final bool hasMemory;
  final VoidCallback onClearMemory;
  final VoidCallback onBackspace;
  final VoidCallback onClear;
  final VoidCallback? onOpenHistory;
  final VoidCallback? onOpenConstants;

  const DisplayScreen({
    super.key,
    required this.expression,
    this.liveResult,
    required this.isDegree,
    required this.onToggleDegree,
    this.hasMemory = false,
    required this.onClearMemory,
    required this.onBackspace,
    required this.onClear,
    this.onOpenHistory,
    this.onOpenConstants,
  });

  @override
  State<DisplayScreen> createState() => _DisplayScreenState();
}

class _DisplayScreenState extends State<DisplayScreen> with SingleTickerProviderStateMixin {
  late AnimationController _caretController;
  final ScrollController _scrollController = ScrollController();
  bool _copiedFeedback = false;

  @override
  void initState() {
    super.initState();
    _caretController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant DisplayScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.expression != oldWidget.expression) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _caretController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _copyToClipboard(String text) {
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    setState(() => _copiedFeedback = true);
    HapticFeedback.mediumImpact();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copiedFeedback = false);
    });
  }

  List<TextSpan> _buildSyntaxHighlightedSpans(String text) {
    if (text.isEmpty) {
      return [
        TextSpan(
          text: '0',
          style: TextStyle(
            color: LuxuryTheme.textSubtle,
            fontSize: 34,
            fontWeight: FontWeight.w300,
          ),
        ),
      ];
    }

    final spans = <TextSpan>[];
    final tokenRegex = RegExp(
      r'([0-9]+(\.[0-9]+)?)|([+\-×÷*/^%])|([a-zA-Z]+[0-9]*)|([()√∛!πφ])|(\s+)',
    );

    final matches = tokenRegex.allMatches(text);
    for (final m in matches) {
      final token = m.group(0)!;
      Color color = LuxuryTheme.textBright;
      FontWeight weight = FontWeight.w400;

      if (RegExp(r'^[0-9]+(\.[0-9]+)?$').hasMatch(token)) {
        color = LuxuryTheme.textBright;
        weight = FontWeight.w600;
      } else if (RegExp(r'^[+\-×÷*/^%]$').hasMatch(token)) {
        color = LuxuryTheme.goldPrimary;
        weight = FontWeight.w700;
      } else if (RegExp(r'^(sin|cos|tan|asin|acos|atan|sinh|cosh|tanh|log|ln|sqrt|cbrt|abs|exp|nCr|nPr)$')
          .hasMatch(token)) {
        color = LuxuryTheme.emeraldBright;
        weight = FontWeight.w700;
      } else if (token == 'π' || token == 'φ' || token == 'e') {
        color = LuxuryTheme.goldWarm;
        weight = FontWeight.w700;
      } else if (token == '(' || token == ')') {
        color = LuxuryTheme.emeraldMuted;
        weight = FontWeight.w600;
      } else if (token == '√' || token == '∛' || token == '!') {
        color = LuxuryTheme.goldWarm;
      }

      spans.add(
        TextSpan(
          text: token,
          style: TextStyle(
            color: color,
            fontSize: 34,
            fontWeight: weight,
            letterSpacing: 0.5,
          ),
        ),
      );
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LuxuryTheme.surfaceCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: LuxuryTheme.borderGlowing, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
          BoxShadow(
            color: LuxuryTheme.emeraldSubtle,
            blurRadius: 12,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Badges & Controls Bar
          Row(
            children: [
              // Angle Mode Badge (DEG / RAD)
              GlowingBadge(
                text: widget.isDegree ? 'DEG' : 'RAD',
                isActive: true,
                activeColor: widget.isDegree ? LuxuryTheme.emeraldPrimary : LuxuryTheme.goldPrimary,
                onTap: widget.onToggleDegree,
              ),
              const SizedBox(width: 8),

              // Memory indicator
              if (widget.hasMemory)
                GlowingBadge(
                  text: 'MEM',
                  isActive: true,
                  activeColor: LuxuryTheme.goldPrimary,
                  icon: Icons.memory,
                  onTap: widget.onClearMemory,
                ),

              const Spacer(),

              // Quick Actions: Constants, History, Copy
              if (widget.onOpenConstants != null)
                IconButton(
                  icon: Icon(Icons.calculate_outlined, size: 20, color: LuxuryTheme.goldPrimary),
                  tooltip: 'Physical & Math Constants',
                  onPressed: widget.onOpenConstants,
                  visualDensity: VisualDensity.compact,
                ),

              if (widget.onOpenHistory != null)
                IconButton(
                  icon: Icon(Icons.history, size: 20, color: LuxuryTheme.emeraldPrimary),
                  tooltip: 'Calculation History',
                  onPressed: widget.onOpenHistory,
                  visualDensity: VisualDensity.compact,
                ),

              IconButton(
                icon: Icon(
                  _copiedFeedback ? Icons.check : Icons.copy_rounded,
                  size: 18,
                  color: _copiedFeedback ? LuxuryTheme.emeraldBright : LuxuryTheme.textMuted,
                ),
                tooltip: _copiedFeedback ? 'Copied!' : 'Copy Expression',
                onPressed: () => _copyToClipboard(
                  widget.liveResult ?? widget.expression,
                ),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Main Expression Display with Horizontal Scroll and Animated Caret
          SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            reverse: false,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                RichText(
                  text: TextSpan(
                    children: _buildSyntaxHighlightedSpans(widget.expression),
                  ),
                ),
                // Animated Caret
                FadeTransition(
                  opacity: _caretController,
                  child: Container(
                    width: 2.5,
                    height: 32,
                    margin: const EdgeInsets.only(left: 3),
                    decoration: BoxDecoration(
                      color: LuxuryTheme.emeraldPrimary,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: LuxuryTheme.emeraldPrimary,
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Live Result Preview Ticker
          AnimatedOpacity(
            duration: const Duration(milliseconds: 180),
            opacity: widget.liveResult != null && widget.liveResult!.isNotEmpty ? 1.0 : 0.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '= ',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: LuxuryTheme.goldWarm,
                  ),
                ),
                Flexible(
                  child: Text(
                    widget.liveResult ?? '',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: LuxuryTheme.emeraldBright,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

