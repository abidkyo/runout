import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:runout/core/constants/layout_breakpoints.dart';
import 'package:runout/core/constants/match_limits.dart';
import 'package:runout/core/theme/theme_extension.dart';
import 'package:runout/data/repositories/player_repository.dart';
import 'package:runout/domain/enums/game_type.dart';
import 'package:runout/domain/models/player.dart';
import 'package:runout/features/match/match_page.dart';
import 'package:runout/features/match_setup/match_setup_notifier.dart';
import 'package:runout/features/match_setup/widgets/break_format_selector.dart';
import 'package:runout/features/match_setup/widgets/game_type_selector.dart';
import 'package:runout/features/match_setup/widgets/mode_selector.dart';
import 'package:runout/features/match_setup/widgets/number_stepper.dart';
import 'package:runout/features/match_setup/widgets/player_panel.dart';
import 'package:runout/features/match_setup/widgets/player_picker_dialog.dart';
import 'package:runout/features/match_setup/widgets/setup_actions.dart';
import 'package:runout/shared/widgets/app_snack_bar.dart';

/// Setup page. Lets the user pick players and match settings.
class MatchSetupPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MatchSetupNotifier(),
      child: const _MatchSetupView(),
    );
  }
}

class _MatchSetupView extends StatelessWidget {
  const new();

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
      showAppSnackBar(context, error);
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
    final size = MediaQuery.sizeOf(context);
    final padding = size.width < LayoutBreakpoints.compact ? 16.0 : 24.0;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Center(
            child: ConstrainedBox(
              key: const ValueKey('setup-content'),
              constraints: const BoxConstraints(
                maxWidth: LayoutBreakpoints.contentMax,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 12,
                children: [
                  const _PageHeader(),
                  _SetupPanel(
                    onSlotTap: (side, slot) => _pickPlayer(context, side, slot),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SetupActions(
        onStart: () => _start(context),
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        Text(
          'New Match',
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          'Set up your match details below.',
          style: context.textTheme.bodyLarge?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _SetupPanel extends StatelessWidget {
  const new({required this.onSlotTap});

  final void Function(int sideIndex, int slotIndex) onSlotTap;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padding = size.width < LayoutBreakpoints.compact ? 16.0 : 24.0;

    final notifier = context.watch<MatchSetupNotifier>();
    final isStraightPool = notifier.gameType == GameType.straightPool;

    return Card(
      color: context.colors.surfaceContainerLow,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 24,
          children: [
            const _Section(
              icon: Icons.groups_rounded,
              title: 'Match Mode',
              child: ModeSelector(),
            ),
            _Section(
              icon: Icons.person_rounded,
              title: 'Players',
              child: PlayerPanel(onSlotTap: onSlotTap),
            ),
            const _Section(
              icon: Icons.sports_baseball_rounded,
              title: 'Game Type',
              child: GameTypeSelector(),
            ),
            if (!isStraightPool)
              const _Section(
                icon: Icons.sync_alt_rounded,
                title: 'Break Format',
                child: BreakFormatSelector(),
              ),
            _Section(
              icon: Icons.flag_rounded,
              title: 'Race to',
              child: NumberStepper(
                value: notifier.raceTo,
                min: MatchLimits.minRaceTo,
                max: MatchLimits.maxRaceTo,
                onChanged: (value) => notifier.raceTo = value,
              ),
            ),
            if (isStraightPool)
              _Section(
                icon: Icons.timer_rounded,
                title: 'Innings',
                child: NumberStepper(
                  value: notifier.innings,
                  min: MatchLimits.minInnings,
                  max: MatchLimits.maxInnings,
                  onChanged: (value) => notifier.innings = value,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const new({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        Row(
          spacing: 8,
          children: [
            Icon(icon, size: 20, color: context.colors.onSurfaceVariant),
            Expanded(
              child: Text(title, style: context.textTheme.titleMedium),
            ),
          ],
        ),
        child,
      ],
    );
  }
}
