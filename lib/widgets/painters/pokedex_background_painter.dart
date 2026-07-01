import 'package:flutter/material.dart';

class PokedexBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFD32F2F); // Main red color

    // Draw main red background with rounded corners
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(16),
      ),
      paint,
    );

    // Top-left blue camera circle with white border
    final cameraCenter = Offset(40, 40);
    final cameraRadius = 20.0;
    paint.color = Colors.white;
    canvas.drawCircle(cameraCenter, cameraRadius + 4, paint);
    paint.color = Colors.blue;
    canvas.drawCircle(cameraCenter, cameraRadius, paint);

    // Three small indicator lights (green, yellow, red)
    const indicatorColors = [Colors.green, Colors.yellow, Colors.red];
    for (int i = 0; i < 3; i++) {
      paint.color = indicatorColors[i];
      canvas.drawCircle(Offset(80.0 + (i * 20), 26.0), 6, paint);
    }

    // Main screen frame (white border with inner dark screen)
    final screenFrame = Rect.fromLTWH(40, 90, size.width - 80, size.height * 0.35);
    paint.color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(screenFrame, const Radius.circular(6)),
      paint,
    );

    // Small red button below screen
    paint.color = Colors.red.shade800;
    canvas.drawCircle(Offset(screenFrame.left + 20, screenFrame.bottom + 20), 10, paint);

    // Speaker lines
    paint.color = Colors.black;
    const speakerLineHeight = 4.0;
    for (int i = 0; i < 3; i++) {
      canvas.drawRect(
        Rect.fromLTWH(
          screenFrame.right - 40,
          screenFrame.bottom + 10 + (i * (speakerLineHeight + 2)),
          25,
          speakerLineHeight,
        ),
        paint,
      );
    }

    // Green rectangle screen at bottom
    paint.color = Colors.green.shade700;
    canvas.drawRect(
      Rect.fromLTWH(40, size.height - 70, 100, 30),
      paint,
    );

    // Directional pad (D-pad)
    paint.color = Colors.black;
    const dpadSize = 20.0;
    canvas.drawRect(
      Rect.fromLTWH(size.width - 80, size.height - 90, dpadSize, 60),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width - 100, size.height - 70, 60, dpadSize),
      paint,
    );

    // Extra circle button (like select/start)
    paint.color = Colors.black;
    canvas.drawCircle(Offset(50, size.height - 110), 10, paint);

    // Small horizontal indicators near green screen
    paint.color = Colors.teal;
    canvas.drawRect(Rect.fromLTWH(150, size.height - 60, 40, 6), paint);
    paint.color = Colors.red;
    canvas.drawRect(Rect.fromLTWH(150, size.height - 48, 40, 6), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}