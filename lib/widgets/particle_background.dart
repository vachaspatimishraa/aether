import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/luxury_theme.dart';

/// Ambient floating mathematical particle background with luxury emerald/gold bokeh.
class ParticleBackground extends StatefulWidget {
  final Widget child;
  const ParticleBackground({super.key, required this.child});

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    final symbols = ['∫', '∑', 'π', '√', 'e', 'φ', 'Δ', 'λ', '∞', 'θ', 'µ', 'ƒ'];
    for (int i = 0; i < 28; i++) {
      _particles.add(
        _Particle(
          x: _random.nextDouble(),
          y: _random.nextDouble(),
          size: 14 + _random.nextDouble() * 22,
          speed: 0.02 + _random.nextDouble() * 0.04,
          drift: (_random.nextDouble() - 0.5) * 0.02,
          opacity: 0.04 + _random.nextDouble() * 0.12,
          symbol: symbols[_random.nextInt(symbols.length)],
          isEmerald: _random.nextBool(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base gradient background
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.6, -0.7),
                radius: 1.4,
                colors: LuxuryTheme.isDark
                    ? const [
                        Color(0xFF131D17), // Deep emerald-tinged dark obsidian
                        Color(0xFF090D0B),
                        Color(0xFF070A08),
                      ]
                    : const [
                        Color(0xFFE8EFEA), // Light pearl with soft olive-mint undertone
                        Color(0xFFF4F6F4),
                        Color(0xFFDFE6E0),
                      ],
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
          ),
        ),

        // Animated particles
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: _ParticlePainter(
                  particles: _particles,
                  progress: _controller.value,
                ),
              );
            },
          ),
        ),

        // Ambient top-right subtle gold glow
        Positioned(
          top: -120,
          right: -100,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  LuxuryTheme.goldPrimary.withOpacity(0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Main app content
        widget.child,
      ],
    );
  }
}

class _Particle {
  double x;
  double y;
  final double size;
  final double speed;
  final double drift;
  final double opacity;
  final String symbol;
  final bool isEmerald;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.drift,
    required this.opacity,
    required this.symbol,
    required this.isEmerald,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _ParticlePainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particles) {
      final currentY = (p.y - progress * p.speed * 4) % 1.0;
      final currentX = (p.x + math.sin(progress * 2 * math.pi + p.size) * p.drift) % 1.0;

      final offset = Offset(currentX * size.width, currentY * size.height);
      final color = p.isEmerald ? LuxuryTheme.emeraldPrimary : LuxuryTheme.goldPrimary;

      final textSpan = TextSpan(
        text: p.symbol,
        style: TextStyle(
          color: color.withOpacity(p.opacity),
          fontSize: p.size,
          fontFamily: 'serif',
          fontWeight: FontWeight.w300,
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(canvas, offset);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}

