import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/luxury_theme.dart';
import '../widgets/glowing_badge.dart';

class SolverScreen extends StatefulWidget {
  const SolverScreen({super.key});

  @override
  State<SolverScreen> createState() => _SolverScreenState();
}

class _SolverScreenState extends State<SolverScreen> {
  int _solverType = 0; // 0 = Quadratic, 1 = Linear 2x2, 2 = Linear 3x3, 3 = Cubic

  // Quadratic inputs: ax² + bx + c = 0
  double _qa = 1.0, _qb = -5.0, _qc = 6.0;
  Map<String, dynamic>? _quadResult;

  // Linear 2x2 inputs:
  // a1*x + b1*y = c1
  // a2*x + b2*y = c2
  double _l_a1 = 2.0, _l_b1 = 3.0, _l_c1 = 8.0;
  double _l_a2 = 1.0, _l_b2 = -1.0, _l_c2 = -1.0;
  Map<String, dynamic>? _linearResult;

  // Linear 3x3 inputs:
  // a1*x + b1*y + c1*z = d1
  // a2*x + b2*y + c2*z = d2
  // a3*x + b3*y + c3*z = d3
  double _m_a1 = 1, _m_b1 = 2, _m_c1 = -1, _m_d1 = 2;
  double _m_a2 = 2, _m_b2 = -1, _m_c2 = 1, _m_d2 = 3;
  double _m_a3 = 3, _m_b3 = 1, _m_c3 = -2, _m_d3 = 1;
  Map<String, dynamic>? _linear3x3Result;

  // Cubic inputs: ax³ + bx² + cx + d = 0
  double _ca = 1.0, _cb = -6.0, _cc = 11.0, _cd = -6.0;
  Map<String, dynamic>? _cubicResult;

  @override
  void initState() {
    super.initState();
    _solveQuadratic();
  }

  void _solveQuadratic() {
    if (_qa == 0) {
      if (_qb == 0) {
        setState(() {
          _quadResult = {'type': 'Degenerate', 'text': _qc == 0 ? 'Infinite solutions' : 'No solution'};
        });
      } else {
        final r = -_qc / _qb;
        setState(() {
          _quadResult = {
            'type': 'Linear Solution',
            'roots': ['x = ${_format(r)}'],
            'disc': null,
          };
        });
      }
      return;
    }

    final d = _qb * _qb - 4 * _qa * _qc;
    final h = -_qb / (2 * _qa);
    final k = _qc - (_qb * _qb) / (4 * _qa);

    if (d > 0) {
      final r1 = (-_qb + math.sqrt(d)) / (2 * _qa);
      final r2 = (-_qb - math.sqrt(d)) / (2 * _qa);
      setState(() {
        _quadResult = {
          'type': 'Two Real Distinct Roots',
          'roots': ['x₁ = ${_format(r1)}', 'x₂ = ${_format(r2)}'],
          'disc': d,
          'vertex': '(${_format(h)}, ${_format(k)})',
        };
      });
    } else if (d == 0) {
      final r = -_qb / (2 * _qa);
      setState(() {
        _quadResult = {
          'type': 'One Repeated Real Root',
          'roots': ['x = ${_format(r)}'],
          'disc': d,
          'vertex': '(${_format(h)}, ${_format(k)})',
        };
      });
    } else {
      final real = -_qb / (2 * _qa);
      final imag = math.sqrt(-d) / (2 * _qa.abs());
      setState(() {
        _quadResult = {
          'type': 'Two Complex Conjugate Roots',
          'roots': [
            'x₁ = ${_format(real)} + ${_format(imag)} i',
            'x₂ = ${_format(real)} - ${_format(imag)} i',
          ],
          'disc': d,
          'vertex': '(${_format(h)}, ${_format(k)})',
        };
      });
    }
  }

  void _solveLinear() {
    final det = _l_a1 * _l_b2 - _l_b1 * _l_a2;
    if (det.abs() < 1e-12) {
      final detX = _l_c1 * _l_b2 - _l_b1 * _l_c2;
      setState(() {
        _linearResult = {
          'type': detX.abs() < 1e-12 ? 'Infinite Solutions' : 'No Solution (Parallel lines)',
        };
      });
      return;
    }

    final detX = _l_c1 * _l_b2 - _l_b1 * _l_c2;
    final detY = _l_a1 * _l_c2 - _l_c1 * _l_a2;
    final x = detX / det;
    final y = detY / det;

    setState(() {
      _linearResult = {
        'type': 'Unique Solution (Cramer’s Rule)',
        'x': _format(x),
        'y': _format(y),
        'det': _format(det),
      };
    });
  }

  double _det3(
    double a, double b, double c,
    double d, double e, double f,
    double g, double h, double i,
  ) {
    return a * (e * i - f * h) - b * (d * i - f * g) + c * (d * h - e * g);
  }

