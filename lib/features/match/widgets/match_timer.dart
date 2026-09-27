import 'package:flutter/material.dart';

/// Placeholder match timer display. Will tick once match timing is wired.
class MatchTimer extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Center(
        child: Text(
          '00:00',
          style: TextStyle(
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }
}
