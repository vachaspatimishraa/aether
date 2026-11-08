import 'dart:math' as math;
import 'package:math_expressions/math_expressions.dart';

class EvaluationResult {
  final bool isSuccess;
  final String value;
  final String? errorMessage;
  final double? numericValue;

  const EvaluationResult({
    required this.isSuccess,
    required this.value,
    this.errorMessage,
    this.numericValue,
  });

  factory EvaluationResult.success(String val, double numVal) {
    return EvaluationResult(
      isSuccess: true,
      value: val,
      numericValue: numVal,
    );
  }

  factory EvaluationResult.failure(String message) {
    return EvaluationResult(
      isSuccess: false,
      value: 'Error',
      errorMessage: message,
    );
  }
}

class ExpressionEvaluator {
  static const double piValue = math.pi;
  static const double eValue = math.e;
  static const double phiValue = 1.6180339887498948482; // Golden ratio
  static const double cValue = 299792458.0; // Speed of light m/s
  static const double hValue = 6.62607015e-34; // Planck constant
  static const double gValue = 6.67430e-11; // Gravitational constant
  static const double naValue = 6.02214076e23; // Avogadro constant
  static const double kbValue = 1.380649e-23; // Boltzmann constant

  /// Evaluates mathematical expression in DEG or RAD angle mode.
  static EvaluationResult evaluate(String expression, {bool isDegree = true}) {
    if (expression.trim().isEmpty) {
      return const EvaluationResult(isSuccess: true, value: '0', numericValue: 0.0);
    }

    try {
      String sanitized = _preprocess(expression, isDegree: isDegree);
      final parser = ShuntingYardParser();
      final exp = parser.parse(sanitized);
      final cm = ContextModel();
      final eval = exp.evaluate(EvaluationType.REAL, cm) as double;

      if (eval.isNaN) {
        return EvaluationResult.failure('Undefined result (NaN)');
      }
      if (eval.isInfinite) {
        return EvaluationResult.failure(eval.isNegative ? '-Infinity' : 'Infinity');
      }

      String formatted = formatResult(eval);
      return EvaluationResult.success(formatted, eval);
    } catch (e) {
      return EvaluationResult.failure(e.toString());
    }
  }

  /// Live preview evaluation: returns formatted result or empty if incomplete
  static String? livePreview(String expression, {bool isDegree = true}) {
    if (expression.trim().isEmpty) return null;
    final res = evaluate(expression, isDegree: isDegree);
    return res.isSuccess ? res.value : null;
  }

  static String _preprocess(String exp, {required bool isDegree}) {
    String s = exp;

    // Normalize multiplication and division signs
    s = s.replaceAll('×', '*').replaceAll('÷', '/');
    s = s.replaceAll('–', '-').replaceAll('—', '-');

    // Replace scientific constants
    s = s.replaceAll('π', '($piValue)');
    s = s.replaceAll('φ', '($phiValue)');
    s = s.replaceAll('c_0', '($cValue)');
    s = s.replaceAll('h_0', '($hValue)');
    s = s.replaceAll('G_0', '($gValue)');
    s = s.replaceAll('N_A', '($naValue)');
    s = s.replaceAll('k_B', '($kbValue)');

    // Replace standalone Euler 'e' if not in 'exp' or 'ceil'
    s = s.replaceAllMapped(RegExp(r'(?<![a-zA-Z])e(?![a-zA-Z0-9])'), (m) => '($eValue)');

    // Support percentage %: e.g. 50% -> (50/100), 20 + 10% -> 20 + (10/100)
    s = s.replaceAllMapped(RegExp(r'(\d+(\.\d+)?)%'), (m) => '(${m[1]}/100)');

    // Handle factorial `n!`: e.g. 5! -> factorial(5)
    s = _replaceFactorials(s);

    // Handle Combinations nCr and Permutations nPr: e.g. 5 nCr 2 -> combinations(5, 2)
    s = _replaceCombinatorics(s);

    // Handle square root √x -> sqrt(x)
    s = s.replaceAllMapped(RegExp(r'√\s*(\d+(\.\d+)?|\([^\)]+\))'), (m) => 'sqrt(${m[1]})');
    s = s.replaceAll('√', 'sqrt');

    // Handle cube root ∛x -> (x)^(1/3)
    s = s.replaceAllMapped(RegExp(r'∛\s*(\d+(\.\d+)?|\([^\)]+\))'), (m) => '((${m[1]})^(1/3))');

    // Handle degree conversion for trig functions
    if (isDegree) {
      s = _convertTrigDegrees(s);
    }

    // Auto-balance closing parentheses if needed
    int openCount = 0;
    int closeCount = 0;
    for (int i = 0; i < s.length; i++) {
      if (s[i] == '(') openCount++;
      if (s[i] == ')') closeCount++;
    }
    while (closeCount < openCount) {
      s += ')';
      closeCount++;
    }

    return s;
  }

