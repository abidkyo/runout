import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:runout/core/settings/app_settings.dart';
import 'package:runout/core/theme/app_theme.dart';
import 'package:runout/data/repositories/match_repository.dart';
import 'package:runout/data/repositories/player_repository.dart';
import 'package:runout/data/repositories/settings_repository.dart';
import 'package:runout/features/home/home_page.dart';
import 'package:runout/features/settings/settings_notifier.dart';

class RunoutApp extends StatelessWidget {
  const new({
    required this.settingsRepository,
    required this.initialSettings,
    super.key,
  });

  final SettingsRepository settingsRepository;
  final AppSettings initialSettings;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsNotifier(
        settingsRepository,
        initialSettings: initialSettings,
      ),
      child: const _RunoutAppView(),
    );
  }
}

class _RunoutAppView extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsNotifier>();

    return AppProviders(
      child: MaterialApp(
        title: 'Runout',
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
      ),
    );
  }
}

/// Provides the repositories shared by the whole app.
class AppProviders extends StatelessWidget {
  const new({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<PlayerRepository>(create: (_) => PlayerRepository()),
        Provider<MatchRepository>(create: (_) => MatchRepository()),
      ],
      child: child,
    );
  }
}
