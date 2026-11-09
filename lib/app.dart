import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:runout/core/theme/app_theme.dart';
import 'package:runout/data/repositories/match_repository.dart';
import 'package:runout/data/repositories/player_repository.dart';
import 'package:runout/features/home/home_page.dart';

class RunoutApp extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return AppProviders(
      child: MaterialApp(
        title: 'Runout',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.light,
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
