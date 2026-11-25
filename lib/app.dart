import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:runout/core/settings/app_settings.dart';
import 'package:runout/core/theme/app_theme.dart';
import 'package:runout/data/repositories/match_repository.dart';
import 'package:runout/data/repositories/player_repository.dart';
import 'package:runout/data/repositories/settings_repository.dart';
import 'package:runout/features/home/home_page.dart';
import 'package:runout/features/settings/settings_notifier.dart';
import 'package:runout/shared/widgets/app_snack_bar.dart';

class RunoutApp extends StatelessWidget {
  const new({
    required this.settingsRepository,
    required this.initialSettings,
    required this.playerRepository,
    required this.matchRepository,
    this.isStorageUnavailable = false,
    super.key,
  });

  final SettingsRepository settingsRepository;
  final AppSettings initialSettings;
  final PlayerRepository playerRepository;
  final MatchRepository matchRepository;
  final bool isStorageUnavailable;

  @override
  Widget build(BuildContext context) {
    return AppProviders(
      playerRepository: playerRepository,
      matchRepository: matchRepository,
      child: ChangeNotifierProvider(
        create: (_) => SettingsNotifier(
          settingsRepository,
          initialSettings: initialSettings,
        ),
        child: _RunoutAppView(
          isStorageUnavailable: isStorageUnavailable,
        ),
      ),
    );
  }
}

class _RunoutAppView extends StatelessWidget {
  const new({
    required this.isStorageUnavailable,
  });

  final bool isStorageUnavailable;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsNotifier>();

    return MaterialApp(
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
          child: _StorageWarning(
            isStorageUnavailable: isStorageUnavailable,
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
      home: const HomePage(),
    );
  }
}

/// Warns once when the local storage could not be loaded.
class _StorageWarning extends StatefulWidget {
  const new({
    required this.isStorageUnavailable,
    required this.child,
  });

  final bool isStorageUnavailable;
  final Widget child;

  @override
  State<_StorageWarning> createState() => _StorageWarningState();
}

class _StorageWarningState extends State<_StorageWarning> {
  @override
  void initState() {
    super.initState();
    if (!widget.isStorageUnavailable) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        'Storage unavailable. Changes will not be saved.',
      );
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
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
      ],
      child: child,
    );
  }
}
