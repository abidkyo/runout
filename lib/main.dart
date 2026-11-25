import 'package:material_ui/material_ui.dart';
import 'package:runout/app.dart';
import 'package:runout/core/constants/persistence_defaults.dart';
import 'package:runout/data/local/app_database.dart';
import 'package:runout/data/repositories/match_repository.dart';
import 'package:runout/data/repositories/player_repository.dart';
import 'package:runout/data/repositories/settings_repository.dart';
import 'package:runout/shared/widgets/app_snack_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settingsRepository = SettingsRepository(SharedPreferencesAsync());

  final database = AppDatabase();
  final playerRepository = PlayerRepository(database);
  final matchRepository = MatchRepository(database);
  var isStorageUnavailable = false;

  try {
    await Future.wait([
      settingsRepository.load(),
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
      playerRepository: playerRepository,
      matchRepository: matchRepository,
    ),
  );

  if (isStorageUnavailable) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showAppSnackBar('Storage unavailable. Changes will not be saved.');
    });
  }
}
