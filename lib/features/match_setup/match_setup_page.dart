import 'package:flutter/material.dart';
import 'package:runout/domain/enums/match_mode.dart';

/// Placeholder setup page. Will be replaced with the real setup UI.
class MatchSetupPage extends StatelessWidget {
  const new({required this.mode, super.key});

  final MatchMode mode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(mode.name)),
      body: Center(child: Text('Setup: ${mode.name}')),
    );
  }
}
