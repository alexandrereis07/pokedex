import 'package:flutter/material.dart';

// ── Palette ──────────────────────────────────────────────────────────────────
const kPokedexRed = Color(0xFFCC0000);
const kPokedexDarkRed = Color(0xFF880000);
const kScreenBg = Color(0xFF0D1B0D);
const kScreenGreen = Color(0xFF33FF57);

// ── Lens (blue eye) ──────────────────────────────────────────────────────────
class PokedexLens extends StatelessWidget {
  final VoidCallback? onTap;
  const PokedexLens({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
          gradient: const RadialGradient(
            colors: [Color(0xFFBBDEFB), Color(0xFF1565C0), Color(0xFF0D47A1)],
            stops: [0.0, 0.45, 1.0],
            center: Alignment(-0.4, -0.4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withValues(alpha: 0.55),
              blurRadius: 14,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Center(
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.28),
              border: Border.all(color: Colors.white38, width: 1),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Indicator lights ──────────────────────────────────────────────────────────
class PokedexIndicatorLights extends StatelessWidget {
  const PokedexIndicatorLights({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Light(color: Color(0xFF4CAF50)),
        SizedBox(width: 6),
        _Light(color: Color(0xFFFFEB3B)),
        SizedBox(width: 6),
        _Light(color: Color(0xFFFF5252)),
      ],
    );
  }
}

class _Light extends StatelessWidget {
  final Color color;
  const _Light({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.9),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}

// ── Hinge separator ───────────────────────────────────────────────────────────
class PokedexHinge extends StatelessWidget {
  const PokedexHinge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF550000), Color(0xFF990000), Color(0xFF550000)],
        ),
        boxShadow: [
          BoxShadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
    );
  }
}

// ── LCD screen container ──────────────────────────────────────────────────────
class PokedexScreen extends StatelessWidget {
  final Widget child;
  final String? label;
  const PokedexScreen({super.key, required this.child, this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kScreenBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF555555), width: 3),
        boxShadow: const [
          BoxShadow(color: Colors.black87, blurRadius: 8, offset: Offset(2, 2)),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            decoration: const BoxDecoration(
              color: Color(0xFF080E08),
              borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
            ),
            child: Row(
              children: [
                _dot(), const SizedBox(width: 5),
                _dot(), const SizedBox(width: 5),
                _dot(),
                if (label != null) ...[
                  const Spacer(),
                  Text(
                    label!,
                    style: const TextStyle(
                      fontFamily: 'Pokemon',
                      color: kScreenGreen,
                      fontSize: 8,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _dot() => Container(
        width: 7,
        height: 7,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: kScreenGreen,
        ),
      );
}

// ── Speaker grills ────────────────────────────────────────────────────────────
class PokedexSpeaker extends StatelessWidget {
  const PokedexSpeaker({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (_) => Container(
          width: 38,
          height: 3,
          margin: const EdgeInsets.symmetric(vertical: 2),
          decoration: BoxDecoration(
            color: kPokedexDarkRed,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

// ── D-pad ─────────────────────────────────────────────────────────────────────
class PokedexDPad extends StatelessWidget {
  const PokedexDPad({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 72,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 22,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Container(
            width: 72,
            height: 22,
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
          ),
          const Positioned(top: 3, child: Icon(Icons.arrow_drop_up, color: Colors.white38, size: 16)),
          const Positioned(bottom: 3, child: Icon(Icons.arrow_drop_down, color: Colors.white38, size: 16)),
          const Positioned(left: 3, child: Icon(Icons.arrow_left, color: Colors.white38, size: 16)),
          const Positioned(right: 3, child: Icon(Icons.arrow_right, color: Colors.white38, size: 16)),
        ],
      ),
    );
  }
}

// ── Round action button ───────────────────────────────────────────────────────
class PokedexActionButton extends StatelessWidget {
  final Color color;
  final String label;
  final VoidCallback? onTap;

  const PokedexActionButton({
    super.key,
    required this.color,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: const [
            BoxShadow(
                color: Colors.black54, blurRadius: 4, offset: Offset(2, 3)),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            fontFamily: 'Pokemon',
          ),
        ),
      ),
    );
  }
}

// ── Small pill button (SEL / STA) ─────────────────────────────────────────────
class PokedexPillButton extends StatelessWidget {
  final String label;
  const PokedexPillButton({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: kPokedexDarkRed,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        '',
        style: TextStyle(color: Colors.white54, fontSize: 8),
      ),
    );
  }
}

// ── Outer Pokédex body shell ──────────────────────────────────────────────────
class PokedexBody extends StatelessWidget {
  final Widget child;
  const PokedexBody({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE52020), Color(0xFF990000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Colors.black54, blurRadius: 24, offset: Offset(4, 10)),
        ],
      ),
      child: child,
    );
  }
}
