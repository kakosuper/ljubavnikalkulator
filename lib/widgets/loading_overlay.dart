import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:lottie/lottie.dart';
import '../helpers/translate_helper.dart';

class LoadingOverlay extends StatefulWidget {
  final VoidCallback onFinished;
  const LoadingOverlay({super.key, required this.onFinished});

  @override
  State<LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<LoadingOverlay> {
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _animateProgress();
  }

  void _animateProgress() {
    // Simuliramo proces kalkulacije od 3 sekunde
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 30));
      if (!mounted) return false;
      setState(() {
        _progress += 0.01;
      });
      if (_progress >= 1.0) {
        // Kada stigne do 100%, sačekamo malo i gasimo overlay
        Future.delayed(const Duration(milliseconds: 500), widget.onFinished);
        return false;
      }
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeumorphicTheme.baseColor(context).withOpacity(0.95),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ovde stavi Lottie Kupidona (ako ga nemaš, koristi privremeno srce)
            Lottie.asset(
              'assets/love.json', // Kasnije zameni sa assets/cupid.json
              height: 200,
            ),
            const SizedBox(height: 30),
            Text(
              "${t(context, "Analiza u toku")}...",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text("${(_progress * 100).toInt()}%"),
            const SizedBox(height: 20),
            // Neumorphic Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: NeumorphicProgress(
                percent: _progress,
                height: 15,
                style: const ProgressStyle(
                  accent: Colors.pink,
                  variant: Colors.pinkAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}