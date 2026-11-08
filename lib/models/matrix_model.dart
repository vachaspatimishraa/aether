import 'dart:math' as math;

class MatrixModel {
  final int rows;
  final int cols;
  final List<List<double>> data;

  MatrixModel(this.rows, this.cols, [List<List<double>>? initialData])
      : data = initialData ??
            List.generate(rows, (_) => List.generate(cols, (_) => 0.0));

  factory MatrixModel.identity(int size) {
    final m = MatrixModel(size, size);
    for (int i = 0; i < size; i++) {
      m.data[i][i] = 1.0;
    }
    return m;
  }

  MatrixModel copy() {
    return MatrixModel(
      rows,
      cols,
      data.map((row) => List<double>.from(row)).toList(),
    );
  }

  MatrixModel add(MatrixModel other) {
    if (rows != other.rows || cols != other.cols) {
      throw Exception('Dimension mismatch for addition');
    }
    final res = MatrixModel(rows, cols);
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        res.data[i][j] = data[i][j] + other.data[i][j];
      }
    }
    return res;
  }

  MatrixModel subtract(MatrixModel other) {
    if (rows != other.rows || cols != other.cols) {
      throw Exception('Dimension mismatch for subtraction');
    }
    final res = MatrixModel(rows, cols);
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        res.data[i][j] = data[i][j] - other.data[i][j];
      }
    }
    return res;
  }

  MatrixModel multiply(MatrixModel other) {
    if (cols != other.rows) {
      throw Exception('Cannot multiply matrices: inner dimensions mismatch');
    }
    final res = MatrixModel(rows, other.cols);
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < other.cols; j++) {
        double sum = 0.0;
        for (int k = 0; k < cols; k++) {
          sum += data[i][k] * other.data[k][j];
        }
        res.data[i][j] = sum;
      }
    }
    return res;
  }

  MatrixModel scalarMultiply(double k) {
    final res = MatrixModel(rows, cols);
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        res.data[i][j] = data[i][j] * k;
      }
    }
    return res;
  }

  MatrixModel transpose() {
    final res = MatrixModel(cols, rows);
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        res.data[j][i] = data[i][j];
      }
    }
    return res;
  }

  double trace() {
    if (rows != cols) throw Exception('Trace requires square matrix');
    double sum = 0;
    for (int i = 0; i < rows; i++) {
      sum += data[i][i];
    }
    return sum;
  }

  double determinant() {
    if (rows != cols) throw Exception('Determinant requires square matrix');
    if (rows == 1) return data[0][0];
    if (rows == 2) {
      return data[0][0] * data[1][1] - data[0][1] * data[1][0];
    }
    if (rows == 3) {
      final a = data[0][0], b = data[0][1], c = data[0][2];
      final d = data[1][0], e = data[1][1], f = data[1][2];
      final g = data[2][0], h = data[2][1], i = data[2][2];
      return a * (e * i - f * h) - b * (d * i - f * g) + c * (d * h - e * g);
    }
    throw Exception('Determinant not supported above 3x3');
  }

  MatrixModel? inverse() {
    final det = determinant();
    if (det.abs() < 1e-12) return null; // Singular

    if (rows == 2) {
      final res = MatrixModel(2, 2);
      res.data[0][0] = data[1][1] / det;
      res.data[0][1] = -data[0][1] / det;
      res.data[1][0] = -data[1][0] / det;
      res.data[1][1] = data[0][0] / det;
      return res;
    }

    if (rows == 3) {
      final res = MatrixModel(3, 3);
      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          final sub = _minor(i, j);
          final sign = ((i + j) % 2 == 0) ? 1.0 : -1.0;
          // Note transpose for adjugate: res[j][i]
          res.data[j][i] = (sign * sub.determinant()) / det;
        }
      }
      return res;
    }

    return null;
  }

  MatrixModel _minor(int r, int c) {
    final minor = MatrixModel(rows - 1, cols - 1);
    int mi = 0;
    for (int i = 0; i < rows; i++) {
      if (i == r) continue;
      int mj = 0;
      for (int j = 0; j < cols; j++) {
        if (j == c) continue;
        minor.data[mi][mj] = data[i][j];
        mj++;
      }
      mi++;
    }
    return minor;
  }

  List<String> eigenvalues2x2() {
    if (rows != 2 || cols != 2) return [];
    final tr = trace();
    final det = determinant();
    final disc = tr * tr - 4 * det;
    if (disc >= 0) {
      final lambda1 = (tr + math.sqrt(disc)) / 2;
      final lambda2 = (tr - math.sqrt(disc)) / 2;
      return [
        lambda1.toStringAsFixed(4).replaceAll(RegExp(r'\.?0+$'), ''),
        lambda2.toStringAsFixed(4).replaceAll(RegExp(r'\.?0+$'), '')
      ];
    } else {
      final real = (tr / 2).toStringAsFixed(3);
      final imag = (math.sqrt(-disc) / 2).toStringAsFixed(3);
      return ['$real + ${imag}i', '$real - ${imag}i'];
    }
  }
}

