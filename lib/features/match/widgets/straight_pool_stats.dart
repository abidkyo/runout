import 'package:flutter/material.dart';

/// One side's straight-pool stats: innings, high run, average.
///
/// Only rendered when the match is straight pool and playing/finished.
class StraightPoolStats extends StatelessWidget {
  const new({
    required this.score,
    required this.innings,
    required this.highRun,
    super.key,
  });

  final int score;
  final int innings;
  final int highRun;

  String get _average {
    if (innings == 0) return '0.00';
    return (score / innings).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      fontSize: 12 * 1.5,
    );

    return Text(
      'I: $innings   HR: $highRun   Ø: $_average',
      style: style,
      textAlign: TextAlign.center,
    );
  }
}
