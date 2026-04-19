import 'dart:math';
import 'package:flutter/material.dart';

class MacroRing extends StatelessWidget {
  final double calories;
  final double goal;
  final double size;

  const MacroRing({super.key, required this.calories, required this.goal, required this.size});

  @override
  Widget build(BuildContext context) {
    final progress = (calories / goal).clamp(0.0, 1.0);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(progress),
        child: Center(
          child: Text(
            '${(progress * 100).toInt()}%',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  _RingPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    final strokeWidth = 7.0;

    final bgPaint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final fgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}
