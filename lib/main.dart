import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/calculation_history.dart';
import 'screens/financial_screen.dart';
import 'screens/graphing_screen.dart';
import 'screens/matrix_screen.dart';
import 'screens/programmer_screen.dart';
import 'screens/scientific_calculator_screen.dart';
import 'screens/solver_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/unit_converter_screen.dart';
import 'theme/luxury_theme.dart';
import 'widgets/particle_background.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Set system navigation bar and status bar colors to match Obsidian Carbon
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: LuxuryTheme.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const AetherCalcApp());
}

class AetherCalcApp extends StatelessWidget {
  const AetherCalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: LuxuryTheme.isDarkNotifier,
      builder: (context, isDark, _) {
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
            systemNavigationBarColor: LuxuryTheme.background,
            systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          ),
        );
        return MaterialApp(
          title: 'AetherCalc Pro - Ultra Scientific',
          debugShowCheckedModeBanner: false,
          theme: LuxuryTheme.themeData,
          home: const MainCalculatorHome(),
        );
      },
    );
  }
}

class MainCalculatorHome extends StatefulWidget {
  const MainCalculatorHome({super.key});

  @override
  State<MainCalculatorHome> createState() => _MainCalculatorHomeState();
}

class _MainCalculatorHomeState extends State<MainCalculatorHome>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<HistoryItem> _history = [];
  bool _isHapticSoundEnabled = true;

  final List<({String title, IconData icon})> _modes = [
    (title: 'Scientific', icon: Icons.calculate),
    (title: 'Graphing', icon: Icons.show_chart),
    (title: 'Programmer', icon: Icons.terminal),
    (title: 'Matrix', icon: Icons.grid_4x4),
    (title: 'Equations', icon: Icons.functions),
    (title: 'Unit Converter', icon: Icons.swap_horiz),
    (title: 'Financial', icon: Icons.monetization_on_outlined),
    (title: 'Statistics', icon: Icons.bar_chart),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _modes.length, vsync: this);
    LuxuryTheme.isDarkNotifier.addListener(_onThemeChanged);
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    LuxuryTheme.isDarkNotifier.removeListener(_onThemeChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _toggleHaptics() {
    setState(() {
      _isHapticSoundEnabled = !_isHapticSoundEnabled;
    });
    if (_isHapticSoundEnabled) {
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tactile Haptics & SFX: ACTIVE',
            style: TextStyle(color: LuxuryTheme.emeraldBright, fontWeight: FontWeight.bold),
          ),
          backgroundColor: LuxuryTheme.surfaceCardElevated,
          duration: const Duration(milliseconds: 1200),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tactile Haptics & SFX: MUTED',
            style: TextStyle(color: LuxuryTheme.textMuted),
          ),
          backgroundColor: LuxuryTheme.surfaceCardElevated,
          duration: const Duration(milliseconds: 1200),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showAboutModal() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: LuxuryTheme.surfaceDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _buildAboutSheet(ctx),
    );
  }

  Widget _buildAboutSheet(BuildContext ctx) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: LuxuryTheme.surfaceDark,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: LuxuryTheme.borderMuted,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 18),

          // Glowing Brand Emblem
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [LuxuryTheme.emeraldPrimary, LuxuryTheme.goldPrimary],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: LuxuryTheme.emeraldGlow,
                  blurRadius: 18,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.all_inclusive,
              color: Color(0xFF042014),
              size: 38,
            ),
          ),
          const SizedBox(height: 14),

          // Elvyntra Company Branding Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: LuxuryTheme.goldSubtle,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: LuxuryTheme.goldWarm.withOpacity(0.6), width: 1.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.workspace_premium_outlined, size: 14, color: LuxuryTheme.goldPrimary),
                const SizedBox(width: 6),
                Text(
                  'AN ELVYNTRA PRODUCT',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: LuxuryTheme.goldPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          Text(
            'AETHERCALC PRO',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              letterSpacing: 2.5,
              fontSize: 20,
              color: LuxuryTheme.textBright,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Version 1.0.0 Enterprise • Engineered by Elvyntra',
            style: TextStyle(
              fontSize: 12,
              color: LuxuryTheme.emeraldBright,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Ultra-precision scientific, graphing, programmer & matrix computational engine with real-time 60 FPS spring physics.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: LuxuryTheme.textMuted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),

          // Security & Architecture Badges
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildAboutBadge('100% OFFLINE', Icons.wifi_off, LuxuryTheme.emeraldPrimary),
              _buildAboutBadge('ZERO TRACKING', Icons.security, LuxuryTheme.goldPrimary),
              _buildAboutBadge('ZERO ADS', Icons.block, LuxuryTheme.emeraldBright),
              _buildAboutBadge('60 FPS PHYSICS', Icons.speed, LuxuryTheme.ochreWarm),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Copyright © 2026 Elvyntra. All rights reserved.',
            style: TextStyle(
              fontSize: 10,
              color: LuxuryTheme.textSubtle,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 14),

          // Close button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: LuxuryTheme.emeraldPrimary,
                foregroundColor: const Color(0xFF042014),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('DISMISS', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.0)),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildAboutBadge(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5), width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  void _addHistoryItem(HistoryItem item) {
    setState(() {
      _history.add(item);
    });
  }

  void _clearHistory() {
    setState(() {
      _history.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ParticleBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Luxury Top Header Bar
              _buildTopAppBar(),

              // Luxury Tab Navigation Bar
              _buildModeTabBar(),

              // Mode Screen View
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    ScientificCalculatorScreen(
                      history: _history,
                      onAddHistory: _addHistoryItem,
                      onClearHistory: _clearHistory,
                    ),
                    const GraphingScreen(),
                    const ProgrammerScreen(),
                    const MatrixScreen(),
                    const SolverScreen(),
                    const UnitConverterScreen(),
                    const FinancialScreen(),
                    const StatsScreen(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: LuxuryTheme.surfaceDark,
        border: Border(
          bottom: BorderSide(color: LuxuryTheme.borderMuted, width: 1.0),
        ),
      ),
      child: Row(
        children: [
          // Logo & Glowing Brand Pill (Clickable -> About System Sheet)
          GestureDetector(
            onTap: _showAboutModal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [LuxuryTheme.emeraldPrimary, LuxuryTheme.goldPrimary],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: LuxuryTheme.emeraldGlow,
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.all_inclusive,
                    color: Color(0xFF042014),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'AETHER',
                          style: TextStyle(
                            fontFamily: 'sans-serif',
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                            fontSize: 16,
                            color: LuxuryTheme.textBright,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: LuxuryTheme.emeraldSubtle,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: LuxuryTheme.emeraldPrimary, width: 0.8),
                          ),
                          child: Text(
                            'PRO',
                            style: TextStyle(
                              color: LuxuryTheme.emeraldBright,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'ELVYNTRA',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: LuxuryTheme.goldWarm,
                            letterSpacing: 0.8,
                          ),
                        ),
                        Text(
                          ' • Analytical Engine',
                          style: TextStyle(
                            fontSize: 9,
                            color: LuxuryTheme.textMuted,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),

          // Theme Toggle Button (Dark <-> Light)
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              LuxuryTheme.toggleTheme();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: LuxuryTheme.surfaceCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: LuxuryTheme.isDark
                      ? LuxuryTheme.goldWarm
                      : LuxuryTheme.emeraldPrimary,
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: LuxuryTheme.isDark
                        ? LuxuryTheme.goldGlow
                        : LuxuryTheme.emeraldGlow,
                    blurRadius: 8,
                    spreadRadius: 0.5,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    LuxuryTheme.isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                    size: 15,
                    color: LuxuryTheme.isDark ? LuxuryTheme.goldPrimary : LuxuryTheme.emeraldPrimary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    LuxuryTheme.isDark ? 'LIGHT' : 'DARK',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: LuxuryTheme.isDark ? LuxuryTheme.goldPrimary : LuxuryTheme.emeraldPrimary,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Audio & Haptic Interactive Toggle
          GestureDetector(
            onTap: _toggleHaptics,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: _isHapticSoundEnabled ? LuxuryTheme.emeraldSubtle : LuxuryTheme.surfaceCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _isHapticSoundEnabled ? LuxuryTheme.emeraldPrimary : LuxuryTheme.borderMuted,
                  width: 1.0,
                ),
                boxShadow: _isHapticSoundEnabled
                    ? [
                        BoxShadow(
                          color: LuxuryTheme.emeraldGlow,
                          blurRadius: 6,
                          spreadRadius: 0.5,
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isHapticSoundEnabled ? Icons.volume_up : Icons.volume_off_outlined,
                    size: 14,
                    color: _isHapticSoundEnabled ? LuxuryTheme.emeraldBright : LuxuryTheme.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isHapticSoundEnabled ? 'SFX ON' : 'MUTED',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: _isHapticSoundEnabled ? LuxuryTheme.emeraldBright : LuxuryTheme.textMuted,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeTabBar() {
    return Container(
      color: LuxuryTheme.surfaceDark,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        indicatorColor: LuxuryTheme.emeraldPrimary,
        indicatorWeight: 3.0,
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: LuxuryTheme.emeraldBright,
        unselectedLabelColor: LuxuryTheme.textMuted,
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.4,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        tabs: _modes.map((mode) {
          return Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(mode.icon, size: 16),
                const SizedBox(width: 6),
                Text(mode.title),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
