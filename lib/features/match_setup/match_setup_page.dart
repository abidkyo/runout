import 'package:flutter/material.dart';
import 'package:runout/domain/enums/match_mode.dart';

/// Setup page. Lets the user pick players and match settings.
class MatchSetupPage extends StatelessWidget {
  const new({required this.mode, super.key});

  /// The match mode chosen on the home page.
  final MatchMode mode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(mode.name),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildSideCards()),
            _buildSettingsBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildSideCards() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: List.generate(
          mode.sideCount,
          (i) => Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: _SideCardPlaceholder(index: i),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsBar() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: SizedBox(
        height: 80,
        child: Center(child: Text('Settings bar')),
      ),
    );
  }
}

/// Temporary placeholder for a side card.
class _SideCardPlaceholder extends StatelessWidget {
  const new({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Center(
        child: Text(
          'Side ${index + 1}',
          style: theme.textTheme.titleLarge,
        ),
      ),
    );
  }
}
