import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:runout/domain/enums/match_mode.dart';
import 'package:runout/features/match/match_page.dart';
import 'package:runout/features/match_setup/match_setup_notifier.dart';
import 'package:runout/features/match_setup/player_slot.dart';
import 'package:runout/features/match_setup/settings_bar.dart';

/// Setup page. Lets the user pick players and match settings.
class MatchSetupPage extends StatelessWidget {
  const new({required this.mode, super.key});

  /// The match mode chosen on the home page.
  final MatchMode mode;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MatchSetupNotifier(),
      child: _MatchSetupView(mode: mode),
    );
  }
}

class _MatchSetupView extends StatelessWidget {
  const new({required this.mode});

  final MatchMode mode;

  void _start(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const MatchPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(mode.name),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _SideCards(mode: mode)),
            SettingsBar(
              onStart: () => _start(context),
              onCancel: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SideCards extends StatelessWidget {
  const new({required this.mode});

  final MatchMode mode;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          for (var i = 0; i < mode.sideCount; i++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _SideColumn(mode: mode),
              ),
            ),
        ],
      ),
    );
  }
}

class _SideColumn extends StatelessWidget {
  const new({required this.mode});

  final MatchMode mode;

  @override
  Widget build(BuildContext context) {
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
}
