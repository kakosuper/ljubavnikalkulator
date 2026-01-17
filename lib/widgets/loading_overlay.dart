import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:lottie/lottie.dart';

class LoadingOverlay extends StatefulWidget {
  final VoidCallback? onFinished;
  final String message;


  final String lottieAsset;

  const LoadingOverlay({
    super.key,
    required this.message,
    this.onFinished,
    this.lottieAsset = 'assets/love.json',
  });

  // --- STATIC OVERLAY API (da bi radilo LoadingOverlay.show/hide) ---
  static OverlayEntry? _entry;

  static void show(BuildContext context, String message, {required String lottieAsset}) {
    if (_entry != null) return; // već prikazano

    _entry = OverlayEntry(
      builder: (_) => Material(
        color: Colors.black54,
        child: SafeArea(
          child: Center(
            child: LoadingOverlay(
            message: message,
            // ✅ DODAJ
            lottieAsset: lottieAsset ?? 'assets/love.json',
          ),
            
          ),
        ),
      ),
    );

    final overlay = Overlay.of(context, rootOverlay: true);
  overlay.insert(_entry!);
  }

  static void hide() {
    _entry?.remove();
    _entry = null;
  }
  // ---------------------------------------------------------------

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
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 30));
      if (!mounted) return false;

      setState(() {
        _progress += 0.01;
      });

      if (_progress >= 1.0) {
        Future.delayed(const Duration(milliseconds: 250), () {
          widget.onFinished?.call();
        });
        return false;
      }
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final percent = _progress.clamp(0.0, 1.0);

    // ✅ Responsive sizing (da srce bude "baš veliko", ali da stane svuda)
    final screenW = MediaQuery.of(context).size.width;
    final cardW = (screenW * 0.86).clamp(320.0, 420.0);
    final heartSize = (cardW * 0.72).clamp(240.0, 320.0);

    return Neumorphic(
      style: NeumorphicStyle(
        depth: 10,
        intensity: 0.8,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
      ),
      child: Container(
        width: cardW,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ❤️ veće srce
            SizedBox(
              width: heartSize,
              height: heartSize,
              child: Lottie.asset(widget.lottieAsset, fit: BoxFit.contain)
            ),

            const SizedBox(height: 20),
            Text(
              widget.message,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text("${(percent * 100).toInt()}%"),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: NeumorphicProgress(
                percent: percent,
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