  void _solveLinear3x3() {
    final d = _det3(
      _m_a1, _m_b1, _m_c1,
      _m_a2, _m_b2, _m_c2,
      _m_a3, _m_b3, _m_c3,
    );

    if (d.abs() < 1e-12) {
      setState(() {
        _linear3x3Result = {'type': 'Degenerate System (Determinant = 0)'};
      });
      return;
    }

    final dx = _det3(
      _m_d1, _m_b1, _m_c1,
      _m_d2, _m_b2, _m_c2,
      _m_d3, _m_b3, _m_c3,
    );
    final dy = _det3(
      _m_a1, _m_d1, _m_c1,
      _m_a2, _m_d2, _m_c2,
      _m_a3, _m_d3, _m_c3,
    );
    final dz = _det3(
      _m_a1, _m_b1, _m_d1,
      _m_a2, _m_b2, _m_d2,
      _m_a3, _m_b3, _m_d3,
    );

    setState(() {
      _linear3x3Result = {
        'type': 'Unique 3D Solution (3×3 Cramer’s Rule)',
        'x': _format(dx / d),
        'y': _format(dy / d),
        'z': _format(dz / d),
        'det': _format(d),
      };
    });
  }

  void _solveCubic() {
    if (_ca == 0) {
      _solveQuadratic();
      return;
    }
    // Cardano-Vieta formula for ax³ + bx² + cx + d = 0
    final a = _ca, b = _cb / a, c = _cc / a, d = _cd / a;
    final p = c - (b * b) / 3.0;
    final q = (2.0 * b * b * b) / 27.0 - (b * c) / 3.0 + d;
    final disc = (q * q) / 4.0 + (p * p * p) / 27.0;

    List<String> roots = [];
    if (disc > 0) {
      // One real root and two complex conjugate
      final u = _cbrt(-q / 2.0 + math.sqrt(disc));
      final v = _cbrt(-q / 2.0 - math.sqrt(disc));
      final r1 = (u + v) - b / 3.0;
      final realPart = -(u + v) / 2.0 - b / 3.0;
      final imagPart = (math.sqrt(3.0) / 2.0) * (u - v).abs();
      roots = [
        'x₁ = ${_format(r1)}',
        'x₂ = ${_format(realPart)} + ${_format(imagPart)}i',
        'x₃ = ${_format(realPart)} - ${_format(imagPart)}i',
      ];
    } else if (disc == 0) {
      // Multiple real roots
      final u = _cbrt(-q / 2.0);
      final r1 = 2.0 * u - b / 3.0;
      final r2 = -u - b / 3.0;
      roots = [
        'x₁ = ${_format(r1)}',
        'x₂ = x₃ = ${_format(r2)}',
      ];
    } else {
      // Three distinct real roots (casus irreducibilis)
      final r = math.sqrt(-(p * p * p) / 27.0);
      final phi = math.acos((-q / (2.0 * r)).clamp(-1.0, 1.0));
      final m = 2.0 * _cbrt(r);
      final r1 = m * math.cos(phi / 3.0) - b / 3.0;
      final r2 = m * math.cos((phi + 2.0 * math.pi) / 3.0) - b / 3.0;
      final r3 = m * math.cos((phi + 4.0 * math.pi) / 3.0) - b / 3.0;
      roots = [
        'x₁ = ${_format(r1)}',
        'x₂ = ${_format(r2)}',
        'x₃ = ${_format(r3)}',
      ];
    }

    setState(() {
      _cubicResult = {
        'type': 'Cubic Polynomial Roots (Cardano’s Algorithm)',
        'roots': roots,
        'disc': disc,
      };
    });
  }

  double _cbrt(double x) {
    if (x < 0) return -math.pow(-x, 1.0 / 3.0).toDouble();
    return math.pow(x, 1.0 / 3.0).toDouble();
  }

