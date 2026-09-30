import 'package:flutter/material.dart';
import 'package:flutter_auto_size_text/flutter_auto_size_text.dart';

/// A large, tappable score display that fills its available space.
class ScoreButton extends StatelessWidget {
  const new({
    required this.score,
    required this.onTap,
    super.key,
  });

  /// The score to display.
  final int score;

  /// Called when the score area is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      customBorder: const StadiumBorder(),
      onTap: onTap,
      child: Center(
        child: AutoSizeText(
          '$score',
          style: theme.textTheme.titleMedium?.copyWith(fontSize: 12 * 20),
          maxLines: 1,
          minFontSize: 12 * 5,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
