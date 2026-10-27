import 'package:flutter/material.dart';

import 'AppColors.dart';
import 'Model.dart';

/// Inline grid of every category — no extra tap into a bottom sheet.
class CategoryGridSelector extends StatelessWidget {
  final ExpenseCategory value;
  final ValueChanged<ExpenseCategory> onChanged;

  const CategoryGridSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.55,
      children: ExpenseCategory.values.map((cat) {
        final selected = cat == value;
        return InkWell(
          onTap: () => onChanged(cat),
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: selected
                  ? cat.color.withValues(alpha: context.isDark ? 0.22 : 0.12)
                  : cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: selected ? cat.color : Colors.transparent,
                width: 1.6,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  cat.icon,
                  size: 21,
                  color: selected ? cat.color : cs.onSurfaceVariant,
                ),
                const SizedBox(height: 5),
                Text(
                  cat.label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: selected ? cs.onSurface : cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Three-way segmented control for how necessary a spend was.
class NecessitySelector extends StatelessWidget {
  final NecessityLevel value;
  final ValueChanged<NecessityLevel> onChanged;

  const NecessitySelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: NecessityLevel.values.map((level) {
          final selected = value == level;
          return Expanded(
            child: InkWell(
              onTap: () => onChanged(level),
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: selected ? level.color : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: level.color.withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  children: [
                    Icon(
                      level.icon,
                      size: 17,
                      color: selected ? Colors.white : cs.onSurfaceVariant,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      level.label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: selected ? Colors.white : cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Bottom-sheet picker for the goal icon, used by the goal editor.
Future<GoalIconType?> showGoalIconPicker(
  BuildContext context, {
  GoalIconType? current,
}) {
  return showModalBottomSheet<GoalIconType>(
    context: context,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('เลือกไอคอนเป้าหมาย', style: context.tt.titleLarge),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.95,
              children: GoalIconType.values.map((type) {
                final selected = type == current;
                return InkWell(
                  onTap: () => Navigator.of(context).pop(type),
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    decoration: BoxDecoration(
                      color: selected
                          ? type.color.withValues(alpha: 0.16)
                          : context.cs.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: selected ? type.color : Colors.transparent,
                        width: 1.6,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(type.icon, color: type.color, size: 24),
                        const SizedBox(height: 6),
                        Text(
                          type.label,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    ),
  );
}
