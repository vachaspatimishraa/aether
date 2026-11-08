import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart' hide Stack;
import '../theme/luxury_theme.dart';

class GraphingScreen extends StatefulWidget {
  const GraphingScreen({super.key});

  @override
  State<GraphingScreen> createState() => _GraphingScreenState();
}

class _GraphingScreenState extends State<GraphingScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _fnController = TextEditingController(text: 'sin(x) * 2');
  late AnimationController _animController;

  // Viewport parameters
  double _xMin = -6.0;
  double _xMax = 6.0;
  double _yMin = -4.0;
  double _yMax = 4.0;

  // Cursor inspection
  Offset? _hoverOffset;
  double? _inspectedX;
  double? _inspectedY;

  // Presets
  final List<String> _presets = [
    'sin(x) * 2',
    'cos(x) + sin(2*x)',
    'x^3 - 3*x',
    'x^2 - 4',
    '1 / (1 + x^2) * 4',
    'exp(-0.2*x^2) * 3',
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _fnController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _zoom(double factor) {
    setState(() {
      final xRange = (_xMax - _xMin) * factor;
      final yRange = (_yMax - _yMin) * factor;
      final xCenter = (_xMax + _xMin) / 2;
      final yCenter = (_yMax + _yMin) / 2;

      _xMin = xCenter - xRange / 2;
      _xMax = xCenter + xRange / 2;
      _yMin = yCenter - yRange / 2;
      _yMax = yCenter + yRange / 2;
    });
  }

  void _resetView() {
    setState(() {
      _xMin = -6.0;
      _xMax = 6.0;
      _yMin = -4.0;
      _yMax = 4.0;
      _hoverOffset = null;
      _inspectedX = null;
      _inspectedY = null;
    });
  }

  void _pan(double dxFraction, double dyFraction) {
    setState(() {
      final xRange = _xMax - _xMin;
      final yRange = _yMax - _yMin;
      _xMin += xRange * dxFraction;
      _xMax += xRange * dxFraction;
      _yMin -= yRange * dyFraction;
      _yMax -= yRange * dyFraction;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Function input bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: LuxuryTheme.surfaceDark,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: LuxuryTheme.emeraldSubtle,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: LuxuryTheme.emeraldPrimary),
                ),
                child: Text(
                  'f(x) =',
                  style: TextStyle(
                    color: LuxuryTheme.emeraldBright,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _fnController,
                  style: TextStyle(
                    color: LuxuryTheme.textBright,
                    fontSize: 16,
                    fontFamily: 'monospace',
                  ),
                  decoration: InputDecoration(
                    hintText: 'e.g. sin(x) + cos(2*x)',
                    hintStyle: TextStyle(color: LuxuryTheme.textSubtle),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    filled: true,
                    fillColor: LuxuryTheme.surfaceCard,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: LuxuryTheme.borderMuted),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: LuxuryTheme.emeraldPrimary, width: 1.5),
                    ),
                  ),
                  onSubmitted: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.check_circle, color: LuxuryTheme.emeraldPrimary),
                tooltip: 'Plot Function',
                onPressed: () => setState(() {}),
              ),
            ],
          ),
        ),

        // Quick Preset chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: _presets.map((preset) {
              final isCurrent = _fnController.text == preset;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text(preset),
                  selected: isCurrent,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _fnController.text = preset;
                      });
                    }
                  },
                  selectedColor: LuxuryTheme.emeraldDark,
                  backgroundColor: LuxuryTheme.surfaceCard,
                  labelStyle: TextStyle(
                    color: isCurrent ? LuxuryTheme.emeraldBright : LuxuryTheme.textMuted,
                    fontSize: 12,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isCurrent ? LuxuryTheme.emeraldPrimary : LuxuryTheme.borderMuted,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // Graph Canvas with Gestures
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF070B09),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: LuxuryTheme.borderGlowing, width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // Animated canvas painter
                  AnimatedBuilder(
                    animation: _animController,
                    builder: (context, child) {
                      return GestureDetector(
                        onPanUpdate: (details) {
                          _pan(
                            -details.delta.dx / 300,
                            -details.delta.dy / 300,
                          );
                        },
                        child: MouseRegion(
                          onHover: (event) {
                            setState(() {
                              _hoverOffset = event.localPosition;
                            });
                          },
                          onExit: (_) {
                            setState(() {
                              _hoverOffset = null;
                              _inspectedX = null;
                              _inspectedY = null;
                            });
                          },
                          child: CustomPaint(
                            painter: _GraphPainter(
                              functionString: _fnController.text,
                              xMin: _xMin,
                              xMax: _xMax,
                              yMin: _yMin,
                              yMax: _yMax,
                              hoverOffset: _hoverOffset,
                              animPhase: _animController.value,
                              onPointInspected: (x, y) {
                                _inspectedX = x;
                                _inspectedY = y;
                              },
                            ),
                            size: Size.infinite,
                          ),
                        ),
                      );
                    },
                  ),

                  // Inspection coordinates overlay
                  if (_inspectedX != null && _inspectedY != null)
                    Positioned(
                      top: 14,
                      left: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: LuxuryTheme.surfaceDark.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: LuxuryTheme.emeraldPrimary, width: 1),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Coordinate: ',
                              style: TextStyle(color: LuxuryTheme.textMuted, fontSize: 12),
                            ),
                            Text(
                              '(${_inspectedX!.toStringAsFixed(3)}, ${_inspectedY!.toStringAsFixed(3)})',
                              style: TextStyle(
                                color: LuxuryTheme.emeraldBright,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Control overlay buttons (Zoom in/out, Reset view)
                  Positioned(
                    right: 14,
                    bottom: 14,
                    child: Container(
                      decoration: BoxDecoration(
                        color: LuxuryTheme.surfaceDark.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: LuxuryTheme.borderMuted),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.add, color: LuxuryTheme.emeraldPrimary, size: 20),
                            tooltip: 'Zoom In',
                            onPressed: () => _zoom(0.8),
                          ),
                          Container(width: 1, height: 20, color: LuxuryTheme.borderMuted),
                          IconButton(
                            icon: Icon(Icons.remove, color: LuxuryTheme.emeraldPrimary, size: 20),
                            tooltip: 'Zoom Out',
                            onPressed: () => _zoom(1.25),
                          ),
                          Container(width: 1, height: 20, color: LuxuryTheme.borderMuted),
                          IconButton(
                            icon: Icon(Icons.center_focus_strong, color: LuxuryTheme.goldPrimary, size: 20),
                            tooltip: 'Reset Origin (0,0)',
                            onPressed: _resetView,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GraphPainter extends CustomPainter {
  final String functionString;
  final double xMin;
  final double xMax;
  final double yMin;
  final double yMax;
  final Offset? hoverOffset;
  final double animPhase;
  final void Function(double x, double y) onPointInspected;

  _GraphPainter({
    required this.functionString,
    required this.xMin,
    required this.xMax,
    required this.yMin,
    required this.yMax,
    required this.hoverOffset,
    required this.animPhase,
    required this.onPointInspected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Coordinate transforms
    double toScreenX(double x) => ((x - xMin) / (xMax - xMin)) * width;
    double toScreenY(double y) => height - ((y - yMin) / (yMax - yMin)) * height;
    double toMathX(double px) => xMin + (px / width) * (xMax - xMin);

    // 1. Draw Grid Lines
    final gridPaint = Paint()
      ..color = const Color(0xFF131F17)
      ..strokeWidth = 1.0;

    final stepX = _calculateGridStep(xMax - xMin);
    final startX = (xMin / stepX).floor() * stepX;
    for (double x = startX; x <= xMax; x += stepX) {
      final sx = toScreenX(x);
      canvas.drawLine(Offset(sx, 0), Offset(sx, height), gridPaint);
    }

    final stepY = _calculateGridStep(yMax - yMin);
    final startY = (yMin / stepY).floor() * stepY;
    for (double y = startY; y <= yMax; y += stepY) {
      final sy = toScreenY(y);
      canvas.drawLine(Offset(0, sy), Offset(width, sy), gridPaint);
    }

    // 2. Draw Main Axes (Champagne Gold)
    final axisPaint = Paint()
      ..color = LuxuryTheme.goldWarm.withOpacity(0.8)
      ..strokeWidth = 1.8;

    final originX = toScreenX(0);
    final originY = toScreenY(0);

    // Y Axis (x=0)
    if (originX >= 0 && originX <= width) {
      canvas.drawLine(Offset(originX, 0), Offset(originX, height), axisPaint);
    }
    // X Axis (y=0)
    if (originY >= 0 && originY <= height) {
      canvas.drawLine(Offset(0, originY), Offset(width, originY), axisPaint);
    }

    // 3. Evaluate & Draw Function Curve
    Expression? expression;
    try {
      final parser = ShuntingYardParser();
      String prep = functionString.replaceAll('^', '^');
      prep = prep.replaceAll('×', '*').replaceAll('÷', '/');
      expression = parser.parse(prep);
    } catch (_) {
      expression = null;
    }

    if (expression != null) {
      final curvePaint = Paint()
        ..color = LuxuryTheme.emeraldPrimary
        ..strokeWidth = 2.8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final glowPaint = Paint()
        ..color = LuxuryTheme.emeraldPrimary.withOpacity(0.3)
        ..strokeWidth = 6.0
        ..style = PaintingStyle.stroke;

      final path = Path();
      bool firstPoint = true;
      final int segments = 220;
      final double dx = (xMax - xMin) / segments;
      final cm = ContextModel();

      for (int i = 0; i <= segments; i++) {
        final mathX = xMin + i * dx;
        cm.bindVariable(Variable('x'), Number(mathX));
        try {
          final evalY = expression.evaluate(EvaluationType.REAL, cm) as double;
          if (evalY.isFinite) {
            final sx = toScreenX(mathX);
            final sy = toScreenY(evalY);

            if (sy >= -100 && sy <= height + 100) {
              if (firstPoint) {
                path.moveTo(sx, sy);
                firstPoint = false;
              } else {
                path.lineTo(sx, sy);
              }
            } else {
              firstPoint = true;
            }
          } else {
            firstPoint = true;
          }
        } catch (_) {
          firstPoint = true;
        }
      }

      // Draw curve with glow
      canvas.drawPath(path, glowPaint);
      canvas.drawPath(path, curvePaint);

      // 4. Hover / Tap Inspection Crosshair
      if (hoverOffset != null) {
        final hoverMathX = toMathX(hoverOffset!.dx);
        cm.bindVariable(Variable('x'), Number(hoverMathX));
        try {
          final hoverMathY = expression.evaluate(EvaluationType.REAL, cm) as double;
          if (hoverMathY.isFinite) {
            final ptX = toScreenX(hoverMathX);
            final ptY = toScreenY(hoverMathY);

            // Crosshair lines
            final crosshairPaint = Paint()
              ..color = LuxuryTheme.textMuted.withOpacity(0.5)
              ..strokeWidth = 1.0
              ..style = PaintingStyle.stroke;

            canvas.drawLine(Offset(ptX, 0), Offset(ptX, height), crosshairPaint);
            canvas.drawLine(Offset(0, ptY), Offset(width, ptY), crosshairPaint);

            // Glowing dot on function
            final dotPaint = Paint()..color = LuxuryTheme.goldPrimary;
            final dotGlow = Paint()..color = LuxuryTheme.goldPrimary.withOpacity(0.4);

            canvas.drawCircle(Offset(ptX, ptY), 8, dotGlow);
            canvas.drawCircle(Offset(ptX, ptY), 4.5, dotPaint);

            onPointInspected(hoverMathX, hoverMathY);
          }
        } catch (_) {}
      }
    }
  }

  double _calculateGridStep(double range) {
    if (range <= 2) return 0.2;
    if (range <= 5) return 0.5;
    if (range <= 15) return 1.0;
    if (range <= 30) return 2.0;
    if (range <= 70) return 5.0;
    return 10.0;
  }

  @override
  bool shouldRepaint(covariant _GraphPainter oldDelegate) {
    return oldDelegate.functionString != functionString ||
        oldDelegate.xMin != xMin ||
        oldDelegate.xMax != xMax ||
        oldDelegate.yMin != yMin ||
        oldDelegate.yMax != yMax ||
        oldDelegate.hoverOffset != hoverOffset ||
        oldDelegate.animPhase != animPhase;
  }
}
