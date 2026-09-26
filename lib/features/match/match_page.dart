import 'package:flutter/material.dart';
import 'package:runout/domain/models/match.dart';

/// Placeholder match page. Will show scoring UI later.
class MatchPage extends StatelessWidget {
  const new({required this.match, super.key});

  final Match match;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Match')),
      body: Center(
        child: Text('Match ${match.id}'),
      ),
    );
  }
}
