import 'dart:math' show min;

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:pokedex/services/pokemon_service.dart';
import 'package:pokedex/utils/utils.dart';
import 'package:pokedex/views/catch_screen.dart';
import 'package:pokedex/widgets/pokemon_text.dart';
import 'package:pokedex/widgets/pokeloader.dart';
import 'package:pokedex/widgets/pokedex_ui.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with SingleTickerProviderStateMixin {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  String? _initError;
  String? _scanResult;
  bool _isMatch = false;
  late AnimationController _scanAnim;
  final _service = PokemonService();

  @override
  void initState() {
    super.initState();
    _scanAnim = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) setState(() => _initError = 'NO CAMERA FOUND');
        return;
      }
      _controller = CameraController(cameras.first, ResolutionPreset.high);
      await _controller!.initialize();
      if (mounted) {
        setState(() => _isCameraInitialized = true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _initError = 'CAMERA ERROR');
      }
    }
  }

  Future<void> _scan() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isProcessing) {
      return;
    }
    setState(() {
      _isProcessing = true;
      _scanResult = null;
    });
    _scanAnim.repeat();

    try {
      final picture = await _controller!.takePicture();
      final detectedName = await compareAndMatchImage(picture.path);

      if (!mounted) return;
      _scanAnim.stop();
      _scanAnim.reset();

      if (detectedName != null) {
        final pokemon = await _service.fetchPokemonByName(detectedName);
        if (!mounted) return;
        setState(() => _isProcessing = false);
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CatchScreen(pokemon: pokemon)),
        );
      } else {
        setState(() {
          _isMatch = false;
          _scanResult = 'NO POKEMON FOUND';
          _isProcessing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        _scanAnim.stop();
        _scanAnim.reset();
        setState(() {
          _isMatch = false;
          _scanResult = 'SCAN ERROR';
          _isProcessing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _scanAnim.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_initError != null) return _buildErrorState();
    if (!_isCameraInitialized) return _buildLoadingState();

    final size = MediaQuery.sizeOf(context);
    final bottomH = size.height * 0.24;
    final circleRadius = min(size.width, size.height - bottomH) * 0.42;
    final circleCenter = Offset(size.width / 2, (size.height - bottomH) * 0.48);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Camera feed ──────────────────────────────────────────────
          CameraPreview(_controller!),

          // ── Viewfinder overlay ───────────────────────────────────────
          AnimatedBuilder(
            animation: _scanAnim,
            builder: (_, __) => CustomPaint(
              painter: _ViewfinderPainter(
                center: circleCenter,
                radius: circleRadius,
                isScanning: _isProcessing,
                scanProgress: _scanAnim.value,
              ),
            ),
          ),

          // ── Scan result banner ───────────────────────────────────────
          if (_scanResult != null)
            Positioned(
              top: circleCenter.dy + circleRadius + 12,
              left: 32,
              right: 32,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.82),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _isMatch
                          ? const Color(0xFF4CAF50)
                          : Colors.red,
                      width: 2,
                    ),
                  ),
                  child: PokemonText(
                    text: _scanResult!,
                    fontSize: 10,
                    color: _isMatch ? const Color(0xFF4CAF50) : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          // ── Back button ──────────────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // ── Bottom Pokédex control section ───────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: bottomH,
            child: _buildBottomSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE02020), Color(0xFF990000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          // Left decorative controls
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const PokedexSpeaker(),
                const SizedBox(height: 6),
                Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF550000),
                  ),
                ),
              ],
            ),
          ),
          // Center scan button
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _scan,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isProcessing
                          ? Colors.grey.shade700
                          : const Color(0xFF1565C0),
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: (_isProcessing
                                  ? Colors.grey
                                  : Colors.blue)
                              .withValues(alpha: 0.55),
                          blurRadius: 14,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: _isProcessing
                        ? const Center(child: PokeballLoader(size: 36))
                        : const Icon(Icons.camera_alt,
                            color: Colors.white, size: 28),
                  ),
                ),
                const SizedBox(height: 5),
                const PokemonText(
                    text: 'SCAN', fontSize: 8, color: Colors.white70),
              ],
            ),
          ),
          // Right decorative D-pad
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Transform.scale(
              scale: 0.7,
              child: const PokedexDPad(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Scaffold(
      backgroundColor: kPokedexRed,
      body: Center(child: PokeballLoader(size: 80)),
    );
  }

  Widget _buildErrorState() {
    return Scaffold(
      backgroundColor: kPokedexRed,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Lens as decorative element
                const PokedexLens(),
                const SizedBox(height: 8),
                // Red X over it
                const Icon(Icons.close, color: Colors.white, size: 40),
                const SizedBox(height: 20),
                const PokemonText(
                  text: 'CAMERA\nNOT AVAILABLE',
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 28),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: Colors.white54, width: 1),
                    ),
                    child: const PokemonText(
                      text: '[ GO BACK ]',
                      fontSize: 11,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Viewfinder painter ────────────────────────────────────────────────────────

class _ViewfinderPainter extends CustomPainter {
  final Offset center;
  final double radius;
  final bool isScanning;
  final double scanProgress;

  _ViewfinderPainter({
    required this.center,
    required this.radius,
    required this.isScanning,
    required this.scanProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Dark overlay with circular hole
    final overlayPaint = Paint()..color = const Color(0xCC000000);
    final holePath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(Rect.fromCircle(center: center, radius: radius))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(holePath, overlayPaint);

    // White outer ring
    canvas.drawCircle(
      center,
      radius + 3,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );

    // Blue inner ring
    canvas.drawCircle(
      center,
      radius - 6,
      Paint()
        ..color = const Color(0xFF1565C0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Corner bracket reticle
    final bracket = Paint()
      ..color = kScreenGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.square;

    const bLen = 22.0;
    const bOff = 48.0;
    final cx = center.dx;
    final cy = center.dy;

    // Top-left
    canvas.drawLine(Offset(cx - bOff, cy - bOff + bLen), Offset(cx - bOff, cy - bOff), bracket);
    canvas.drawLine(Offset(cx - bOff, cy - bOff), Offset(cx - bOff + bLen, cy - bOff), bracket);
    // Top-right
    canvas.drawLine(Offset(cx + bOff, cy - bOff + bLen), Offset(cx + bOff, cy - bOff), bracket);
    canvas.drawLine(Offset(cx + bOff, cy - bOff), Offset(cx + bOff - bLen, cy - bOff), bracket);
    // Bottom-left
    canvas.drawLine(Offset(cx - bOff, cy + bOff - bLen), Offset(cx - bOff, cy + bOff), bracket);
    canvas.drawLine(Offset(cx - bOff, cy + bOff), Offset(cx - bOff + bLen, cy + bOff), bracket);
    // Bottom-right
    canvas.drawLine(Offset(cx + bOff, cy + bOff - bLen), Offset(cx + bOff, cy + bOff), bracket);
    canvas.drawLine(Offset(cx + bOff, cy + bOff), Offset(cx + bOff - bLen, cy + bOff), bracket);

    // Center crosshair dot
    canvas.drawCircle(
      center,
      3,
      Paint()
        ..color = kScreenGreen.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Scan line
    if (isScanning) {
      final top = center.dy - radius + 6;
      final bottom = center.dy + radius - 6;
      final y = top + (bottom - top) * scanProgress;

      // Glow
      canvas.drawLine(
        Offset(cx - radius + 18, y),
        Offset(cx + radius - 18, y),
        Paint()
          ..color = kScreenGreen.withValues(alpha: 0.25)
          ..strokeWidth = 8,
      );
      // Line
      canvas.drawLine(
        Offset(cx - radius + 18, y),
        Offset(cx + radius - 18, y),
        Paint()
          ..color = kScreenGreen
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(_ViewfinderPainter old) =>
      old.isScanning != isScanning || old.scanProgress != scanProgress;
}
