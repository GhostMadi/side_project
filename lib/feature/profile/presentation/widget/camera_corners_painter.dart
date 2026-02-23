import 'package:flutter/material.dart';

class CameraCornersPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    const len = 10.0;

    canvas.drawPath(Path()..moveTo(0, len)..lineTo(0, 0)..lineTo(len, 0), paint);
    canvas.drawPath(Path()..moveTo(size.width - len, 0)..lineTo(size.width, 0)..lineTo(size.width, len), paint);
    canvas.drawPath(Path()..moveTo(0, size.height - len)..lineTo(0, size.height)..lineTo(len, size.height), paint);
    canvas.drawPath(Path()..moveTo(size.width - len, size.height)..lineTo(size.width, size.height)..lineTo(size.width, size.height - len), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}