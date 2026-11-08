import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/matrix_model.dart';
import '../theme/luxury_theme.dart';
import '../widgets/glowing_badge.dart';

class MatrixScreen extends StatefulWidget {
  const MatrixScreen({super.key});

  @override
  State<MatrixScreen> createState() => _MatrixScreenState();
}

class _MatrixScreenState extends State<MatrixScreen> {
  int _dim = 2; // 2x2 or 3x3
  bool _isVectorMode = false;

  late MatrixModel _matA;
  late MatrixModel _matB;
  MatrixModel? _resultMatrix;
  String? _scalarResult;

  // Vectors 3D
  final List<double> _vecU = [1.0, 2.0, 3.0];
  final List<double> _vecV = [4.0, 5.0, 6.0];
  String? _vectorResultText;

  @override
  void initState() {
    super.initState();
    _resetMatrices();
  }

  void _resetMatrices() {
    _matA = MatrixModel(_dim, _dim);
    _matB = MatrixModel(_dim, _dim);
    if (_dim == 2) {
      _matA.data[0][0] = 4; _matA.data[0][1] = 7;
      _matA.data[1][0] = 2; _matA.data[1][1] = 6;

      _matB.data[0][0] = 1; _matB.data[0][1] = 0;
      _matB.data[1][0] = 3; _matB.data[1][1] = 5;
    } else {
      _matA.data[0][0] = 1; _matA.data[0][1] = 2; _matA.data[0][2] = 3;
      _matA.data[1][0] = 0; _matA.data[1][1] = 1; _matA.data[1][2] = 4;
      _matA.data[2][0] = 5; _matA.data[2][1] = 6; _matA.data[2][2] = 0;

      _matB.data[0][0] = 2; _matB.data[0][1] = 0; _matB.data[0][2] = -1;
      _matB.data[1][0] = 1; _matB.data[1][1] = 3; _matB.data[1][2] = 2;
      _matB.data[2][0] = 0; _matB.data[2][1] = -2; _matB.data[2][2] = 1;
    }
    _resultMatrix = null;
    _scalarResult = null;
  }

  void _opAdd() {
    setState(() {
      _resultMatrix = _matA.add(_matB);
      _scalarResult = null;
    });
  }

  void _opSub() {
    setState(() {
      _resultMatrix = _matA.subtract(_matB);
      _scalarResult = null;
    });
  }

  void _opMul() {
    setState(() {
      _resultMatrix = _matA.multiply(_matB);
      _scalarResult = null;
    });
  }

  void _opDet() {
    setState(() {
      final d = _matA.determinant();
      _scalarResult = 'det(A) = ${d.toStringAsFixed(4).replaceAll(RegExp(r'\.?0+$'), '')}';
      _resultMatrix = null;
    });
  }

  void _opInv() {
    setState(() {
      final inv = _matA.inverse();
      if (inv == null) {
        _scalarResult = 'Matrix A is Singular (det = 0, no inverse)';
        _resultMatrix = null;
      } else {
        _resultMatrix = inv;
        _scalarResult = 'A⁻¹ (Inverse Matrix)';
      }
    });
  }

  void _opTranspose() {
    setState(() {
      _resultMatrix = _matA.transpose();
      _scalarResult = 'Aᵀ (Transpose)';
    });
  }

  void _opTrace() {
    setState(() {
      final tr = _matA.trace();
      _scalarResult = 'Trace tr(A) = $tr';
      _resultMatrix = null;
    });
  }

  void _opEigenvalues() {
    if (_dim != 2) {
      setState(() {
        _scalarResult = 'Eigenvalues currently computed for 2x2 matrices';
        _resultMatrix = null;
      });
      return;
    }
    setState(() {
      final ev = _matA.eigenvalues2x2();
      _scalarResult = 'Eigenvalues: λ₁ = ${ev[0]},  λ₂ = ${ev[1]}';
      _resultMatrix = null;
    });
  }

  // Vector ops
  void _vecDot() {
    final dot = _vecU[0] * _vecV[0] + _vecU[1] * _vecV[1] + _vecU[2] * _vecV[2];
    setState(() {
      _vectorResultText = 'Dot Product u · v = $dot';
    });
  }