  static String _replaceFactorials(String input) {
    final reg = RegExp(r'(\d+(\.\d+)?|\([^\(\)]+\))!');
    String s = input;
    while (reg.hasMatch(s)) {
      s = s.replaceAllMapped(reg, (match) {
        final inner = match[1]!;
        // If it's a simple number
        final numVal = double.tryParse(inner);
        if (numVal != null && numVal >= 0 && numVal <= 170 && numVal == numVal.roundToDouble()) {
          return '${_computeFactorial(numVal.toInt())}';
        }
        return match[0]!;
      });
      if (!s.contains('!')) break;
      // prevent infinite loop
      break;
    }
    return s;
  }

  static double _computeFactorial(int n) {
    if (n < 0) return double.nan;
    if (n <= 1) return 1.0;
    double res = 1.0;
    for (int i = 2; i <= n; i++) {
      res *= i;
    }
    return res;
  }

  static String _replaceCombinatorics(String input) {
    // 5 nCr 2 or 5C2
    final nCrReg = RegExp(r'(\d+)\s*(nCr|C)\s*(\d+)');
    var s = input.replaceAllMapped(nCrReg, (m) {
      final n = int.parse(m[1]!);
      final r = int.parse(m[3]!);
      return '${combinations(n, r)}';
    });

    final nPrReg = RegExp(r'(\d+)\s*(nPr|P)\s*(\d+)');
    s = s.replaceAllMapped(nPrReg, (m) {
      final n = int.parse(m[1]!);
      final r = int.parse(m[3]!);
      return '${permutations(n, r)}';
    });

    return s;
  }

  static double combinations(int n, int r) {
    if (r < 0 || r > n) return 0;
    if (r == 0 || r == n) return 1;
    if (r > n / 2) r = n - r;
    double res = 1;
    for (int i = 1; i <= r; i++) {
      res = res * (n - i + 1) / i;
    }
    return res;
  }

  static double permutations(int n, int r) {
    if (r < 0 || r > n) return 0;
    double res = 1;
    for (int i = 0; i < r; i++) {
      res *= (n - i);
    }
    return res;
  }

  static String _convertTrigDegrees(String input) {
    // Convert trig arguments: sin(x) -> sin((x) * (pi / 180))
    // Inverse trig: asin(x) -> (asin(x) * (180 / pi))
    String s = input;

    // First handle inverse trig
    s = s.replaceAllMapped(RegExp(r'asin\(([^)]+)\)'), (m) => '(asin(${m[1]}) * (180 / $piValue))');
    s = s.replaceAllMapped(RegExp(r'acos\(([^)]+)\)'), (m) => '(acos(${m[1]}) * (180 / $piValue))');
    s = s.replaceAllMapped(RegExp(r'atan\(([^)]+)\)'), (m) => '(atan(${m[1]}) * (180 / $piValue))');

    // Forward trig (excluding asin, acos, atan, sinh, cosh, tanh)
    final trigNames = ['sin', 'cos', 'tan'];
    for (final fn in trigNames) {
      final pattern = RegExp('(?<!a)$fn\\(([^)]+)\\)(?!h)');
      s = s.replaceAllMapped(pattern, (m) => '$fn((${m[1]}) * ($piValue / 180))');
    }

    return s;
  }

  static String formatResult(double val) {
    if (val.abs() < 1e-12 && val != 0) {
      return val.toStringAsExponential(6);
    }
    if (val.abs() >= 1e12) {
      return val.toStringAsExponential(6);
    }
    if (val == val.roundToDouble()) {
      return val.toInt().toString();
    }
    // Remove trailing zeros
    String str = val.toStringAsPrecision(10);
    if (str.contains('.')) {
      str = str.replaceAll(RegExp(r'0+$'), '');
      str = str.replaceAll(RegExp(r'\.$'), '');
    }
    return str;
  }
}
