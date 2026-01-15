import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:provider/provider.dart';

// Importuj oba provajdera
import 'package:ljubavnikalkulator/providers/theme_provider.dart';
import 'package:ljubavnikalkulator/providers/language_provider.dart'; 

import 'screens/home_screen.dart'; 

import 'package:flutter/widgets.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  tzdata.initializeTimeZones();
  runApp(
    // MultiProvider omogućava registrovanje više provajdera odjednom
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return NeumorphicApp(
      debugShowCheckedModeBanner: false,
      title: 'Love Matcher',
      themeMode: themeProvider.themeMode,
      theme: NeumorphicThemeData(
        baseColor: const Color(0xFFF3F3F3),
        lightSource: LightSource.topLeft,
        depth: 10,
      ),
      darkTheme: NeumorphicThemeData(
        baseColor: const Color(0xFF2E2E2E),
        lightSource: LightSource.topLeft,
        depth: 10,
        intensity: 0.5,
      ),
      home: HomeScreen(),
    );
  }
}