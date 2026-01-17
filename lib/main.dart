import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
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
  //await MobileAds.instance.initialize();
  // init notifikacija + timezone (ti to već radiš u NotificationService.init)
  await NotificationService.init();

  final prefs = await SharedPreferences.getInstance();
  final seenOnboarding = prefs.getBool('onboarding_done') ?? false;
  final notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  
  runApp(MyApp(
    seenOnboarding: seenOnboarding,
    notificationsEnabled: notificationsEnabled,
  ));
}
class ConsentGate extends StatefulWidget {
  final Widget child;
  const ConsentGate({super.key, required this.child});

  @override
  State<ConsentGate> createState() => _ConsentGateState();
}

class _ConsentGateState extends State<ConsentGate> {
  bool _ready = false;
  bool _adsInitialized = false;

  @override
  void initState() {
    super.initState();
    _gatherConsentThenInitAds();
  }

  Future<void> _gatherConsentThenInitAds() async {
    // 1) UMP: traži update consent info na SVAKOM startu
    final params = ConsentRequestParameters();

    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      () async {
        // 2) UMP: učitaj i prikaži formu ako je potrebno
        ConsentForm.loadAndShowConsentFormIfRequired((formError) async {
          // Ako je error, nije smak sveta. UMP može imati prethodni consent.
          await _maybeInitAds();
          if (mounted) setState(() => _ready = true);
        });
      },
      (FormError error) async {
        // Consent update fail. I dalje probaj sa prethodnim statusom.
        await _maybeInitAds();
        if (mounted) setState(() => _ready = true);
      },
    );
  }

  Future<void> _maybeInitAds() async {
    // Pre requestovanja reklama proveri da li smeš da tražiš ads
    final canRequest = await ConsentInformation.instance.canRequestAds();

    if (canRequest && !_adsInitialized) {
      _adsInitialized = true;
      await MobileAds.instance.initialize();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_ready) return widget.child;

    // “Splash” dok UMP odradi svoje
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
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

            home: ConsentGate(
  child: seenOnboarding ? HomeScreen() : OnboardingScreen(),
),
          );
          
        },
        
      ),
      
    );
    
  }
}
