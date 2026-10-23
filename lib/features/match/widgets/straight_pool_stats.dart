import 'package:material_ui/material_ui.dart';

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
    final size = MediaQuery.sizeOf(context);

    final fontSize = (size.shortestSide / 35).clamp(12.0, 24.0);

    final style = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      fontSize: fontSize,
    );

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: fontSize * 1.5,
      children: [
        Text('I: $innings', style: style),
        Text('HR: $highRun', style: style),
        Text('Ø: $_average', style: style), // Ø U+00D8
      ],
    );
  }
}
