import 'package:flutter/material.dart';
import 'package:pokedex/views/home_screen.dart';

// ── Game Boy palette ──────────────────────────────────────────────────────────
const _gbDark = Color(0xFF0f380f);
const _gbMid = Color(0xFF306230);
const _gbLight = Color(0xFF8bac0f);
const _gbLighter = Color(0xFF9bbc0f);

// Converts sprite colors to 4-shade Game Boy green palette
const _gbFilter = ColorFilter.matrix([
  0.10, 0.20, 0.04, 0, 0.06,
  0.14, 0.26, 0.05, 0, 0.22,
  0.02, 0.06, 0.01, 0, 0.06,
  0,    0,    0,    1, 0,
]);

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _ctrl;

  late final Animation<double> _screenOn;
  late final Animation<double> _nidorinoIn;
  late final Animation<double> _nidorinoHp;
  late final Animation<double> _gengarIn;
  late final Animation<double> _gengarHp;
  late final Animation<double> _vsOpacity;
  late final Animation<double> _flash;
  late final Animation<Offset> _shake;
  late final Animation<double> _titleOpacity;
  late final Animation<double> _blinkOpacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 6800),
      vsync: this,
    );

    _screenOn = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.00, 0.10, curve: Curves.easeIn),
    );
    _nidorinoIn = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.10, 0.28, curve: Curves.easeOut),
    );
    _nidorinoHp = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.26, 0.36, curve: Curves.easeOut),
    );
    _gengarIn = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.34, 0.52, curve: Curves.easeOut),
    );
    _gengarHp = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.50, 0.60, curve: Curves.easeOut),
    );
    _vsOpacity = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.56, 0.65, curve: Curves.easeIn),
    );
    _flash = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.9), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 0.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.5), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 0.0), weight: 15),
    ]).animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.65, 0.82),
    ));
    _shake = TweenSequence<Offset>([
      TweenSequenceItem(
          tween: Tween(begin: Offset.zero, end: const Offset(-18, 0)),
          weight: 20),
      TweenSequenceItem(
          tween: Tween(begin: const Offset(-18, 0), end: const Offset(14, 0)),
          weight: 20),
      TweenSequenceItem(
          tween: Tween(begin: const Offset(14, 0), end: const Offset(-10, 0)),
          weight: 20),
      TweenSequenceItem(
          tween: Tween(begin: const Offset(-10, 0), end: const Offset(6, 0)),
          weight: 20),
      TweenSequenceItem(
          tween:
              Tween(begin: const Offset(6, 0), end: Offset.zero),
          weight: 20),
    ]).animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.65, 0.78),
    ));
    _titleOpacity = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.82, 0.94, curve: Curves.easeIn),
    );
    _blinkOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 50),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.94, 1.0),
    ));

    _ctrl.forward().then((_) {
      if (mounted) _navigate();
    });
  }

  void _navigate() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionDuration: const Duration(milliseconds: 600),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => Stack(
          fit: StackFit.expand,
          children: [
            // Game Boy screen
            Opacity(
              opacity: _screenOn.value,
              child: _buildBattleScene(size),
            ),
            // Attack flash
            if (_flash.value > 0)
              Opacity(
                opacity: _flash.value,
                child: Container(color: _gbLighter),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBattleScene(Size size) {
    final sw = size.width;
    final sh = size.height;

    return Container(
      color: _gbLighter,
      child: Stack(
        children: [
          // Scanlines
          Positioned.fill(child: CustomPaint(painter: _ScanlinesPainter())),

          // ── Enemy platform (top-right) ─────────────────────────────────
          Positioned(
            top: sh * 0.32,
            child: CustomPaint(
              size: Size(sw, 24),
              painter: _PlatformPainter(right: true),
            ),
          ),

          // ── Player platform (bottom-left) ─────────────────────────────
          Positioned(
            top: sh * 0.58,
            child: CustomPaint(
              size: Size(sw, 24),
              painter: _PlatformPainter(right: false),
            ),
          ),

          // ── Nidorino (enemy, top-right) ────────────────────────────────
          Positioned(
            top: sh * 0.10,
            right: sw * 0.04 + (1 - _nidorinoIn.value) * sw * 0.7,
            child: Transform.translate(
              offset: _shake.value,
              child: _sprite(33, sw * 0.36, flip: false),
            ),
          ),

          // ── Gengar (player, bottom-left) ───────────────────────────────
          Positioned(
            top: sh * 0.34,
            left: sw * 0.02 - (1 - _gengarIn.value) * sw * 0.7,
            child: _sprite(94, sw * 0.42, flip: true),
          ),

          // ── Enemy HP bar (top-left) ────────────────────────────────────
          Positioned(
            top: 16,
            left: 12,
            right: sw * 0.38,
            child: Opacity(
              opacity: _nidorinoHp.value,
              child: _HpBar(
                name: 'NIDORINO',
                level: 5,
                hp: 35,
                maxHp: 35,
                showNumbers: false,
              ),
            ),
          ),

          // ── Player HP bar (bottom-right) ────────────────────────────────
          Positioned(
            top: sh * 0.60,
            right: 12,
            left: sw * 0.35,
            child: Opacity(
              opacity: _gengarHp.value,
              child: _HpBar(
                name: 'GENGAR',
                level: 35,
                hp: 89,
                maxHp: 89,
                showNumbers: true,
              ),
            ),
          ),

          // ── VS ─────────────────────────────────────────────────────────
          Center(
            child: Opacity(
              opacity: _vsOpacity.value,
              child: _gbText('VS!', 30),
            ),
          ),

          // ── Title + blink ───────────────────────────────────────────────
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: _titleOpacity.value,
              child: Column(
                children: [
                  _gbText('POKEDEX', 20),
                  const SizedBox(height: 14),
                  Opacity(
                    opacity: _blinkOpacity.value,
                    child: _gbText('PRESS  START', 8),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sprite(int id, double size, {required bool flip}) {
    final url =
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/versions/generation-i/red-blue/transparent/$id.png';
    return Transform.scale(
      scaleX: flip ? -1.0 : 1.0,
      child: ColorFiltered(
        colorFilter: _gbFilter,
        child: Image.network(
          url,
          width: size,
          height: size,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.none,
          errorBuilder: (_, __, ___) => SizedBox(width: size, height: size),
        ),
      ),
    );
  }

  static Widget _gbText(String text, double fontSize) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: 'Pokemon',
        fontSize: fontSize,
        color: _gbDark,
        letterSpacing: 2,
      ),
    );
  }
}

// ── HP bar ────────────────────────────────────────────────────────────────────

class _HpBar extends StatelessWidget {
  final String name;
  final int level;
  final int hp;
  final int maxHp;
  final bool showNumbers;

  const _HpBar({
    required this.name,
    required this.level,
    required this.hp,
    required this.maxHp,
    required this.showNumbers,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = hp / maxHp;
    final barColor = ratio > 0.5
        ? _gbMid
        : ratio > 0.25
            ? _gbLight
            : Colors.red.shade800;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      decoration: BoxDecoration(
        color: _gbLighter,
        border: Border.all(color: _gbDark, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _t(name, 6),
              _t('♂Lv$level', 6),
            ],
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              _t('HP', 5),
              const SizedBox(width: 3),
              Expanded(
                child: Container(
                  height: 5,
                  decoration: BoxDecoration(
                    color: _gbDark,
                    border: Border.all(color: _gbDark, width: 1),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: ratio,
                      child: Container(color: barColor),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (showNumbers) ...[
            const SizedBox(height: 2),
            Align(
              alignment: Alignment.centerRight,
              child: _t('$hp/$maxHp', 6),
            ),
          ],
        ],
      ),
    );
  }

  static Widget _t(String text, double size) => Text(
        text,
        style: TextStyle(
          fontFamily: 'Pokemon',
          fontSize: size,
          color: _gbDark,
        ),
      );
}

// ── Scanlines painter ─────────────────────────────────────────────────────────

class _ScanlinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0x18000000)
      ..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 3) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(_ScanlinesPainter _) => false;
}

// ── Battle platform painter ───────────────────────────────────────────────────

class _PlatformPainter extends CustomPainter {
  final bool right;
  const _PlatformPainter({required this.right});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = right ? size.width * 0.70 : size.width * 0.30;
    final rect = Rect.fromCenter(
      center: Offset(cx, 12),
      width: size.width * 0.52,
      height: 22,
    );
    canvas.drawOval(rect, Paint()..color = _gbDark);
    canvas.drawOval(
      rect.deflate(3),
      Paint()..color = _gbMid,
    );
  }

  @override
  bool shouldRepaint(_PlatformPainter _) => false;
}
