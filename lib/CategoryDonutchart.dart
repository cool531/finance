import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'AppColors.dart';
import 'Model.dart';

/// A hand-drawn donut chart — no chart package needed. Segment sizes are
/// proportional to the values, and the ring sweeps in when the data changes.
class DonutChart extends StatelessWidget {
  final Map<ExpenseCategory, double> data;
  final double size;
  final double strokeWidth;
  final Widget? center;

  const DonutChart({
    super.key,
    required this.data,
    this.size = 160,
    this.strokeWidth = 24,
    this.center,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 850),
      curve: Curves.easeOutCubic,
      builder: (context, progress, _) => SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size(size, size),
              painter: _DonutChartPainter(
                data: data,
                strokeWidth: strokeWidth,
                progress: progress,
                trackColor: context.cs.surfaceContainerHighest,
              ),
            ),
            if (center != null) center!,
          ],
        ),
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final Map<ExpenseCategory, double> data;
  final double strokeWidth;
  final double progress;
  final Color trackColor;

  _DonutChartPainter({
    required this.data,
    required this.strokeWidth,
    required this.progress,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    final total = data.values.fold(0.0, (sum, v) => sum + v);

    // Track ring — also the empty state.
    canvas.drawArc(
      rect,
      0,
      2 * math.pi,
      false,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    if (total <= 0) return;

    const gap = 0.05; // visual gap between segments, in radians
    double startAngle = -math.pi / 2; // 12 o'clock

    for (final entry in data.entries) {
      if (entry.value <= 0) continue;
      final fraction = entry.value / total;
      final sweep = math.max(0.0, fraction * 2 * math.pi - gap) * progress;
      if (sweep <= 0) continue;

      canvas.drawArc(
        rect,
        startAngle,
        sweep,
        false,
        Paint()
          ..shader = SweepGradient(
            colors: [
              entry.key.color,
              Color.lerp(entry.key.color, AppColors.ink, 0.22)!,
            ],
            startAngle: startAngle,
            endAngle: startAngle + sweep,
            transform: GradientRotation(startAngle),
          ).createShader(rect)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );

      startAngle += fraction * 2 * math.pi;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter old) {
    return old.progress != progress ||
        old.strokeWidth != strokeWidth ||
        old.trackColor != trackColor ||
        !mapEquals(old.data, data);
  }
}
