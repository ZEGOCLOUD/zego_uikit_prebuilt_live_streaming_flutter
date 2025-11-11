// Dart imports:
import 'dart:math' as math;

// Flutter imports:
import 'package:flutter/material.dart';

/// Wave line painter
class ZegoLiveStreamingLiveHallEnterWavePainter extends CustomPainter {
  ZegoLiveStreamingLiveHallEnterWavePainter({
    required this.progress,
    required this.color,
  });

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final centerY = size.height / 2;
    final waveLength = size.width * 0.8;
    final amplitude = size.height * 0.3;
    final offsetX = progress * waveLength * 2;

    final path = Path();
    final points = <Offset>[];

    for (double x = 0; x <= size.width; x += 1) {
      final normalizedX = (x + offsetX) / waveLength;
      final y = centerY + math.sin(normalizedX * 2 * math.pi) * amplitude;
      points.add(Offset(x, y));
    }

    if (points.isNotEmpty) {
      path.moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(ZegoLiveStreamingLiveHallEnterWavePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
