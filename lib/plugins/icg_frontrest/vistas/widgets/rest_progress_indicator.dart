// lib/plugins/icg_frontrest/widgets/rest_progress_indicator.dart
import 'package:flutter/material.dart';
import '../../../../core/temas/tema_personalizado.dart';

class KPIProgressIndicator extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final bool compact;

  const KPIProgressIndicator({
    Key? key,
    required this.label,
    required this.value,
    required this.color,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!compact) ...[
          Text(label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: ColoresTema.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
        ],
        Stack(
          children: [
            Container(
              height: 4,
              width: double.infinity,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            FractionallySizedBox(
              widthFactor: value / 100,
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              compact ? label : '${value.toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (compact)
              Text(
                '${value.toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ],
    );
  }
}