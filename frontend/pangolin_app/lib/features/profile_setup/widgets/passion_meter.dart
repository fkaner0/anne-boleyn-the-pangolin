import 'package:flutter/material.dart';

class PassionMeter extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const PassionMeter({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final clamped = value.clamp(0.0, 1.0);
    final endLabelStyle = theme.textTheme.bodySmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Slider(
          value: clamped,
          onChanged: onChanged,
          activeColor: colorScheme.primary,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text("I'd like to give it a go", style: endLabelStyle),
              ),
              Expanded(
                child: Text(
                  "I'd do it all the time if I could",
                  textAlign: TextAlign.end,
                  style: endLabelStyle,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
