import 'package:flutter/material.dart';

/// Placeholder match page. Will show scoring UI later.
class MatchPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Match')),
      body: const Center(child: Text('Match page')),
    );
  }
}
