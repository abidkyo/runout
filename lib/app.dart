import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:runout/core/constants/app_constants.dart';
import 'package:runout/core/theme/app_theme.dart';
import 'package:runout/data/repositories/match_repository.dart';
import 'package:runout/data/repositories/player_repository.dart';
import 'package:runout/data/repositories/settings_repository.dart';
import 'package:runout/features/home/home_page.dart';
import 'package:runout/features/match/match_list_notifier.dart';
import 'package:runout/features/settings/settings_notifier.dart';

class RunoutApp extends StatelessWidget {
  const new({
    required this.settingsRepository,
    required this.playerRepository,
    required this.matchRepository,
    super.key,
  });

  final SettingsRepository settingsRepository;
  final PlayerRepository playerRepository;
  final MatchRepository matchRepository;

  @override
  Widget build(BuildContext context) {
    return AppProviders(
      playerRepository: playerRepository,
      matchRepository: matchRepository,
      child: ChangeNotifierProvider(
        create: (_) => SettingsNotifier(settingsRepository),
        child: const _RunoutAppView(),
      ),
    );
  }
}

class _RunoutAppView extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsNotifier>();

    return MaterialApp(
      scaffoldMessengerKey: AppConstants.scaffoldMessengerKey,
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(settings.appColor),
      darkTheme: AppTheme.dark(settings.appColor),
      themeMode: settings.themeMode,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(settings.textScale),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const HomePage(),
    );
  }
}

/// Provides the repositories shared by the whole app.
class AppProviders extends StatelessWidget {
  const new({
    required this.playerRepository,
    required this.matchRepository,
    required this.child,
    super.key,
  });

  final PlayerRepository playerRepository;
  final MatchRepository matchRepository;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<PlayerRepository>.value(value: playerRepository),
        Provider<MatchRepository>.value(value: matchRepository),
        ChangeNotifierProvider<MatchListNotifier>(
          create: (ctx) => MatchListNotifier(ctx.read<MatchRepository>()),
        ),
      ],
      child: child,
    );
  }
}
