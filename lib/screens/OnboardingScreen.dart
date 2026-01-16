import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:ljubavnikalkulator/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/translate_helper.dart';
import '../providers/language_provider.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeumorphicTheme.baseColor(context),
      body: PageView(
        controller: _pageController,
        children: [
          // PRVA STRANA: O aplikaciji
          _buildStep(
            title: "Dobrodošli!",
            description: "Otkrijte tajne zvezda, izračunajte ljubavnu kompatibilnost i saznajte svoj podznak na jednom mestu.",
            child: Icon(Icons.favorite, size: 100, color: Colors.pink),
            buttonText: "Dalje",
            onNext: () => _pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeIn),
          ),
          
          // DRUGA STRANA: Podešavanja
          _buildStep(
            title: "Podešavanja",
            description: "Izaberite pismo i podesite obaveštenja.",
            child: Column(
              children: [
                // Izbor pisma
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Latinica"),
                    Switch(
                      value: Provider.of<LanguageProvider>(context).currentScript == ScriptType.cirilica,
                      onChanged: (val) {
                        Provider.of<LanguageProvider>(context, listen: false).setScript(val ? ScriptType.cirilica : ScriptType.latinica);
                      },
                    ),
                    Text("Ćirilica"),
                  ],
                ),
                const SizedBox(height: 20),
                // Notifikacije
                NeumorphicSwitch(
                  isEnabled: _notificationsEnabled,
                  onChanged: (val) => setState(() => _notificationsEnabled = val),
                ),
                const SizedBox(height: 10),
                Text(_notificationsEnabled ? "Obaveštenja uključena" : "Obaveštenja isključena"),
              ],
            ),
            buttonText: "Sačuvaj i počni",
            onNext: _finishOnboarding,
          ),
        ],
      ),
    );
  }

void _finishOnboarding() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('onboarding_done', true);
  
  // Ako su notifikacije uključene u UI-u (tvoj Switch)
  if (_notificationsEnabled) {
    await NotificationService.scheduleTripleDayNotification(context);
  }

  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
}

  Widget _buildStep({required String title, required String description, required Widget child, required String buttonText, required VoidCallback onNext}) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          child,
          const SizedBox(height: 40),
          Text(t(context, title), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Text(t(context, description), textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 60),
          NeumorphicButton(
            onPressed: onNext,
            child: Text(t(context, buttonText)),
          )
        ],
      ),
    );
  }
}