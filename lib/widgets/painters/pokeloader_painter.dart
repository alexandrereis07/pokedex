import 'dart:math' as math;
import 'package:flutter/material.dart';

class PokeloaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double strokeWidth = size.width / 15;
    final double radius = (size.width - strokeWidth) / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);

    // Paint for the red top half
    final redPaint = Paint()..color = Colors.red.shade700;
    // Paint for the white bottom half
    final whitePaint = Paint()..color = Colors.white;
    // Paint for the black dividing line and outer circle of the button
    final blackPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    // Paint for the white inner circle of the button
    final innerButtonPaint = Paint()..color = Colors.white;

    // Draw red top half (arc)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi, // Start angle (top)
      math.pi,   // Sweep angle (180 degrees)
      true,      // Use center
      redPaint,
    );

    // Draw white bottom half (arc)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,         // Start angle (right side, effectively bottom after rotation)
      math.pi,   // Sweep angle (180 degrees)
      true,      // Use center
      whitePaint,
    );

    // Draw black dividing line (straight line)
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      blackPaint..style = PaintingStyle.fill, // Temporarily fill for thicker line
    );
    // Reset blackPaint style if you use it for strokes later
    blackPaint.style = PaintingStyle.stroke;


    // Draw outer black circle for the button
    canvas.drawCircle(center, radius / 2.5, blackPaint);

    // Draw inner white circle for the button
    canvas.drawCircle(center, radius / 4, innerButtonPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false; // Since the animation is handled by RotationTransition
  }
}