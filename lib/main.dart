import 'package:material_ui/material_ui.dart';
import 'package:runout/app.dart';
import 'package:runout/core/constants/persistence_defaults.dart';
import 'package:runout/core/settings/app_settings.dart';
import 'package:runout/data/local/app_database.dart';
import 'package:runout/data/repositories/match_repository.dart';
import 'package:runout/data/repositories/player_repository.dart';
import 'package:runout/data/repositories/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settingsRepository = SettingsRepository(SharedPreferencesAsync());
  var initialSettings = AppSettings.defaults;

  try {
    initialSettings = await settingsRepository.load();
  } on Object catch (error) {
    debugPrint('Failed to load settings: $error');
  }

  final database = AppDatabase();
  final playerRepository = PlayerRepository(database);
  final matchRepository = MatchRepository(database);
  var isStorageUnavailable = false;

  try {
    await Future.wait([
      playerRepository.load(),
      matchRepository.load(),
    ]).timeout(PersistenceDefaults.loadTimeout);
  } on Object catch (error) {
    debugPrint('Failed to load local storage: $error');
    isStorageUnavailable = true;
  }

  runApp(
    RunoutApp(
      settingsRepository: settingsRepository,
      initialSettings: initialSettings,
      playerRepository: playerRepository,
      matchRepository: matchRepository,
      isStorageUnavailable: isStorageUnavailable,
    ),
  );
}
