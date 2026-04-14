import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnimatedSpeedGauge extends StatefulWidget {
  final double speed;
  final double maxSpeed;
  final String unit;
  final double size;

  const AnimatedSpeedGauge({
    super.key,
    required this.speed,
    this.maxSpeed = 50.0,
    this.unit = 'nœuds',
    this.size = 200.0,
  });

  @override
  State<AnimatedSpeedGauge> createState() => _AnimatedSpeedGaugeState();
}

class _AnimatedSpeedGaugeState extends State<AnimatedSpeedGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: widget.speed.clamp(0.0, widget.maxSpeed),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void didUpdateWidget(AnimatedSpeedGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.speed != widget.speed) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.speed.clamp(0.0, widget.maxSpeed),
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ));
      _animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size * 0.6,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Stack(
          children: [
            // Background arc
            CustomPaint(
              size: Size(widget.size - 40, (widget.size - 40) * 0.6),
              painter: _BackgroundGaugePainter(),
            ),
            // Animated speed arc
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(widget.size - 40, (widget.size - 40) * 0.6),
                  painter: _SpeedGaugePainter(
                    speed: _animation.value,
                    maxSpeed: widget.maxSpeed,
                  ),
                );
              },
            ),
            // Speed text
            Positioned.fill(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Text(
                        _animation.value.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E3A8A),
                          letterSpacing: -1,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.unit,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackgroundGaugePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.8);
    final radius = size.width * 0.4;
    
    final backgroundPaint = Paint()
      ..color = const Color(0xFF1E3A8A)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw background semicircle arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi, // Start from left
      math.pi, // 180 degrees
      false,
      backgroundPaint,
    );

    // Draw tick marks
    final tickPaint = Paint()
      ..color = const Color(0xFF1E3A8A).withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (int i = 0; i <= 10; i++) {
      final angle = math.pi + (math.pi * i / 10);
      final startAngle = angle - 0.05;
      final endAngle = angle + 0.05;
      
      final innerRadius = radius - 12;
      final outerRadius = radius - 4;
      
      final x1 = center.dx + innerRadius * math.cos(startAngle);
      final y1 = center.dy + innerRadius * math.sin(startAngle);
      final x2 = center.dx + outerRadius * math.cos(startAngle);
      final y2 = center.dy + outerRadius * math.sin(startAngle);
      
      canvas.drawLine(
        Offset(x1, y1),
        Offset(x2, y2),
        tickPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SpeedGaugePainter extends CustomPainter {
  final double speed;
  final double maxSpeed;

  _SpeedGaugePainter({
    required this.speed,
    required this.maxSpeed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.8);
    final radius = size.width * 0.4;
    
    final speedPaint = Paint()
      ..color = const Color(0xFF0EA5E9)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Calculate the angle for the current speed
    final speedRatio = (speed / maxSpeed).clamp(0.0, 1.0);
    final sweepAngle = math.pi * speedRatio;

    // Draw speed arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi, // Start from left
      sweepAngle, // Sweep based on speed
      false,
      speedPaint,
    );

    // Draw needle at current speed
    final needlePaint = Paint()
      ..color = const Color(0xFF1E3A8A)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final needleAngle = math.pi + sweepAngle;
    final needleLength = radius - 20;
    final needleX = center.dx + needleLength * math.cos(needleAngle);
    final needleY = center.dy + needleLength * math.sin(needleAngle);

    // Draw needle
    canvas.drawLine(
      center,
      Offset(needleX, needleY),
      needlePaint,
    );

    // Draw center dot
    final centerDotPaint = Paint()
      ..color = const Color(0xFF1E3A8A)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 6, centerDotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! _SpeedGaugePainter || 
           oldDelegate.speed != speed;
  }
}
