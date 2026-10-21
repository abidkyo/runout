import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:runout/core/theme/app_text_theme.dart';
import 'package:runout/data/repositories/player_repository.dart';
import 'package:runout/domain/enums/match_mode.dart';
import 'package:runout/domain/models/player.dart';
import 'package:runout/features/match/match_page.dart';
import 'package:runout/features/match_setup/match_setup_notifier.dart';
import 'package:runout/features/match_setup/widgets/match_config_panel.dart';
import 'package:runout/features/match_setup/widgets/player_panel.dart';
import 'package:runout/features/match_setup/widgets/player_picker_dialog.dart';
import 'package:runout/features/match_setup/widgets/setup_actions.dart';

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
    final notifier = context.read<MatchSetupNotifier>();
    final error = notifier.validatePlayers();

    if (error != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(error), showCloseIcon: true),
        );
      return;
    }

    final match = notifier.buildMatch();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MatchPage(match: match),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${mode.displayName} Match'),
        titleTextStyle: Theme.of(context).textTheme.titleLargeSolid,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    PlayerPanel(
                      mode: mode,
                      onSlotTap: (side, slot) =>
                          _pickPlayer(context, side, slot),
                    ),
                    const SizedBox(height: 8),
                    const MatchConfigPanel(),
                  ],
                ),
              ),
            ),
            SetupActions(
              onStart: () => _start(context),
              onCancel: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
