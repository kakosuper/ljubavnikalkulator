import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:lottie/lottie.dart';

class LoadingOverlay extends StatefulWidget {
  final VoidCallback? onFinished;
  final String message;

  const LoadingOverlay({
    super.key,
    required this.message,
    this.onFinished,
  });

  // --- STATIC OVERLAY API (da bi radilo LoadingOverlay.show/hide) ---
  static OverlayEntry? _entry;

  static void show(BuildContext context, String message) {
    if (_entry != null) return; // već prikazano

    _entry = OverlayEntry(
      builder: (_) => Material(
        color: Colors.black54,
        child: SafeArea(
          child: Center(
            child: LoadingOverlay(message: message),
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

    return Neumorphic(
      style: NeumorphicStyle(
        depth: 10,
        intensity: 0.8,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
      ),
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/love.json',
              height: 200,
            ),
            const SizedBox(height: 30),
            Text(
              widget.message,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text("${(percent * 100).toInt()}%"),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
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
