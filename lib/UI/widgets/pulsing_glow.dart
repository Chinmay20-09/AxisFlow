import 'package:flutter/material.dart';

// ── Pulsing glow blob ──────────────────────────────────────────────────────────
/// An ambient pulsing glow effect used inside glass cards.
class PulsingGlow extends StatefulWidget {
  const PulsingGlow({super.key});

  @override
  State<PulsingGlow> createState() => _PulsingGlowState();
}

class _PulsingGlowState extends State<PulsingGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _opacity = Tween<double>(
      begin: 0.5,
      end: 0.8,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        width: 128,
        height: 128,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: (0.05)),
              blurRadius: 60,
              spreadRadius: 30,
            ),
          ],
        ),
      ),
    );
  }
}
