import 'package:material_ui/material_ui.dart';
import 'package:runout/core/theme/theme_extension.dart';

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
    final size = MediaQuery.sizeOf(context);
    final fontSize = (size.shortestSide / 35).clamp(16.0, 24.0);

    final style = context.textTheme.bodyLarge?.copyWith(
      fontSize: fontSize,
      color: context.colors.onSurfaceVariant,
    );

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: fontSize,
      children: [
        Text('INN: $innings', style: style),
        Text('HIGH: $highRun', style: style),
        Text('AVG: $_average', style: style),
      ],
    );
  }
}
