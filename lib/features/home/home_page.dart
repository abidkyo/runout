import 'package:material_ui/material_ui.dart';
import 'package:runout/core/theme/app_text_theme.dart';
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
        titleTextStyle: Theme.of(context).textTheme.titleLargeSolid,
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
                for (final mode in MatchMode.values)
                  ModeCard(
                    icon: mode.icon,
                    label: mode.displayName,
                    onTap: (mode == .tournament)
                        ? () {}
                        : () => _openSetup(context, mode),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
