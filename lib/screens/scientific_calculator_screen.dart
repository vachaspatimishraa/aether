import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/calculation_history.dart';
import '../services/expression_evaluator.dart';
import '../theme/luxury_theme.dart';
import '../widgets/animated_calculator_button.dart';
import '../widgets/constants_modal.dart';
import '../widgets/display_screen.dart';
import '../widgets/history_drawer.dart';

class ScientificCalculatorScreen extends StatefulWidget {
  final List<HistoryItem> history;
  final ValueChanged<HistoryItem> onAddHistory;
  final VoidCallback onClearHistory;

  const ScientificCalculatorScreen({
    super.key,
    required this.history,
    required this.onAddHistory,
    required this.onClearHistory,
  });

  @override
  State<ScientificCalculatorScreen> createState() => _ScientificCalculatorScreenState();
}

class _ScientificCalculatorScreenState extends State<ScientificCalculatorScreen> {
  String _expression = '';
  String? _livePreview;
  bool _isDegree = true;
  bool _is2ndMode = false;
  bool _isHypMode = false;
  double? _memoryValue;

  @override
  void initState() {
    super.initState();
  }

  void _updateLivePreview() {
    setState(() {
      _livePreview = ExpressionEvaluator.livePreview(_expression, isDegree: _isDegree);
    });
  }

  void _onInput(String str) {
    setState(() {
      _expression += str;
    });
    _updateLivePreview();
  }

  void _onBackspace() {
    if (_expression.isNotEmpty) {
      setState(() {
        // If ending with a function like "sin(", "cos(", "log(", remove the entire token
        final fnPatterns = [
          'sin(', 'cos(', 'tan(', 'asin(', 'acos(', 'atan(',
          'sinh(', 'cosh(', 'tanh(', 'asinh(', 'acosh(', 'atanh(',
          'log(', 'ln(', 'sqrt(', 'cbrt(', 'abs(', 'nCr', 'nPr'
        ];
        bool removed = false;
        for (final fn in fnPatterns) {
          if (_expression.endsWith(fn)) {
            _expression = _expression.substring(0, _expression.length - fn.length);
            removed = true;
            break;
          }
        }
        if (!removed) {
          _expression = _expression.substring(0, _expression.length - 1);
        }
      });
      _updateLivePreview();
    }
  }

  void _onClear() {
    setState(() {
      _expression = '';
      _livePreview = null;
    });
  }

  void _onEquals() {
    if (_expression.trim().isEmpty) return;
    final result = ExpressionEvaluator.evaluate(_expression, isDegree: _isDegree);
    if (result.isSuccess) {
      final historyItem = HistoryItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        expression: _expression,
        result: result.value,
        timestamp: DateTime.now(),
        category: 'Scientific',
      );
      widget.onAddHistory(historyItem);

      setState(() {
        _expression = result.value;
        _livePreview = null;
      });
      HapticFeedback.heavyImpact();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? 'Evaluation Error'),
          backgroundColor: LuxuryTheme.surfaceCardElevated,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // Memory operations
  void _memoryClear() {
    setState(() => _memoryValue = null);
    _showFeedback('Memory Cleared (MC)');
  }

  void _memoryRecall() {
    if (_memoryValue != null) {
      final valStr = ExpressionEvaluator.formatResult(_memoryValue!);
      _onInput(valStr);
      _showFeedback('Memory Recalled (MR)');
    }
  }

  void _memoryAdd() {
    final eval = ExpressionEvaluator.evaluate(_expression, isDegree: _isDegree);
    if (eval.isSuccess && eval.numericValue != null) {
      setState(() {
        _memoryValue = (_memoryValue ?? 0.0) + eval.numericValue!;
      });
      _showFeedback('Added to Memory (M+)');
    }
  }

  void _memorySubtract() {
    final eval = ExpressionEvaluator.evaluate(_expression, isDegree: _isDegree);
    if (eval.isSuccess && eval.numericValue != null) {
      setState(() {
        _memoryValue = (_memoryValue ?? 0.0) - eval.numericValue!;
      });
      _showFeedback('Subtracted from Memory (M-)');
    }
  }

