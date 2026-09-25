import 'package:flutter/material.dart';
import 'package:runout/domain/enums/match_mode.dart';
import 'package:runout/features/home/mode_card.dart';
import 'package:runout/features/match_setup/match_setup_page.dart';

/// Entry screen. Lets the user pick a match mode.
class HomePage extends StatelessWidget {
  const new({super.key});

  void _openSetup(BuildContext context, MatchMode mode) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MatchSetupPage(mode: mode),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Runout'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                ModeCard(
                  icon: Icons.person,
                  label: 'Singles',
                  onTap: () => _openSetup(context, MatchMode.singles),
                ),
                ModeCard(
                  icon: Icons.people,
                  label: 'Doubles',
                  onTap: () => _openSetup(context, MatchMode.doubles),
                ),
                ModeCard(
                  icon: Icons.groups,
                  label: 'Three Players',
                  onTap: () => _openSetup(context, MatchMode.threePlayer),
                ),
                ModeCard(
                  icon: Icons.emoji_events,
                  label: 'Tournament',
                  onTap: () => _openSetup(context, MatchMode.tournament),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
