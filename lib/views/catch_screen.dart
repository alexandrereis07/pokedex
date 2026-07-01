import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pokedex/models/pokemon_model.dart';
import 'package:pokedex/views/details_screen.dart';
import 'package:pokedex/widgets/pokemon_text.dart';

// Session-level caught registry (in-memory)
final _caughtNames = <String>{};
bool isPokemonCaught(String name) => _caughtNames.contains(name);

enum _Phase { ready, throwing, capturing, shaking, caught, escaped }

class CatchScreen extends StatefulWidget {
  final PokemonModel pokemon;
  const CatchScreen({super.key, required this.pokemon});

  @override
  State<CatchScreen> createState() => _CatchScreenState();
}

class _CatchScreenState extends State<CatchScreen>
    with TickerProviderStateMixin {
  _Phase _phase = _Phase.ready;

  late final AnimationController _throwCtrl;
  late final AnimationController _captureCtrl;
  late final AnimationController _shakeCtrl;
  late final AnimationController _resultCtrl;
  late final AnimationController _pulseCtrl;

  late final Animation<double> _pokemonScale;
  late final Animation<double> _flash;
  late final Animation<double> _shakeAngle;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();

    _throwCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 650));

    _captureCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
    _pokemonScale = Tween<double>(begin: 1.0, end: 0.0)
        .animate(CurvedAnimation(parent: _captureCtrl, curve: Curves.easeIn));
    _flash = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 75),
    ]).animate(_captureCtrl);

    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2200));
    _shakeAngle = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 8),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -0.40), weight: 6),
      TweenSequenceItem(tween: Tween(begin: -0.40, end: 0.40), weight: 12),
      TweenSequenceItem(tween: Tween(begin: 0.40, end: 0.0), weight: 6),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 9),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -0.32), weight: 5),
      TweenSequenceItem(tween: Tween(begin: -0.32, end: 0.32), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 0.32, end: 0.0), weight: 5),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 9),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -0.24), weight: 4),
      TweenSequenceItem(tween: Tween(begin: -0.24, end: 0.24), weight: 8),
      TweenSequenceItem(tween: Tween(begin: 0.24, end: 0.0), weight: 4),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 14),
    ]).animate(_shakeCtrl);

    _resultCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));

    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.92, end: 1.08).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  Future<void> _throw() async {
    if (_phase != _Phase.ready) return;
    _pulseCtrl.stop();
    setState(() => _phase = _Phase.throwing);

    await _throwCtrl.forward();
    setState(() => _phase = _Phase.capturing);
    await _captureCtrl.forward();

    final didCatch = Random().nextDouble() < 0.70;
    setState(() => _phase = _Phase.shaking);
    await _shakeCtrl.forward();

    if (didCatch) {
      _caughtNames.add(widget.pokemon.name);
      setState(() => _phase = _Phase.caught);
    } else {
      setState(() => _phase = _Phase.escaped);
      _captureCtrl.reverse();
    }
    await _resultCtrl.forward();
  }

  void _reset() {
    _throwCtrl.reset();
    _captureCtrl.reset();
    _shakeCtrl.reset();
    _resultCtrl.reset();
    _pulseCtrl.repeat(reverse: true);
    setState(() => _phase = _Phase.ready);
  }

  @override
  void dispose() {
    _throwCtrl.dispose();
    _captureCtrl.dispose();
    _shakeCtrl.dispose();
    _resultCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final pokemonCenter = Offset(size.width / 2, size.height * 0.36);
    final ballStart = Offset(size.width / 2, size.height * 0.80);
    final ballShakePos = Offset(size.width / 2, size.height * 0.55);

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragEnd: (d) {
          if ((d.primaryVelocity ?? 0) < -300) _throw();
        },
        onTap: _throw,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Night sky ─────────────────────────────────────────────
            CustomPaint(painter: _NightSkyPainter()),

            // ── Grass ground ──────────────────────────────────────────
            Positioned(
              left: 0,
              right: 0,
              top: size.height * 0.58,
              child: CustomPaint(
                size: Size(size.width, 48),
                painter: _GrassPainter(),
              ),
            ),

            // ── Header ────────────────────────────────────────────────
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  PokemonText(
                    text: 'Wild ${widget.pokemon.name.toUpperCase()}',
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  const PokemonText(
                    text: 'appeared!',
                    fontSize: 10,
                    color: Colors.white70,
                  ),
                ],
              ),
            ),

            // ── Pokémon sprite ────────────────────────────────────────
            AnimatedBuilder(
              animation: _captureCtrl,
              builder: (_, __) => Positioned(
                left: pokemonCenter.dx - 100,
                top: pokemonCenter.dy - 100,
                child: Transform.scale(
                  scale: _pokemonScale.value,
                  child: Image.network(
                    widget.pokemon.imageUrl,
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.catching_pokemon,
                      color: Colors.white,
                      size: 120,
                    ),
                  ),
                ),
              ),
            ),

            // ── Pokéball ──────────────────────────────────────────────
            AnimatedBuilder(
              animation:
                  Listenable.merge([_throwCtrl, _shakeCtrl, _pulseCtrl]),
              builder: (_, __) {
                final t = _throwCtrl.value;
                double x = 0, y = 0, sz = 0, angle = 0;

                switch (_phase) {
                  case _Phase.ready:
                    x = ballStart.dx;
                    y = ballStart.dy;
                    sz = 60 * _pulse.value;
                    angle = 0;
                    break;
                  case _Phase.throwing:
                    x = ballStart.dx + (pokemonCenter.dx - ballStart.dx) * t;
                    y = ballStart.dy +
                        (pokemonCenter.dy - ballStart.dy) * t -
                        sin(t * pi) * 80;
                    sz = 60 * (1 - t * 0.22);
                    angle = t * 2 * pi * 3;
                    break;
                  case _Phase.capturing:
                    x = pokemonCenter.dx;
                    y = pokemonCenter.dy;
                    sz = 56;
                    angle = 0;
                    break;
                  case _Phase.shaking:
                  case _Phase.caught:
                  case _Phase.escaped:
                    x = ballShakePos.dx;
                    y = ballShakePos.dy;
                    sz = 64;
                    angle = _shakeAngle.value;
                    break;
                }

                return Positioned(
                  left: x - sz / 2,
                  top: y - sz / 2,
                  child: Transform.rotate(
                    angle: angle,
                    child: Image.asset(
                      'assets/images/pokeball.png',
                      width: sz,
                      height: sz,
                    ),
                  ),
                );
              },
            ),

            // ── White flash ───────────────────────────────────────────
            AnimatedBuilder(
              animation: _captureCtrl,
              builder: (_, __) => _flash.value > 0
                  ? Opacity(
                      opacity: _flash.value,
                      child: Container(color: Colors.white),
                    )
                  : const SizedBox.shrink(),
            ),

            // ── Status / result ───────────────────────────────────────
            Positioned(
              bottom: size.height * 0.06,
              left: 0,
              right: 0,
              child: Center(child: _buildStatus()),
            ),

            // ── Back button ───────────────────────────────────────────
            if (_phase == _Phase.ready || _phase == _Phase.escaped)
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 12,
                child: Container(
                  decoration:
                      const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatus() {
    switch (_phase) {
      case _Phase.ready:
        return const PokemonText(
          text: '[ TAP TO THROW ]',
          fontSize: 10,
          color: Colors.white60,
        );

      case _Phase.throwing:
      case _Phase.capturing:
      case _Phase.shaking:
        return const SizedBox.shrink();

      case _Phase.caught:
        return AnimatedBuilder(
          animation: _resultCtrl,
          builder: (_, __) => Opacity(
            opacity: _resultCtrl.value,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const PokemonText(
                  text: 'GOTCHA!',
                  fontSize: 22,
                  color: Color(0xFFFFD700),
                  fontWeight: FontWeight.bold,
                ),
                PokemonText(
                  text:
                      '${widget.pokemon.name.toUpperCase()} was caught!',
                  fontSize: 11,
                  color: Colors.white,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _Btn(
                      label: 'POKÉDEX',
                      color: const Color(0xFF1565C0),
                      onTap: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              DetailsScreen(pokemon: widget.pokemon),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    _Btn(
                      label: 'CONTINUE',
                      color: const Color(0xFF2e7d32),
                      onTap: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );

      case _Phase.escaped:
        return AnimatedBuilder(
          animation: _resultCtrl,
          builder: (_, __) => Opacity(
            opacity: _resultCtrl.value,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const PokemonText(
                  text: 'OH NO!',
                  fontSize: 16,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
                PokemonText(
                  text:
                      '${widget.pokemon.name.toUpperCase()} broke free!',
                  fontSize: 11,
                  color: Colors.white70,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _Btn(
                      label: 'TRY AGAIN',
                      color: const Color(0xFFE02020),
                      onTap: _reset,
                    ),
                    const SizedBox(width: 16),
                    _Btn(
                      label: 'RUN',
                      color: Colors.grey.shade700,
                      onTap: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
    }
  }
}

// ── Button widget ─────────────────────────────────────────────────────────────

class _Btn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _Btn(
      {required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white24, width: 1),
        ),
        child: PokemonText(
          text: label,
          fontSize: 10,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ── Night sky background ──────────────────────────────────────────────────────

class _NightSkyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [Color(0xFF0d0d2b), Color(0xFF1a1a2e), Color(0xFF16213e)],
        ).createShader(Offset.zero & size),
    );
    final rng = Random(42);
    final star = Paint()..color = Colors.white;
    for (var i = 0; i < 80; i++) {
      canvas.drawCircle(
        Offset(rng.nextDouble() * size.width,
            rng.nextDouble() * size.height * 0.65),
        rng.nextDouble() * 1.8 + 0.4,
        star,
      );
    }
  }

  @override
  bool shouldRepaint(_NightSkyPainter _) => false;
}

// ── Grass ground ──────────────────────────────────────────────────────────────

class _GrassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 10, size.width, size.height),
      Paint()..color = const Color(0xFF1b4d1b),
    );
    canvas.drawLine(
      Offset(0, 10),
      Offset(size.width, 10),
      Paint()
        ..color = const Color(0xFF3aaa3a)
        ..strokeWidth = 3,
    );
    final rng = Random(7);
    final tuft = Paint()
      ..color = const Color(0xFF3aaa3a)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 36; i++) {
      final x = rng.nextDouble() * size.width;
      canvas.drawLine(
        Offset(x, 10),
        Offset(x + rng.nextDouble() * 10 - 5, -5),
        tuft,
      );
    }
  }

  @override
  bool shouldRepaint(_GrassPainter _) => false;
}
