import 'package:flutter/material.dart';
import 'package:runout/core/theme/app_theme.dart';
import 'package:runout/features/home/home_page.dart';

class RunoutApp extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Runout',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      home: const HomePage(),
    );
  }
}