  void _memoryStore() {
    final eval = ExpressionEvaluator.evaluate(_expression, isDegree: _isDegree);
    if (eval.isSuccess && eval.numericValue != null) {
      setState(() {
        _memoryValue = eval.numericValue!;
      });
      _showFeedback('Stored in Memory (MS)');
    }
  }

  void _showFeedback(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(milliseconds: 1200),
        backgroundColor: LuxuryTheme.surfaceCardElevated,
      ),
    );
  }

  void _openConstantsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ConstantsModal(
        onSelectConstant: (symbol, value) {
          _onInput(symbol);
        },
      ),
    );
  }

  void _openHistoryDrawer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => HistoryDrawer(
        history: widget.history,
        onRecallExpression: (expr) {
          setState(() {
            _expression = expr;
          });
          _updateLivePreview();
        },
        onClearHistory: widget.onClearHistory,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Display Section
        DisplayScreen(
          expression: _expression,
          liveResult: _livePreview,
          isDegree: _isDegree,
          onToggleDegree: () {
            setState(() => _isDegree = !_isDegree);
            _updateLivePreview();
          },
          hasMemory: _memoryValue != null,
          onClearMemory: _memoryClear,
          onBackspace: _onBackspace,
          onClear: _onClear,
          onOpenConstants: _openConstantsModal,
          onOpenHistory: _openHistoryDrawer,
        ),

        // Memory Register Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          child: Row(
            children: [
              _buildMemoryBtn('MC', _memoryClear),
              _buildMemoryBtn('MR', _memoryRecall),
              _buildMemoryBtn('M+', _memoryAdd),
              _buildMemoryBtn('M-', _memorySubtract),
              _buildMemoryBtn('MS', _memoryStore),
            ],
          ),
        ),

        // Main Scientific Keypad
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Column(
              children: [
                // Scientific Row 1: 2nd, Hyp, sin/asin, cos/acos, tan/atan
                Row(
                  children: [
                    Expanded(
                      child: AnimatedCalculatorButton(
                        label: '2nd',
                        variant: _is2ndMode ? ButtonVariant.action : ButtonVariant.secondary,
                        onTap: () => setState(() => _is2ndMode = !_is2ndMode),
                      ),
                    ),
                    Expanded(
                      child: AnimatedCalculatorButton(
                        label: 'hyp',
                        variant: _isHypMode ? ButtonVariant.action : ButtonVariant.secondary,
                        onTap: () => setState(() => _isHypMode = !_isHypMode),
                      ),
                    ),
                    _buildTrigButton('sin'),
                    _buildTrigButton('cos'),
                    _buildTrigButton('tan'),
                  ],
                ),

                // Scientific Row 2: ln/e^x, log/10^x, x^y / y√x, √ / x², ( / )
                Row(
                  children: [
                    Expanded(
                      child: AnimatedCalculatorButton(
                        label: _is2ndMode ? 'eˣ' : 'ln',
                        variant: ButtonVariant.action,
                        onTap: () => _onInput(_is2ndMode ? 'exp(' : 'ln('),
                      ),
                    ),
                    Expanded(
                      child: AnimatedCalculatorButton(
                        label: _is2ndMode ? '10ˣ' : 'log',
                        variant: ButtonVariant.action,
                        onTap: () => _onInput(_is2ndMode ? '10^(' : 'log('),
                      ),
                    ),
                    Expanded(
                      child: AnimatedCalculatorButton(
                        label: _is2ndMode ? '∛x' : 'xʸ',
                        variant: ButtonVariant.action,
                        onTap: () => _onInput(_is2ndMode ? '∛(' : '^'),
                      ),
                    ),
                    Expanded(
                      child: AnimatedCalculatorButton(
                        label: _is2ndMode ? 'x²' : '√',
                        variant: ButtonVariant.action,
                        onTap: () => _onInput(_is2ndMode ? '^2' : '√('),
                      ),
                    ),
                    Expanded(
                      child: AnimatedCalculatorButton(
                        label: '(',
                        variant: ButtonVariant.action,
                        onTap: () => _onInput('('),
                      ),
                    ),
                    Expanded(
                      child: AnimatedCalculatorButton(
                        label: ')',
                        variant: ButtonVariant.action,
                        onTap: () => _onInput(')'),
                      ),
                    ),
                  ],
                ),

                // Keypad Row 1: AC, ⌫, %, ÷
                Row(
                  children: [
                    Expanded(
                      child: AnimatedCalculatorButton(
                        label: 'AC',
                        variant: ButtonVariant.danger, // Warm Ochre, strictly NO RED
                        onTap: _onClear,
                      ),
                    ),
                    Expanded(
                      child: AnimatedCalculatorButton(
                        label: '⌫',
                        variant: ButtonVariant.danger, // Warm Ochre, strictly NO RED
                        onTap: _onBackspace,
                      ),
                    ),
                    Expanded(
                      child: AnimatedCalculatorButton(
                        label: _is2ndMode ? 'n!' : '%',
                        variant: ButtonVariant.operator,
                        onTap: () => _onInput(_is2ndMode ? '!' : '%'),
                      ),
                    ),
                    Expanded(
                      child: AnimatedCalculatorButton(
                        label: '÷',
                        variant: ButtonVariant.operator,
                        fontSize: 24,
                        onTap: () => _onInput('÷'),
                      ),
                    ),
                  ],
                ),

                // Keypad Row 2: 7, 8, 9, ×
                Row(
                  children: [
                    _buildNumKey('7'),
                    _buildNumKey('8'),
                    _buildNumKey('9'),
                    Expanded(
                      child: AnimatedCalculatorButton(
                        label: '×',
                        variant: ButtonVariant.operator,
                        fontSize: 24,
                        onTap: () => _onInput('×'),
                      ),
                    ),
                  ],
                ),

                // Keypad Row 3: 4, 5, 6, -
                Row(
                  children: [
                    _buildNumKey('4'),
                    _buildNumKey('5'),
                    _buildNumKey('6'),
                    Expanded(
                      child: AnimatedCalculatorButton(
                        label: '–',
                        variant: ButtonVariant.operator,
                        fontSize: 24,
                        onTap: () => _onInput('-'),
                      ),
                    ),
                  ],
                ),

                // Keypad Row 4: 1, 2, 3, +
                Row(
                  children: [
                    _buildNumKey('1'),
                    _buildNumKey('2'),
                    _buildNumKey('3'),
                    Expanded(
                      child: AnimatedCalculatorButton(
                        label: '+',
                        variant: ButtonVariant.operator,
                        fontSize: 24,
                        onTap: () => _onInput('+'),
                      ),
                    ),
                  ],
                ),

                // Keypad Row 5: π, 0, ., =
                Row(
                  children: [
                    Expanded(
                      child: AnimatedCalculatorButton(
                        label: _is2ndMode ? 'e' : 'π',
                        variant: ButtonVariant.action,
                        onTap: () => _onInput(_is2ndMode ? 'e' : 'π'),
                      ),
                    ),
                    _buildNumKey('0'),
                    Expanded(
                      child: AnimatedCalculatorButton(
                        label: '.',
                        variant: ButtonVariant.number,
                        fontSize: 26,
                        onTap: () => _onInput('.'),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: AnimatedCalculatorButton(
                        label: '=',
                        variant: ButtonVariant.equals,
                        fontSize: 28,
                        onTap: _onEquals,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      ],
    );
  }

  Widget _buildNumKey(String digit) {
    return Expanded(
      child: AnimatedCalculatorButton(
        label: digit,
        variant: ButtonVariant.number,
        fontSize: 22,
        onTap: () => _onInput(digit),
      ),
    );
  }

  Widget _buildTrigButton(String base) {
    String label = base;
    String exprToken = '$base(';

    if (_isHypMode && _is2ndMode) {
      label = 'a${base}h';
      exprToken = 'a${base}h(';
    } else if (_isHypMode) {
      label = '${base}h';
      exprToken = '${base}h(';
    } else if (_is2ndMode) {
      label = 'a$base';
      exprToken = 'a$base(';
    }

    return Expanded(
      child: AnimatedCalculatorButton(
        label: label,
        variant: ButtonVariant.action,
        fontSize: 15,
        onTap: () => _onInput(exprToken),
      ),
    );
  }

  Widget _buildMemoryBtn(String label, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: LuxuryTheme.goldWarm,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
