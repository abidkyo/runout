import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:runout/data/repositories/player_repository.dart';
import 'package:runout/domain/enums/match_mode.dart';
import 'package:runout/domain/models/player.dart';
import 'package:runout/features/match/match_page.dart';
import 'package:runout/features/match_setup/match_setup_notifier.dart';
import 'package:runout/features/match_setup/player_picker_dialog.dart';
import 'package:runout/features/match_setup/player_slot.dart';
import 'package:runout/features/match_setup/settings_bar.dart';

/// Setup page. Lets the user pick players and match settings.
class MatchSetupPage extends StatelessWidget {
  const new({required this.mode, super.key});

  final MatchMode mode;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<PlayerRepository>(create: (_) => PlayerRepository()),
        ChangeNotifierProvider(
          create: (_) => MatchSetupNotifier(mode: mode),
        ),
      ],
      child: _MatchSetupView(mode: mode),
    );
  }
}

class _MatchSetupView extends StatelessWidget {
  const new({required this.mode});

  final MatchMode mode;

  Future<void> _pickPlayer(
    BuildContext context,
    int sideIndex,
    int slotIndex,
  ) async {
    final repo = context.read<PlayerRepository>();
    final picked = await showDialog<Player>(
      context: context,
      builder: (_) => PlayerPickerDialog(players: repo.getAll()),
    );
    if (picked == null) return;
    if (!context.mounted) return;
    context.read<MatchSetupNotifier>().setPlayer(
      sideIndex,
      slotIndex,
      picked,
    );
  }

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
            Expanded(
              child: _SideCards(
                mode: mode,
                onSlotTap: (side, slot) => _pickPlayer(context, side, slot),
              ),
            ),
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
  const new({
    required this.mode,
    required this.onSlotTap,
  });

  final MatchMode mode;
  final void Function(int sideIndex, int slotIndex) onSlotTap;

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
                child: _SideColumn(
                  mode: mode,
                  sideIndex: i,
                  onSlotTap: onSlotTap,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SideColumn extends StatelessWidget {
  const new({
    required this.mode,
    required this.sideIndex,
    required this.onSlotTap,
  });

  final MatchMode mode;
  final int sideIndex;
  final void Function(int sideIndex, int slotIndex) onSlotTap;

  @override
  Widget build(BuildContext context) {
    final players = context.watch<MatchSetupNotifier>().players[sideIndex];

    return Column(
      children: [
        for (var i = 0; i < mode.playersPerSide; i++)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: PlayerSlot(
                player: players[i],
                // Country is hidden in doubles to save space for two names.
                showCountry: mode != MatchMode.doubles,
                onTap: () => onSlotTap(sideIndex, i),
              ),
            ),
          ),
      ],
    );
  }
}
