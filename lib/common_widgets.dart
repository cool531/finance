import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'AppColors.dart';
import 'AppTheme.dart';
import 'Model.dart';
import 'formatters.dart';

/// Soft, barely-there elevation. Flat cards look dated and heavy shadows look
/// cheap — this sits in between and stays subtle in dark mode.
List<BoxShadow> softShadow(BuildContext context, {double strength = 1}) {
  final dark = context.isDark;
  return [
    BoxShadow(
      color: Colors.black.withValues(alpha: (dark ? 0.35 : 0.055) * strength),
      blurRadius: 24 * strength,
      offset: Offset(0, 8 * strength),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: (dark ? 0.18 : 0.025) * strength),
      blurRadius: 3,
      offset: const Offset(0, 1),
    ),
  ];
}

/// The standard rounded container every screen is built out of.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final double radius;
  final bool bordered;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
    this.color,
    this.radius = AppTheme.radius,
    this.bordered = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final border = BorderRadius.circular(radius);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? cs.surface,
        borderRadius: border,
        border: bordered ? Border.all(color: cs.outlineVariant) : null,
        boxShadow: softShadow(context),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: border,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: border,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// A section title with an optional trailing action.
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: context.tt.titleMedium),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!, style: context.tt.bodySmall),
              ],
            ],
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Row(
              children: [
                Text(actionLabel!, style: const TextStyle(fontSize: 13)),
                const Icon(Icons.chevron_right_rounded, size: 18),
              ],
            ),
          ),
      ],
    );
  }
}

/// A number that counts up when it changes — makes the dashboard feel alive.
class AnimatedAmount extends StatelessWidget {
  final double value;
  final TextStyle? style;
  final bool compact;
  final bool hidden;

  const AnimatedAmount({
    super.key,
    required this.value,
    this.style,
    this.compact = false,
    this.hidden = false,
  });

  @override
  Widget build(BuildContext context) {
    if (hidden) {
      return Text('฿ • • • • •', style: style, maxLines: 1);
    }
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => Text(
        compact ? formatCompactBaht(v) : formatBaht(v),
        style: style,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// Small labelled figure; three of them sit in a row under the balance card.
class StatCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color? amountColor;
  final IconData? icon;
  final bool hidden;

  const StatCard({
    super.key,
    required this.label,
    required this.amount,
    this.amountColor,
    this.icon,
    this.hidden = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final tint = amountColor ?? cs.onSurface;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: softShadow(context, strength: 0.7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: tint.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 12, color: tint),
                ),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  label,
                  style: context.tt.bodySmall?.copyWith(fontSize: 11.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: AnimatedAmount(
              value: amount,
              hidden: hidden,
              style: TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
                color: tint,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Rounded progress bar with an animated fill and an optional gradient.
class AppProgressBar extends StatelessWidget {
  final double value;
  final Color? fillColor;
  final List<Color>? gradient;
  final double height;

  const AppProgressBar({
    super.key,
    required this.value,
    this.fillColor,
    this.gradient,
    this.height = 10,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final clamped = value.clamp(0.0, 1.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: Container(
        height: height,
        color: cs.surfaceContainerHighest,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: clamped),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
          builder: (context, v, _) => FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: v <= 0 ? 0.0001 : v,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(height),
                gradient:
                    gradient != null ? LinearGradient(colors: gradient!) : null,
                color: gradient == null ? (fillColor ?? cs.primary) : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Circular gauge used for the financial score.
class ScoreRing extends StatelessWidget {
  final double value; // 0..1
  final double size;
  final double stroke;
  final List<Color> gradient;
  final Widget? center;

  const ScoreRing({
    super.key,
    required this.value,
    this.size = 132,
    this.stroke = 12,
    this.gradient = AppColors.heroGradient,
    this.center,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size(size, size),
              painter: _RingPainter(
                value: v,
                stroke: stroke,
                gradient: gradient,
                track: context.cs.surfaceContainerHighest,
              ),
            ),
            if (center != null) center!,
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double value;
  final double stroke;
  final List<Color> gradient;
  final Color track;

  _RingPainter({
    required this.value,
    required this.stroke,
    required this.gradient,
    required this.track,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      size.width - stroke,
      size.height - stroke,
    );

    canvas.drawArc(
      rect,
      0,
      2 * math.pi,
      false,
      Paint()
        ..color = track
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );

    if (value <= 0) return;

    canvas.drawArc(
      rect,
      -math.pi / 2,
      value * 2 * math.pi,
      false,
      Paint()
        ..shader = SweepGradient(
          colors: gradient,
          startAngle: 0,
          endAngle: 2 * math.pi,
          transform: const GradientRotation(-math.pi / 2),
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.value != value || old.track != track || old.stroke != stroke;
}

/// The circular, tinted category icon used in every expense row.
class CategoryIconBubble extends StatelessWidget {
  final ExpenseCategory category;
  final double size;

  const CategoryIconBubble({super.key, required this.category, this.size = 44});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: category.color.withValues(alpha: context.isDark ? 0.22 : 0.13),
        borderRadius: BorderRadius.circular(size * 0.36),
      ),
      child: Icon(category.icon, color: category.color, size: size * 0.5),
    );
  }
}

/// A colored dot, a label, and a trailing value — the donut chart legend.
class LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final String trailing;

  const LegendRow({
    super.key,
    required this.color,
    required this.label,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.5),
      child: Row(
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            trailing,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: context.cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Small rounded tag, e.g. the necessity marker on an expense row.
class TagChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final bool filled;

  const TagChip({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color:
            filled ? color : color.withValues(alpha: context.isDark ? 0.2 : 0.11),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: filled ? Colors.white : color),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: filled ? Colors.white : color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Month stepper: previous / current month label / next.
class MonthSwitcher extends StatelessWidget {
  final DateTime month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final bool compact;

  const MonthSwitcher({
    super.key,
    required this.month,
    required this.onPrevious,
    required this.onNext,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(40),
        boxShadow: softShadow(context, strength: 0.6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _RoundIconButton(icon: Icons.chevron_left_rounded, onTap: onPrevious),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 12),
            child: Text(
              compact
                  ? formatMonthYearShortThai(month)
                  : formatMonthYearThai(month),
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
            ),
          ),
          _RoundIconButton(icon: Icons.chevron_right_rounded, onTap: onNext),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 20, color: context.cs.onSurfaceVariant),
      ),
    );
  }
}

/// A circular icon button for the header row (menu, bell, theme toggle).
class HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;
  final bool showBadge;

  const HeaderIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.showBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final button = InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: cs.surface,
          shape: BoxShape.circle,
          boxShadow: softShadow(context, strength: 0.6),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, size: 21, color: cs.onSurface),
            if (showBadge)
              Positioned(
                top: 9,
                right: 9,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: AppColors.danger,
                    shape: BoxShape.circle,
                    border: Border.all(color: cs.surface, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}

/// Friendly placeholder for empty lists and charts.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 12),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: cs.primary, size: 30),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(message, style: context.tt.bodySmall, textAlign: TextAlign.center),
          if (actionLabel != null) ...[
            const SizedBox(height: 16),
            FilledButton.tonal(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
