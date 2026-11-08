import 'package:flutter/material.dart';
import '../theme/luxury_theme.dart';
import '../widgets/animated_calculator_button.dart';

enum NumBase { hex, dec, oct, bin }
enum WordSize { qword, dword, word, byte }

class ProgrammerScreen extends StatefulWidget {
  const ProgrammerScreen({super.key});

  @override
  State<ProgrammerScreen> createState() => _ProgrammerScreenState();
}

class _ProgrammerScreenState extends State<ProgrammerScreen> {
  NumBase _activeBase = NumBase.dec;
  WordSize _wordSize = WordSize.dword; // 32-bit default
  BigInt _currentValue = BigInt.from(42);
  BigInt? _storedValue;
  String? _pendingOp;

  int get _bitCount {
    switch (_wordSize) {
      case WordSize.qword:
        return 64;
      case WordSize.dword:
        return 32;
      case WordSize.word:
        return 16;
      case WordSize.byte:
        return 8;
    }
  }

  BigInt get _bitMask {
    switch (_wordSize) {
      case WordSize.qword:
        return (BigInt.one << 64) - BigInt.one;
      case WordSize.dword:
        return (BigInt.one << 32) - BigInt.one;
      case WordSize.word:
        return (BigInt.one << 16) - BigInt.one;
      case WordSize.byte:
        return (BigInt.one << 8) - BigInt.one;
    }
  }

  void _onDigit(String d) {
    setState(() {
      int baseInt = 10;
      switch (_activeBase) {
        case NumBase.hex:
          baseInt = 16;
          break;
        case NumBase.dec:
          baseInt = 10;
          break;
        case NumBase.oct:
          baseInt = 8;
          break;
        case NumBase.bin:
          baseInt = 2;
          break;
      }

      int digitVal = int.tryParse(d, radix: 16) ?? 0;
      if (digitVal >= baseInt) return; // Invalid for this base

      _currentValue = ((_currentValue * BigInt.from(baseInt)) + BigInt.from(digitVal)) & _bitMask;
    });
  }

  void _onBackspace() {
    setState(() {
      int baseInt = 10;
      switch (_activeBase) {
        case NumBase.hex:
          baseInt = 16;
          break;
        case NumBase.dec:
          baseInt = 10;
          break;
        case NumBase.oct:
          baseInt = 8;
          break;
        case NumBase.bin:
          baseInt = 2;
          break;
      }
      _currentValue = _currentValue ~/ BigInt.from(baseInt);
    });
  }

  void _onClear() {
    setState(() {
      _currentValue = BigInt.zero;
      _storedValue = null;
      _pendingOp = null;
    });
  }

  void _onBitwiseOp(String op) {
    setState(() {
      if (op == 'NOT') {
        _currentValue = (~_currentValue) & _bitMask;
        return;
      }
      _storedValue = _currentValue;
      _pendingOp = op;
      _currentValue = BigInt.zero;
    });
  }

  void _onEquals() {
    if (_storedValue == null || _pendingOp == null) return;
    setState(() {
      final a = _storedValue!;
      final b = _currentValue;
      switch (_pendingOp) {
        case 'AND':
          _currentValue = (a & b) & _bitMask;
          break;
        case 'OR':
          _currentValue = (a | b) & _bitMask;
          break;
        case 'XOR':
          _currentValue = (a ^ b) & _bitMask;
          break;
        case 'NAND':
          _currentValue = (~(a & b)) & _bitMask;
          break;
        case 'NOR':
          _currentValue = (~(a | b)) & _bitMask;
          break;
        case '<<':
          final shift = b.toInt();
          _currentValue = (a << (shift > 64 ? 64 : shift)) & _bitMask;
          break;
        case '>>':
          final shift = b.toInt();
          _currentValue = (a >> (shift > 64 ? 64 : shift)) & _bitMask;
          break;
      }
      _storedValue = null;
      _pendingOp = null;
    });
  }

