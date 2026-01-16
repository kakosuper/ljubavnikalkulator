import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/theme_provider.dart';
import 'providers/language_provider.dart';
import 'providers/notifications_provider.dart';
import 'services/notification_service.dart';

import 'screens/home_screen.dart';
import 'screens/OnboardingScreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // init notifikacija + timezone (ti to već radiš u NotificationService.init)
  await NotificationService.init();

  final prefs = await SharedPreferences.getInstance();
  final seenOnboarding = prefs.getBool('onboarding_done') ?? false;
  final notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;

  runApp(MyApp(
    seenOnboarding: seenOnboarding,
    notificationsEnabled: notificationsEnabled,
  ));
}

class MyApp extends StatelessWidget {
  final bool seenOnboarding;
  final bool notificationsEnabled;

  const MyApp({
    super.key,
    required this.seenOnboarding,
    required this.notificationsEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(
          create: (_) => NotificationsProvider(initialEnabled: notificationsEnabled),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return NeumorphicApp(
            debugShowCheckedModeBanner: false,
            title: 'Ljubav i Zvezde',
            themeMode: themeProvider.themeMode,

            // Light neumorphic theme
            theme: NeumorphicThemeData(
              baseColor: const Color(0xFFF3F3F3),
              lightSource: LightSource.topLeft,
              depth: 10,
            ),

            // Dark neumorphic theme
            darkTheme: NeumorphicThemeData(
              baseColor: const Color(0xFF2E2E2E),
              lightSource: LightSource.topLeft,
              depth: 10,
              intensity: 0.5,
            ),

            home: seenOnboarding ? HomeScreen() : OnboardingScreen(),
          );
        },
      ),
    );
  }
}
