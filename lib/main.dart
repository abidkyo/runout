import 'package:material_ui/material_ui.dart';
import 'package:runout/app.dart';
import 'package:runout/core/settings/app_settings.dart';
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

  runApp(
    RunoutApp(
      settingsRepository: settingsRepository,
      initialSettings: initialSettings,
    ),
  );
}
