import 'dart:math';
import 'package:flutter/material.dart';

class MacroRing extends StatelessWidget {
  final double calories;
  final double goal;
  final double size;

  const MacroRing({
    super.key,
    required this.calories,
    required this.goal,
    this.size = 90,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (calories / goal).clamp(0.0, 1.0);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(progress: progress),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = size.width / 2 - 8;
    final stroke = 8.0;

    final bgPaint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final fgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(Offset(cx, cy), radius, bgPaint);
    final sweep = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      -pi / 2,
      sweep,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}