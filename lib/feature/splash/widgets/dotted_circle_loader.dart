import 'dart:math';
import 'package:flutter/material.dart';

class DottedCircleLoader extends StatefulWidget {
  const DottedCircleLoader({super.key});

  @override
  State<DottedCircleLoader> createState() => _DottedCircleLoaderState();
}

class _DottedCircleLoaderState extends State<DottedCircleLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RotationTransition(
        turns: _controller,
        child: CustomPaint(
          size: const Size(60, 60),
          painter: _LoaderPainter(),
        ),
      ),
    );
  }
}

class _LoaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2E7D32)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 3;

    //final dotSizes = [12.0, 10.0, 8.0, 6.0, 5.0, 4.0, 3.0, 2.0];
    final dotSizes = [0.8, 1.0, 1.5, 2.0, 3.0, 4.0, 5.0, 7.0];

    double angleStep = (1.5 * pi) / (dotSizes.length - 1);

    for (int i = 0; i < dotSizes.length; i++) {
      double angle = i * angleStep;
      double x = center.dx + radius * cos(angle);
      double y = center.dy + radius * sin(angle);

      canvas.drawCircle(Offset(x, y), dotSizes[i], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}