import 'package:flutter/material.dart';
import 'package:runout/core/theme/app_theme.dart';
import 'package:runout/features/home/home_page.dart';

class RunoutApp extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // App runs at a fixed 1.5× text scale,
      // system font-scale is intentionally ignored.
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: const TextScaler.linear(1.5),
        ),
        child: child!,
      ),
      title: 'Runout',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      home: const HomePage(),
    );
  }
}
