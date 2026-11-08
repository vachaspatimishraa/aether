import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/luxury_theme.dart';
import '../widgets/glowing_badge.dart';

class FinancialScreen extends StatefulWidget {
  const FinancialScreen({super.key});

  @override
  State<FinancialScreen> createState() => _FinancialScreenState();
}

class _FinancialScreenState extends State<FinancialScreen> {
  int _activeTab = 0; // 0 = Compound Interest, 1 = Loan/Mortgage EMI

  // Compound Interest parameters
  double _principal = 10000.0;
  double _annualRate = 7.5;
  double _years = 10.0;
  double _monthlyDeposit = 200.0;
  // Loan EMI parameters
  double _loanAmount = 250000.0;
  double _loanRate = 6.5;
  double _loanYears = 25.0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tabs
          Row(
            children: [
              GlowingBadge(
                text: 'COMPOUND INTEREST',
                isActive: _activeTab == 0,
                activeColor: LuxuryTheme.emeraldPrimary,
                onTap: () => setState(() => _activeTab = 0),
              ),
              const SizedBox(width: 8),
              GlowingBadge(
                text: 'LOAN / MORTGAGE EMI',
                isActive: _activeTab == 1,
                activeColor: LuxuryTheme.goldPrimary,
                onTap: () => setState(() => _activeTab = 1),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_activeTab == 0) _buildCompoundInterestSection() else _buildLoanSection(),
        ],
      ),
    );
  }

  Widget _buildCompoundInterestSection() {
    // Formula: FV = P*(1 + r/n)^(nt) + PMT * [((1 + r/n)^(nt) - 1) / (r/n)]
    final r = _annualRate / 100.0;
    final totalMonths = (_years * 12).toInt();

    // Direct monthly simulation for precise recurring deposits
    double balance = _principal;
    double totalDeposited = _principal;
    for (int m = 1; m <= totalMonths; m++) {
      balance += _monthlyDeposit;
      totalDeposited += _monthlyDeposit;
      balance += balance * (r / 12.0);
    }
    final totalInterest = balance - totalDeposited;

    return Column(
      children: [
        // Inputs card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: LuxuryTheme.surfaceCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: LuxuryTheme.borderGlowing),
          ),
          child: Column(
            children: [
              _buildSliderInput(
                title: 'Initial Principal',
                valueStr: '\$${_principal.toInt()}',
                value: _principal,
                min: 0,
                max: 100000,
                accent: LuxuryTheme.emeraldPrimary,
                onChanged: (v) => setState(() => _principal = v),
              ),
              _buildSliderInput(
                title: 'Monthly Contribution',
                valueStr: '\$${_monthlyDeposit.toInt()}/mo',
                value: _monthlyDeposit,
                min: 0,
                max: 2000,
                accent: LuxuryTheme.goldPrimary,
                onChanged: (v) => setState(() => _monthlyDeposit = v),
              ),
              _buildSliderInput(
                title: 'Annual Interest Rate',
                valueStr: '${_annualRate.toStringAsFixed(1)}%',
                value: _annualRate,
                min: 0.5,
                max: 25.0,
                accent: LuxuryTheme.emeraldPrimary,
                onChanged: (v) => setState(() => _annualRate = v),
              ),
              _buildSliderInput(
                title: 'Investment Horizon',
                valueStr: '${_years.toInt()} Years',
                value: _years,
                min: 1,
                max: 40,
                accent: LuxuryTheme.goldPrimary,
                onChanged: (v) => setState(() => _years = v),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Financial Growth Output Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: LuxuryTheme.surfaceDark,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: LuxuryTheme.emeraldPrimary, width: 1.5),
            boxShadow: [
              BoxShadow(color: LuxuryTheme.emeraldSubtle, blurRadius: 18),
            ],
          ),
          child: Column(
            children: [
              Text(
                'PROJECTED FUTURE WEALTH',
                style: TextStyle(
                  color: LuxuryTheme.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '\$${balance.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: LuxuryTheme.emeraldBright,
                  letterSpacing: 0.5,
                ),
              ),
              Divider(color: LuxuryTheme.borderMuted, height: 26),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatColumn(
                    'Total Invested',
                    '\$${totalDeposited.toStringAsFixed(0)}',
                    LuxuryTheme.goldWarm,
                  ),
                  _buildStatColumn(
                    'Total Compound Interest',
                    '\$${totalInterest.toStringAsFixed(0)}',
                    LuxuryTheme.emeraldPrimary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoanSection() {
    // EMI = P * r * (1 + r)^n / ((1 + r)^n - 1)
    final P = _loanAmount;
    final r = (_loanRate / 100.0) / 12.0;
    final n = _loanYears * 12.0;

    double monthlyEMI = 0.0;
    if (r > 0) {
      final powRN = math.pow(1 + r, n);
      monthlyEMI = (P * r * powRN) / (powRN - 1);
    } else {
      monthlyEMI = P / n;
    }

    final totalPayment = monthlyEMI * n;
    final totalInterest = totalPayment - P;

    return Column(
      children: [
        // Loan Inputs Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: LuxuryTheme.surfaceCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: LuxuryTheme.borderGlowing),
          ),
          child: Column(
            children: [
              _buildSliderInput(
                title: 'Loan Principal Amount',
                valueStr: '\$${_loanAmount.toInt()}',
                value: _loanAmount,
                min: 5000,
                max: 1000000,
                accent: LuxuryTheme.goldPrimary,
                onChanged: (v) => setState(() => _loanAmount = v),
              ),
              _buildSliderInput(
                title: 'Annual Interest Rate',
                valueStr: '${_loanRate.toStringAsFixed(2)}%',
                value: _loanRate,
                min: 1.0,
                max: 20.0,
                accent: LuxuryTheme.emeraldPrimary,
                onChanged: (v) => setState(() => _loanRate = v),
              ),
              _buildSliderInput(
                title: 'Loan Term',
                valueStr: '${_loanYears.toInt()} Years',
                value: _loanYears,
                min: 1,
                max: 30,
                accent: LuxuryTheme.goldPrimary,
                onChanged: (v) => setState(() => _loanYears = v),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // EMI Output Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: LuxuryTheme.surfaceDark,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: LuxuryTheme.goldWarm, width: 1.5),
            boxShadow: [
              BoxShadow(color: LuxuryTheme.goldSubtle, blurRadius: 18),
            ],
          ),
          child: Column(
            children: [
              Text(
                'MONTHLY PAYMENT (EMI)',
                style: TextStyle(
                  color: LuxuryTheme.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '\$${monthlyEMI.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: LuxuryTheme.goldPrimary,
                  letterSpacing: 0.5,
                ),
              ),
              Divider(color: LuxuryTheme.borderMuted, height: 26),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatColumn(
                    'Principal',
                    '\$${P.toStringAsFixed(0)}',
                    LuxuryTheme.textBright,
                  ),
                  _buildStatColumn(
                    'Total Interest',
                    '\$${totalInterest.toStringAsFixed(0)}',
                    LuxuryTheme.ochreWarm, // Orange-ochre, NO RED
                  ),
                  _buildStatColumn(
                    'Total Repayment',
                    '\$${totalPayment.toStringAsFixed(0)}',
                    LuxuryTheme.emeraldBright,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSliderInput({
    required String title,
    required String valueStr,
    required double value,
    required double min,
    required double max,
    required Color accent,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(color: LuxuryTheme.textMuted, fontSize: 13),
              ),
              Text(
                valueStr,
                style: TextStyle(color: accent, fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: accent,
              inactiveTrackColor: LuxuryTheme.borderMuted,
              thumbColor: accent,
              overlayColor: accent.withOpacity(0.2),
              trackHeight: 3,
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: LuxuryTheme.textMuted, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}