  void _toggleBit(int bitIndex) {
    setState(() {
      _currentValue = (_currentValue ^ (BigInt.one << bitIndex)) & _bitMask;
    });
  }

  String _formatBinary() {
    final bits = _bitCount;
    String bin = _currentValue.toRadixString(2).padLeft(bits, '0');
    // Group into 4-bit nibbles
    final buffer = StringBuffer();
    for (int i = 0; i < bin.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(bin[i]);
    }
    return buffer.toString();
  }

  bool _isDigitValidForBase(String digit) {
    final val = int.tryParse(digit, radix: 16);
    if (val == null) return false;
    switch (_activeBase) {
      case NumBase.bin:
        return val < 2;
      case NumBase.oct:
        return val < 8;
      case NumBase.dec:
        return val < 10;
      case NumBase.hex:
        return val < 16;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hexStr = _currentValue.toRadixString(16).toUpperCase();
    final decStr = _currentValue.toString();
    final octStr = _currentValue.toRadixString(8);
    final binStr = _formatBinary();

    return Column(
      children: [
        // Base displays card
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: LuxuryTheme.surfaceCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: LuxuryTheme.borderGlowing),
          ),
          child: Column(
            children: [
              // Word size selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'WORD SIZE',
                    style: TextStyle(
                      color: LuxuryTheme.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  Row(
                    children: [
                      _buildWordSizeBadge(WordSize.qword, 'QWORD (64)'),
                      const SizedBox(width: 6),
                      _buildWordSizeBadge(WordSize.dword, 'DWORD (32)'),
                      const SizedBox(width: 6),
                      _buildWordSizeBadge(WordSize.word, 'WORD (16)'),
                      const SizedBox(width: 6),
                      _buildWordSizeBadge(WordSize.byte, 'BYTE (8)'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Bases row
              _buildBaseRow('HEX', hexStr, NumBase.hex),
              Divider(color: LuxuryTheme.borderMuted, height: 10),
              _buildBaseRow('DEC', decStr, NumBase.dec),
              Divider(color: LuxuryTheme.borderMuted, height: 10),
              _buildBaseRow('OCT', octStr, NumBase.oct),
              Divider(color: LuxuryTheme.borderMuted, height: 10),
              _buildBaseRow('BIN', binStr, NumBase.bin, isSmall: true),
            ],
          ),
        ),

        // Interactive bit-toggle visualizer
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: LuxuryTheme.surfaceDark,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: LuxuryTheme.borderMuted),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.tune, color: LuxuryTheme.goldWarm, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'BIT FLIPPER (Tap to toggle individual bit)',
                    style: TextStyle(
                      color: LuxuryTheme.goldWarm,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'MSB ➔ LSB',
                    style: TextStyle(
                      color: LuxuryTheme.textSubtle,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              _buildBitGrid(),
            ],
          ),
        ),

        // Programmer Keypad
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Column(
              children: [
                // Bitwise operations row
                Row(
                  children: [
                    _buildOpBtn('AND'),
                    _buildOpBtn('OR'),
                    _buildOpBtn('XOR'),
                    _buildOpBtn('NOT'),
                    _buildOpBtn('<<'),
                    _buildOpBtn('>>'),
                  ],
                ),
                // Row 1: A B C D Clear Backspace
                Row(
                  children: [
                    _buildHexKey('A'),
                    _buildHexKey('B'),
                    _buildHexKey('C'),
                    _buildHexKey('D'),
                    Expanded(
                      child: AnimatedCalculatorButton(
                        label: 'AC',
                        variant: ButtonVariant.danger,
                        onTap: _onClear,
                      ),
                    ),
                    Expanded(
                      child: AnimatedCalculatorButton(
                        label: '⌫',
                        variant: ButtonVariant.danger,
                        onTap: _onBackspace,
                      ),
                    ),
                  ],
                ),
                // Row 2: E F 7 8 9 /
                Row(
                  children: [
                    _buildHexKey('E'),
                    _buildHexKey('F'),
                    _buildNumKey('7'),
                    _buildNumKey('8'),
                    _buildNumKey('9'),
                    _buildOpBtn('NAND'),
                  ],
                ),
                // Row 3: 4 5 6 NOR
                Row(
                  children: [
                    _buildNumKey('4'),
                    _buildNumKey('5'),
                    _buildNumKey('6'),
                    _buildOpBtn('NOR'),
                    Expanded(
                      flex: 2,
                      child: AnimatedCalculatorButton(
                        label: '=',
                        variant: ButtonVariant.equals,
                        onTap: _onEquals,
                      ),
                    ),
                  ],
                ),
                // Row 4: 0 1 2 3
                Row(
                  children: [
                    _buildNumKey('0'),
                    _buildNumKey('1'),
                    _buildNumKey('2'),
                    _buildNumKey('3'),
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

  Widget _buildWordSizeBadge(WordSize size, String label) {
    final active = _wordSize == size;
    return GestureDetector(
      onTap: () => setState(() {
        _wordSize = size;
        _currentValue = _currentValue & _bitMask;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: active ? LuxuryTheme.emeraldPrimary.withOpacity(0.2) : LuxuryTheme.surfaceDark,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: active ? LuxuryTheme.emeraldPrimary : LuxuryTheme.borderMuted,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? LuxuryTheme.emeraldBright : LuxuryTheme.textMuted,
            fontSize: 9,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildBaseRow(String baseName, String value, NumBase base, {bool isSmall = false}) {
    final isActive = _activeBase == base;
    return InkWell(
      onTap: () => setState(() => _activeBase = base),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 44,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isActive ? LuxuryTheme.emeraldDark : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                baseName,
                style: TextStyle(
                  color: isActive ? LuxuryTheme.emeraldBright : LuxuryTheme.goldWarm,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: isActive ? LuxuryTheme.emeraldPrimary : LuxuryTheme.textBright,
                  fontWeight: FontWeight.w600,
                  fontSize: isSmall ? 13 : 18,
                  fontFamily: 'monospace',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBitGrid() {
    final int count = _bitCount > 32 ? 32 : _bitCount; // show up to 32 interactive bits
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 3,
      runSpacing: 4,
      children: List.generate(count, (idx) {
        final bitPos = count - 1 - idx;
        final isSet = ((_currentValue >> bitPos) & BigInt.one) == BigInt.one;
        return GestureDetector(
          onTap: () => _toggleBit(bitPos),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: count <= 16 ? 18 : 13,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSet ? LuxuryTheme.emeraldPrimary : LuxuryTheme.surfaceCardElevated,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isSet ? LuxuryTheme.emeraldBright : LuxuryTheme.borderMuted,
                width: 1,
              ),
              boxShadow: isSet
                  ? [
                      BoxShadow(
                        color: LuxuryTheme.emeraldPrimary.withOpacity(0.5),
                        blurRadius: 4,
                      )
                    ]
                  : null,
            ),
            child: Text(
              isSet ? '1' : '0',
              style: TextStyle(
                color: isSet ? const Color(0xFF042014) : LuxuryTheme.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNumKey(String digit) {
    final valid = _isDigitValidForBase(digit);
    return Expanded(
      child: AnimatedCalculatorButton(
        label: digit,
        variant: valid ? ButtonVariant.number : ButtonVariant.secondary,
        onTap: () {
          if (valid) _onDigit(digit);
        },
      ),
    );
  }

  Widget _buildHexKey(String hex) {
    final valid = _isDigitValidForBase(hex);
    return Expanded(
      child: AnimatedCalculatorButton(
        label: hex,
        variant: valid ? ButtonVariant.action : ButtonVariant.secondary,
        onTap: () {
          if (valid) _onDigit(hex);
        },
      ),
    );
  }

  Widget _buildOpBtn(String op) {
    return Expanded(
      child: AnimatedCalculatorButton(
        label: op,
        fontSize: 13,
        variant: ButtonVariant.operator,
        onTap: () => _onBitwiseOp(op),
      ),
    );
  }
}
