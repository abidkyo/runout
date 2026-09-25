import 'package:flutter/material.dart';
import 'package:runout/domain/enums/match_mode.dart';
import 'package:runout/features/match_setup/player_slot.dart';

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
        children: [
          for (var i = 0; i < mode.sideCount; i++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _buildSideColumn(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSideColumn() {
    return Column(
      children: [
        for (var i = 0; i < mode.playersPerSide; i++)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: PlayerSlot(
                player: null,
                // Country is hidden in doubles to save space for two names.
                showCountry: mode != MatchMode.doubles,
                onTap: () {},
              ),
            ),
          ),
      ],
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