  String _format(double v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(4).replaceAll(RegExp(r'\.?0+$'), '');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Solver Type Badges
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                GlowingBadge(
                  text: 'QUADRATIC (2°)',
                  isActive: _solverType == 0,
                  activeColor: LuxuryTheme.emeraldPrimary,
                  onTap: () {
                    setState(() => _solverType = 0);
                    _solveQuadratic();
                  },
                ),
                const SizedBox(width: 8),
                GlowingBadge(
                  text: 'CUBIC (3°)',
                  isActive: _solverType == 3,
                  activeColor: LuxuryTheme.goldPrimary,
                  onTap: () {
                    setState(() => _solverType = 3);
                    _solveCubic();
                  },
                ),
                const SizedBox(width: 8),
                GlowingBadge(
                  text: 'LINEAR (2×2)',
                  isActive: _solverType == 1,
                  activeColor: LuxuryTheme.emeraldPrimary,
                  onTap: () {
                    setState(() => _solverType = 1);
                    _solveLinear();
                  },
                ),
                const SizedBox(width: 8),
                GlowingBadge(
                  text: 'SYSTEM (3×3)',
                  isActive: _solverType == 2,
                  activeColor: LuxuryTheme.goldPrimary,
                  onTap: () {
                    setState(() => _solverType = 2);
                    _solveLinear3x3();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (_solverType == 0) ...[
            // Quadratic Form
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: LuxuryTheme.surfaceCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: LuxuryTheme.borderGlowing),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Coefficients: a·x² + b·x + c = 0',
                    style: TextStyle(
                      color: LuxuryTheme.goldWarm,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildNumInput('a', _qa, (v) { _qa = v; _solveQuadratic(); }),
                      const SizedBox(width: 10),
                      _buildNumInput('b', _qb, (v) { _qb = v; _solveQuadratic(); }),
                      const SizedBox(width: 10),
                      _buildNumInput('c', _qc, (v) { _qc = v; _solveQuadratic(); }),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (_quadResult != null)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: LuxuryTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: LuxuryTheme.emeraldPrimary, width: 1.2),
                  boxShadow: [
                    BoxShadow(color: LuxuryTheme.emeraldSubtle, blurRadius: 14),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle_outline, color: LuxuryTheme.emeraldBright, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          _quadResult!['type'] as String,
                          style: TextStyle(
                            color: LuxuryTheme.emeraldBright,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    Divider(color: LuxuryTheme.borderMuted, height: 20),
                    if (_quadResult!['roots'] != null)
                      for (String root in (_quadResult!['roots'] as List<String>))
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            root,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: LuxuryTheme.goldPrimary,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                    if (_quadResult!['disc'] != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        'Discriminant Δ = b² - 4ac = ${_format(_quadResult!['disc'] as double)}',
                        style: TextStyle(color: LuxuryTheme.textMuted, fontSize: 13),
                      ),
                    ],
                    if (_quadResult!['vertex'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Parabola Vertex (h, k) = ${_quadResult!['vertex']}',
                        style: TextStyle(color: LuxuryTheme.textMuted, fontSize: 13),
                      ),
                    ],
                  ],
                ),
              ),
          ] else if (_solverType == 3) ...[
            // Cubic Form: ax³ + bx² + cx + d = 0
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: LuxuryTheme.surfaceCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: LuxuryTheme.borderGlowing),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cubic Form: a·x³ + b·x² + c·x + d = 0',
                    style: TextStyle(
                      color: LuxuryTheme.goldWarm,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildNumInput('a', _ca, (v) { _ca = v; _solveCubic(); }),
                      const SizedBox(width: 6),
                      _buildNumInput('b', _cb, (v) { _cb = v; _solveCubic(); }),
                      const SizedBox(width: 6),
                      _buildNumInput('c', _cc, (v) { _cc = v; _solveCubic(); }),
                      const SizedBox(width: 6),
                      _buildNumInput('d', _cd, (v) { _cd = v; _solveCubic(); }),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (_cubicResult != null)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: LuxuryTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: LuxuryTheme.goldPrimary, width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _cubicResult!['type'] as String,
                      style: TextStyle(
                        color: LuxuryTheme.goldPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Divider(color: LuxuryTheme.borderMuted, height: 16),
                    for (String root in (_cubicResult!['roots'] as List<String>))
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          root,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: LuxuryTheme.emeraldBright,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ] else if (_solverType == 1) ...[
            // Linear 2x2 Form
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: LuxuryTheme.surfaceCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: LuxuryTheme.borderGlowing),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'System of 2 Linear Equations:',
                    style: TextStyle(
                      color: LuxuryTheme.goldWarm,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildNumInput('a₁', _l_a1, (v) { _l_a1 = v; _solveLinear(); }),
                      const SizedBox(width: 6),
                      Text('x +', style: TextStyle(color: LuxuryTheme.textMuted)),
                      const SizedBox(width: 6),
                      _buildNumInput('b₁', _l_b1, (v) { _l_b1 = v; _solveLinear(); }),
                      const SizedBox(width: 6),
                      Text('y =', style: TextStyle(color: LuxuryTheme.textMuted)),
                      const SizedBox(width: 6),
                      _buildNumInput('c₁', _l_c1, (v) { _l_c1 = v; _solveLinear(); }),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildNumInput('a₂', _l_a2, (v) { _l_a2 = v; _solveLinear(); }),
                      const SizedBox(width: 6),
                      Text('x +', style: TextStyle(color: LuxuryTheme.textMuted)),
                      const SizedBox(width: 6),
                      _buildNumInput('b₂', _l_b2, (v) { _l_b2 = v; _solveLinear(); }),
                      const SizedBox(width: 6),
                      Text('y =', style: TextStyle(color: LuxuryTheme.textMuted)),
                      const SizedBox(width: 6),
                      _buildNumInput('c₂', _l_c2, (v) { _l_c2 = v; _solveLinear(); }),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (_linearResult != null)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: LuxuryTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: LuxuryTheme.goldPrimary, width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _linearResult!['type'] as String,
                      style: TextStyle(
                        color: LuxuryTheme.emeraldBright,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Divider(color: LuxuryTheme.borderMuted, height: 16),
                    if (_linearResult!['x'] != null) ...[
                      Text(
                        'x = ${_linearResult!['x']}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: LuxuryTheme.goldPrimary,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'y = ${_linearResult!['y']}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: LuxuryTheme.emeraldBright,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Determinant D = ${_linearResult!['det']}',
                        style: TextStyle(color: LuxuryTheme.textMuted, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
          ] else ...[
            // Linear 3x3 Form
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: LuxuryTheme.surfaceCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: LuxuryTheme.borderGlowing),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'System of 3 Equations (3 Unknowns):',
                    style: TextStyle(
                      color: LuxuryTheme.goldWarm,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Eq 1
                  Row(
                    children: [
                      _buildNumInput('a₁', _m_a1, (v) { _m_a1 = v; _solveLinear3x3(); }),
                      const SizedBox(width: 4),
                      _buildNumInput('b₁', _m_b1, (v) { _m_b1 = v; _solveLinear3x3(); }),
                      const SizedBox(width: 4),
                      _buildNumInput('c₁', _m_c1, (v) { _m_c1 = v; _solveLinear3x3(); }),
                      const SizedBox(width: 4),
                      Text('=', style: TextStyle(color: LuxuryTheme.textMuted)),
                      const SizedBox(width: 4),
                      _buildNumInput('d₁', _m_d1, (v) { _m_d1 = v; _solveLinear3x3(); }),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Eq 2
                  Row(
                    children: [
                      _buildNumInput('a₂', _m_a2, (v) { _m_a2 = v; _solveLinear3x3(); }),
                      const SizedBox(width: 4),
                      _buildNumInput('b₂', _m_b2, (v) { _m_b2 = v; _solveLinear3x3(); }),
                      const SizedBox(width: 4),
                      _buildNumInput('c₂', _m_c2, (v) { _m_c2 = v; _solveLinear3x3(); }),
                      const SizedBox(width: 4),
                      Text('=', style: TextStyle(color: LuxuryTheme.textMuted)),
                      const SizedBox(width: 4),
                      _buildNumInput('d₂', _m_d2, (v) { _m_d2 = v; _solveLinear3x3(); }),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Eq 3
                  Row(
                    children: [
                      _buildNumInput('a₃', _m_a3, (v) { _m_a3 = v; _solveLinear3x3(); }),
                      const SizedBox(width: 4),
                      _buildNumInput('b₃', _m_b3, (v) { _m_b3 = v; _solveLinear3x3(); }),
                      const SizedBox(width: 4),
                      _buildNumInput('c₃', _m_c3, (v) { _m_c3 = v; _solveLinear3x3(); }),
                      const SizedBox(width: 4),
                      Text('=', style: TextStyle(color: LuxuryTheme.textMuted)),
                      const SizedBox(width: 4),
                      _buildNumInput('d₃', _m_d3, (v) { _m_d3 = v; _solveLinear3x3(); }),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (_linear3x3Result != null)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: LuxuryTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: LuxuryTheme.emeraldPrimary, width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _linear3x3Result!['type'] as String,
                      style: TextStyle(
                        color: LuxuryTheme.emeraldBright,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Divider(color: LuxuryTheme.borderMuted, height: 16),
                    if (_linear3x3Result!['x'] != null) ...[
                      Text(
                        'x = ${_linear3x3Result!['x']}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: LuxuryTheme.goldPrimary,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'y = ${_linear3x3Result!['y']}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: LuxuryTheme.emeraldBright,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'z = ${_linear3x3Result!['z']}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: LuxuryTheme.goldWarm,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Determinant D = ${_linear3x3Result!['det']}',
                        style: TextStyle(color: LuxuryTheme.textMuted, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildNumInput(String label, double initialVal, ValueChanged<double> onChanged) {
    return Expanded(
      child: TextFormField(
        initialValue: _format(initialVal),
        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
        textAlign: TextAlign.center,
        style: TextStyle(
          color: LuxuryTheme.textBright,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: LuxuryTheme.emeraldPrimary, fontSize: 11),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          filled: true,
          fillColor: LuxuryTheme.surfaceDark,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: LuxuryTheme.borderMuted),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: LuxuryTheme.emeraldPrimary),
          ),
        ),
        onChanged: (val) {
          final parsed = double.tryParse(val) ?? 0.0;
          onChanged(parsed);
        },
      ),
    );
  }
}
