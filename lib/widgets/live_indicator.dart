import 'package:flutter/material.dart';

class LiveIndicator extends StatefulWidget {
  final String? text;
  final double? size;
  final TextStyle? textStyle;

  const LiveIndicator({
    super.key,
    this.text = 'Temps réel',
    this.size,
    this.textStyle,
  });

  @override
  State<LiveIndicator> createState() => _LiveIndicatorState();
}

class _LiveIndicatorState extends State<LiveIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.4,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Pulsing green dot
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Pulsing outer ring
                Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: widget.size ?? 12,
                    height: widget.size ?? 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF10B981).withOpacity(_fadeAnimation.value),
                    ),
                  ),
                ),
                // Solid center dot
                Container(
                  width: (widget.size ?? 12) * 0.6,
                  height: (widget.size ?? 12) * 0.6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF10B981),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(width: 8),
        // Text
        Text(
          widget.text!,
          style: widget.textStyle ??
              const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF10B981),
                letterSpacing: 0.5,
              ),
        ),
      ],
    );
  }
}
