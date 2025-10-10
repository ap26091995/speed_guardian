import 'dart:math';

import 'package:flutter/material.dart';

class Speedometer extends StatelessWidget {
  Speedometer({
    required this.speed,
    required this.speedRecord,
    this.size = 290
  });

  final double speed;
  final double speedRecord;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
        painter: SpeedometerPainter(
            speed: speed,
            speedRecord: speedRecord
        ),
        size: Size(size, size)
    );
  }
}


class SpeedometerPainter extends CustomPainter {
  SpeedometerPainter({
    required this.speed,
    required this.speedRecord
  });

  final double speed;
  final double speedRecord;

  Size? size;
  Canvas? canvas;
  Offset? center;
  Paint? paintObject;

  @override
  void paint(Canvas canvas, Size size) {}

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }}
