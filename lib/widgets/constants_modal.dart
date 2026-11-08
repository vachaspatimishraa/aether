import 'package:flutter/material.dart';
import '../theme/luxury_theme.dart';

class ConstantItem {
  final String symbol;
  final String name;
  final String category;
  final String valueStr;
  final double numericValue;
  final String unit;

  const ConstantItem({
    required this.symbol,
    required this.name,
    required this.category,
    required this.valueStr,
    required this.numericValue,
    required this.unit,
  });
}

class ConstantsModal extends StatelessWidget {
  final void Function(String symbol, double value) onSelectConstant;

  const ConstantsModal({super.key, required this.onSelectConstant});

  static const List<ConstantItem> constants = [
    ConstantItem(
      symbol: 'π',
      name: 'Pi (Archimedes Constant)',
      category: 'Mathematical',
      valueStr: '3.141592653589793',
      numericValue: 3.141592653589793,
      unit: 'ratio',
    ),
    ConstantItem(
      symbol: 'e',
      name: "Euler's Number",
      category: 'Mathematical',
      valueStr: '2.718281828459045',
      numericValue: 2.718281828459045,
      unit: 'base',
    ),
    ConstantItem(
      symbol: 'φ',
      name: 'Golden Ratio (Phi)',
      category: 'Mathematical',
      valueStr: '1.618033988749895',
      numericValue: 1.618033988749895,
      unit: 'ratio',
    ),
    ConstantItem(
      symbol: 'c',
      name: 'Speed of Light in Vacuum',
      category: 'Physics',
      valueStr: '299,792,458',
      numericValue: 299792458.0,
      unit: 'm / s',
    ),
    ConstantItem(
      symbol: 'h',
      name: 'Planck Constant',
      category: 'Quantum',
      valueStr: '6.62607015 × 10⁻³⁴',
      numericValue: 6.62607015e-34,
      unit: 'J · s',
    ),
    ConstantItem(
      symbol: 'ħ',
      name: 'Reduced Planck Constant (h-bar)',
      category: 'Quantum',
      valueStr: '1.054571817 × 10⁻³⁴',
      numericValue: 1.054571817e-34,
      unit: 'J · s',
    ),
    ConstantItem(
      symbol: 'G',
      name: 'Gravitational Constant',
      category: 'Cosmology',
      valueStr: '6.67430 × 10⁻¹¹',
      numericValue: 6.67430e-11,
      unit: 'm³ · kg⁻¹ · s⁻²',
    ),
    ConstantItem(
      symbol: 'N_A',
      name: 'Avogadro Constant',
      category: 'Chemistry',
      valueStr: '6.02214076 × 10²³',
      numericValue: 6.02214076e23,
      unit: 'mol⁻¹',
    ),
    ConstantItem(
      symbol: 'k_B',
      name: 'Boltzmann Constant',
      category: 'Thermodynamics',
      valueStr: '1.380649 × 10⁻²³',
      numericValue: 1.380649e-23,
      unit: 'J / K',
    ),
    ConstantItem(
      symbol: 'R',
      name: 'Molar Gas Constant',
      category: 'Thermodynamics',
      valueStr: '8.314462618',
      numericValue: 8.314462618,
      unit: 'J · mol⁻¹ · K⁻¹',
    ),
    ConstantItem(
      symbol: 'σ',
      name: 'Stefan-Boltzmann Constant',
      category: 'Radiation',
      valueStr: '5.670374419 × 10⁻⁸',
      numericValue: 5.670374419e-8,
      unit: 'W · m⁻² · K⁻⁴',
    ),
    ConstantItem(
      symbol: 'q_e',
      name: 'Elementary Charge',
      category: 'Electromagnetism',
      valueStr: '1.602176634 × 10⁻¹⁹',
      numericValue: 1.602176634e-19,
      unit: 'Coulombs (C)',
    ),
    ConstantItem(
      symbol: 'm_e',
      name: 'Electron Rest Mass',
      category: 'Atomic',
      valueStr: '9.1093837 × 10⁻³¹',
      numericValue: 9.1093837e-31,
      unit: 'kg',
    ),
    ConstantItem(
      symbol: 'm_p',
      name: 'Proton Rest Mass',
      category: 'Nuclear',
      valueStr: '1.67262192 × 10⁻²⁷',
      numericValue: 1.67262192e-27,
      unit: 'kg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: LuxuryTheme.surfaceDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: LuxuryTheme.goldWarm, width: 1.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: LuxuryTheme.borderMuted,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Row(
            children: [
              Icon(Icons.calculate, color: LuxuryTheme.goldPrimary, size: 24),
              const SizedBox(width: 10),
              Text(
                'Scientific & Physical Constants',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: LuxuryTheme.textBright,
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.close, color: LuxuryTheme.textMuted),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // List of constants
          Expanded(
            child: ListView.separated(
              itemCount: constants.length,
              separatorBuilder: (_, _) => Divider(
                color: LuxuryTheme.borderMuted,
                height: 1,
              ),
              itemBuilder: (context, index) {
                final c = constants[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  leading: Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: LuxuryTheme.surfaceCardElevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: LuxuryTheme.goldPrimary.withOpacity(0.4)),
                    ),
                    child: Text(
                      c.symbol,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: LuxuryTheme.goldPrimary,
                      ),
                    ),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          c.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: LuxuryTheme.textBright,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: LuxuryTheme.emeraldDark,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          c.category,
                          style: TextStyle(
                            fontSize: 10,
                            color: LuxuryTheme.emeraldBright,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    '${c.valueStr} ${c.unit}',
                    style: TextStyle(
                      fontSize: 12,
                      color: LuxuryTheme.textMuted,
                      fontFamily: 'monospace',
                    ),
                  ),
                  trailing: Icon(
                    Icons.add_circle_outline,
                    color: LuxuryTheme.emeraldPrimary,
                    size: 20,
                  ),
                  onTap: () {
                    onSelectConstant(c.symbol, c.numericValue);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
