import 'package:material_ui/material_ui.dart';
import 'package:runout/core/constants/app_destinations.dart';
import 'package:runout/core/constants/app_strings.dart';
import 'package:runout/core/constants/layout_breakpoints.dart';
import 'package:runout/core/theme/app_color_scheme.dart';
import 'package:runout/core/theme/app_text_theme.dart';
import 'package:runout/core/theme/theme_extension.dart';
import 'package:runout/domain/models/match.dart';
import 'package:runout/features/history/match_history_page.dart';
import 'package:runout/features/home/widgets/home_content.dart';
import 'package:runout/features/home/widgets/home_sidebar.dart';
import 'package:runout/features/match/match_page.dart';
import 'package:runout/features/match_setup/match_setup_page.dart';
import 'package:runout/shared/widgets/empty_state.dart';

/// Entry screen and app shell.
class HomePage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) => const _HomeShell();
}

class _HomeShell extends StatefulWidget {
  const new();

  @override
  State<_HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<_HomeShell> {
  int _selectedIndex = 0;

  void _selectTab(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
  }

  void _openNewMatch(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const MatchSetupPage(),
      ),
    );
  }

  void _openMatch(BuildContext context, Match match) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MatchPage(match: match),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= LayoutBreakpoints.wide;

        return Scaffold(
          appBar: isWide
              ? null
              : AppBar(
                  automaticallyImplyLeading: false,
                  centerTitle: false,
                  toolbarHeight: MediaQuery.textScalerOf(context).scale(64),
                  title: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.title,
                        style: context.textTheme.appTitle.copyWith(
                          color: context.colors.appTitle,
                        ),
                      ),
                      Text(
                        AppStrings.subtitle,
                        style: context.textTheme.appSubtitle.copyWith(
                          color: context.colors.appSubtitle,
                        ),
                      ),
                    ],
                  ),
                ),
          body: SafeArea(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isWide)
                  HomeSidebar(
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: _selectTab,
                  ),
                Expanded(
                  child: switch (AppDestinations.values[_selectedIndex]) {
                    .home => HomeContent(
                      onNewMatch: () => _openNewMatch(context),
                      onOpenMatch: (match) => _openMatch(context, match),
                      onSeeAllMatches: () => _selectTab(
                        AppDestinations.matches.index,
                      ),
                    ),
                    .players => const EmptyState(
                      icon: Icons.people_outline,
                      title: 'Players',
                      message: 'Player management is coming soon.',
                    ),
                    .matches => const MatchHistoryPage(),
                    .settings => const EmptyState(
                      icon: Icons.settings_outlined,
                      title: 'Settings',
                      message: 'Settings are coming soon.',
                    ),
                  },
                ),
              ],
            ),
          ),
          bottomNavigationBar: isWide
              ? null
              : NavigationBar(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _selectTab,
                  destinations: [
                    for (final d in AppDestinations.values)
                      NavigationDestination(
                        icon: Icon(d.icon),
                        selectedIcon: Icon(d.selectedIcon),
                        label: d.label,
                      ),
                  ],
                ),
        );
      },
    );
  }
}
