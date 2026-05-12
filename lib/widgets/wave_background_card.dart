import 'dart:math' as math;
import 'package:flutter/material.dart';

class WaveBackgroundCard extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;

  const WaveBackgroundCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.backgroundColor,
  });

  @override
  State<WaveBackgroundCard> createState() => _WaveBackgroundCardState();
}

class _WaveBackgroundCardState extends State<WaveBackgroundCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.white,
        borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Wave background
          Positioned.fill(
            child: ClipRRect(
              borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
              child: AnimatedBuilder(
                animation: _waveController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: WavePainter(_waveController.value),
                    size: Size(
                      widget.width ?? double.infinity,
                      widget.height ?? double.infinity,
                    ),
                  );
                },
              ),
            ),
          ),
          // Content
          Padding(
            padding: widget.padding ?? EdgeInsets.all(16),
            child: widget.child,
          ),
        ],
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  final double animationValue;

  WavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw multiple wave layers
    _drawWave(
      canvas,
      size,
      paint..color = const Color(0xFFE0F2FE).withOpacity(0.6),
      0.8,
      animationValue * 2 * math.pi,
      40,
    );

    _drawWave(
      canvas,
      size,
      paint..color = const Color(0xFFE0F2FE).withOpacity(0.5),
      0.85,
      animationValue * 2 * math.pi + math.pi / 3,
      30,
    );

    _drawWave(
      canvas,
      size,
      paint..color = const Color(0xFFE0F2FE).withOpacity(0.4),
      0.9,
      animationValue * 2 * math.pi + math.pi / 1.5,
      25,
    );
  }

  void _drawWave(
    Canvas canvas,
    Size size,
    Paint paint,
    double yPosition,
    double phase,
    double amplitude,
  ) {
    final path = Path();
    final y = size.height * yPosition;
    final waveLength = size.width / 2.5;

    path.moveTo(0, y);

    for (double x = 0; x <= size.width; x += 5) {
      final waveY =
          y + math.sin((x / waveLength * 2 * math.pi) + phase) * amplitude;
      path.lineTo(x, waveY);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}