  void _vecCross() {
    final cx = _vecU[1] * _vecV[2] - _vecU[2] * _vecV[1];
    final cy = _vecU[2] * _vecV[0] - _vecU[0] * _vecV[2];
    final cz = _vecU[0] * _vecV[1] - _vecU[1] * _vecV[0];
    setState(() {
      _vectorResultText = 'Cross Product u × v = [$cx, $cy, $cz]';
    });
  }

  void _vecNorm() {
    final normU = math.sqrt(_vecU[0] * _vecU[0] + _vecU[1] * _vecU[1] + _vecU[2] * _vecU[2]);
    final normV = math.sqrt(_vecV[0] * _vecV[0] + _vecV[1] * _vecV[1] + _vecV[2] * _vecV[2]);
    setState(() {
      _vectorResultText =
          '|u| = ${normU.toStringAsFixed(4)}    |v| = ${normV.toStringAsFixed(4)}';
    });
  }

  void _vecAngle() {
    final dot = _vecU[0] * _vecV[0] + _vecU[1] * _vecV[1] + _vecU[2] * _vecV[2];
    final normU = math.sqrt(_vecU[0] * _vecU[0] + _vecU[1] * _vecU[1] + _vecU[2] * _vecU[2]);
    final normV = math.sqrt(_vecV[0] * _vecV[0] + _vecV[1] * _vecV[1] + _vecV[2] * _vecV[2]);
    final cosTheta = dot / (normU * normV);
    final rad = math.acos(cosTheta.clamp(-1.0, 1.0));
    final deg = rad * 180 / math.pi;
    setState(() {
      _vectorResultText = 'Angle θ = ${deg.toStringAsFixed(2)}° (${rad.toStringAsFixed(3)} rad)';
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sub-mode tabs: Matrix vs Vector
          Row(
            children: [
              GlowingBadge(
                text: 'MATRIX ENGINE',
                isActive: !_isVectorMode,
                activeColor: LuxuryTheme.emeraldPrimary,
                onTap: () => setState(() => _isVectorMode = false),
              ),
              const SizedBox(width: 8),
              GlowingBadge(
                text: 'VECTOR (3D)',
                isActive: _isVectorMode,
                activeColor: LuxuryTheme.goldPrimary,
                onTap: () => setState(() => _isVectorMode = true),
              ),
              const Spacer(),
              if (!_isVectorMode) ...[
                ChoiceChip(
                  label: const Text('2×2'),
                  selected: _dim == 2,
                  onSelected: (val) {
                    if (val) {
                      setState(() {
                        _dim = 2;
                        _resetMatrices();
                      });
                    }
                  },
                  selectedColor: LuxuryTheme.emeraldDark,
                  backgroundColor: LuxuryTheme.surfaceCard,
                  labelStyle: TextStyle(
                    color: _dim == 2 ? LuxuryTheme.emeraldBright : LuxuryTheme.textMuted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 6),
                ChoiceChip(
                  label: const Text('3×3'),
                  selected: _dim == 3,
                  onSelected: (val) {
                    if (val) {
                      setState(() {
                        _dim = 3;
                        _resetMatrices();
                      });
                    }
                  },
                  selectedColor: LuxuryTheme.emeraldDark,
                  backgroundColor: LuxuryTheme.surfaceCard,
                  labelStyle: TextStyle(
                    color: _dim == 3 ? LuxuryTheme.emeraldBright : LuxuryTheme.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),

          if (!_isVectorMode) ...[
            // Matrices inputs row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildMatrixCard('Matrix A', _matA, LuxuryTheme.emeraldPrimary)),
                const SizedBox(width: 10),
                Expanded(child: _buildMatrixCard('Matrix B', _matB, LuxuryTheme.goldPrimary)),
              ],
            ),
            const SizedBox(height: 12),

            // Operation Action Buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildActionChip('A + B', _opAdd),
                _buildActionChip('A - B', _opSub),
                _buildActionChip('A × B', _opMul),
                _buildActionChip('det(A)', _opDet),
                _buildActionChip('A⁻¹', _opInv),
                _buildActionChip('Aᵀ', _opTranspose),
                _buildActionChip('tr(A)', _opTrace),
                if (_dim == 2) _buildActionChip('λ Eigenvalues', _opEigenvalues),
              ],
            ),
            const SizedBox(height: 14),

            // Result Display Card
            _buildResultCard(),
          ] else ...[
            // Vector Mode 3D
            _buildVectorCard('Vector u', _vecU, LuxuryTheme.emeraldPrimary),
            const SizedBox(height: 10),
            _buildVectorCard('Vector v', _vecV, LuxuryTheme.goldPrimary),
            const SizedBox(height: 14),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildActionChip('Dot u · v', _vecDot),
                _buildActionChip('Cross u × v', _vecCross),
                _buildActionChip('Norms |u|, |v|', _vecNorm),
                _buildActionChip('Angle θ', _vecAngle),
              ],
            ),
            const SizedBox(height: 14),

            if (_vectorResultText != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: LuxuryTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: LuxuryTheme.goldWarm, width: 1.2),
                ),
                child: Text(
                  _vectorResultText!,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: LuxuryTheme.emeraldBright,
                    fontFamily: 'monospace',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildMatrixCard(String title, MatrixModel mat, Color accent) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: LuxuryTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          for (int r = 0; r < _dim; r++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  for (int c = 0; c < _dim; c++)
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        child: TextFormField(
                          initialValue: mat.data[r][c].toString().replaceAll(RegExp(r'\.0$'), ''),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                          style: TextStyle(
                            color: LuxuryTheme.textBright,
                            fontSize: 13,
                            fontFamily: 'monospace',
                          ),
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 8),
                            filled: true,
                            fillColor: LuxuryTheme.surfaceDark,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: LuxuryTheme.borderMuted),
                            ),
                          ),
                          onChanged: (val) {
                            final d = double.tryParse(val) ?? 0.0;
                            mat.data[r][c] = d;
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVectorCard(String title, List<double> vec, Color accent) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: LuxuryTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: accent, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (int i = 0; i < 3; i++)
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    child: TextFormField(
                      initialValue: vec[i].toString().replaceAll(RegExp(r'\.0$'), ''),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      style: TextStyle(
                        color: LuxuryTheme.textBright,
                        fontSize: 14,
                        fontFamily: 'monospace',
                      ),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        isDense: true,
                        labelText: ['x', 'y', 'z'][i],
                        labelStyle: TextStyle(color: LuxuryTheme.textMuted, fontSize: 11),
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        filled: true,
                        fillColor: LuxuryTheme.surfaceDark,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (val) {
                        vec[i] = double.tryParse(val) ?? 0.0;
                      },
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip(String label, VoidCallback onTap) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: LuxuryTheme.surfaceDark,
      side: BorderSide(color: LuxuryTheme.emeraldMuted),
      labelStyle: TextStyle(
        color: LuxuryTheme.emeraldBright,
        fontWeight: FontWeight.bold,
        fontSize: 13,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    );
  }

  Widget _buildResultCard() {
    if (_resultMatrix == null && _scalarResult == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: LuxuryTheme.surfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: LuxuryTheme.borderMuted),
        ),
        child: Center(
          child: Text(
            'Select an operation above to view matrix results',
            style: TextStyle(color: LuxuryTheme.textMuted, fontSize: 13),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LuxuryTheme.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: LuxuryTheme.emeraldPrimary, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: LuxuryTheme.emeraldSubtle,
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        children: [
          if (_scalarResult != null)
            Text(
              _scalarResult!,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: LuxuryTheme.goldPrimary,
                fontFamily: 'monospace',
              ),
              textAlign: TextAlign.center,
            ),
          if (_resultMatrix != null) ...[
            const SizedBox(height: 8),
            for (int r = 0; r < _resultMatrix!.rows; r++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int c = 0; c < _resultMatrix!.cols; c++)
                      Container(
                        width: 70,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: LuxuryTheme.surfaceDark,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: LuxuryTheme.borderMuted),
                        ),
                        child: Text(
                          _formatNum(_resultMatrix!.data[r][c]),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: LuxuryTheme.emeraldBright,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  String _formatNum(double d) {
    if (d == d.roundToDouble()) return d.toInt().toString();
    return d.toStringAsFixed(3).replaceAll(RegExp(r'\.?0+$'), '');
  }
}
