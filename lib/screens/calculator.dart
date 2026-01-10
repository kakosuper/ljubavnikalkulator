import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import '../engine/AstroEngine.dart';
import '../helpers/translate_helper.dart';
import '../widgets/loading_overlay.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/services.dart';

class CalculatorPage extends StatefulWidget {
  @override
  _CalculatorPageState createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> with TickerProviderStateMixin {
  final TextEditingController _name1Controller = TextEditingController();
  final TextEditingController _name2Controller = TextEditingController();
  
  // Kontroler za glavno srce
  late AnimationController _heartController;
  bool _isExploded = false;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    
    _name1Controller.addListener(_updateSpeed);
    _name2Controller.addListener(_updateSpeed);
  }

  @override
  void dispose() {
    _name1Controller.dispose();
    _name2Controller.dispose();
    _heartController.dispose();
    super.dispose();
  }

  void _updateSpeed() {
    setState(() {
      if (_name1Controller.text.isNotEmpty || _name2Controller.text.isNotEmpty) {
        HapticFeedback.selectionClick();
        _heartController.duration = const Duration(milliseconds: 600);
      } else {
        _heartController.duration = const Duration(seconds: 2);
      }
      if (!_heartController.isAnimating) _heartController.repeat();
    });
  }

  void _calculate() {
    if (_name1Controller.text.trim().isEmpty || _name2Controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t(context, "Molimo unesite oba imena")), backgroundColor: Colors.orange),
      );
      return;
    }

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      pageBuilder: (context, anim1, anim2) {
        return LoadingOverlay(
          onFinished: () {
            Navigator.pop(context);
            _showResult();
          },
        );
      },
    );
  }

  void _showResult() {
    int result = AstroEngine.getFinalScore(
      name1: _name1Controller.text,
      name2: _name2Controller.text,
    );

    // Specijalni slučaj: Eksplozija ako je rezultat 0
    if (result == 0) {
      setState(() => _isExploded = true);
      Future.delayed(Duration(seconds: 3), () => setState(() => _isExploded = false));
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: NeumorphicTheme.baseColor(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // PRIKAZ ANIMACIJE NA OSNOVU REZULTATA
            Container(
              height: 150,
              child: _getResultAnimation(result),
            ),
            
            Neumorphic(
              style: NeumorphicStyle(depth: 5, boxShape: NeumorphicBoxShape.circle()),
              padding: EdgeInsets.all(20),
              child: Text(
                "$result%",
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.pink),
              ),
            ),
            SizedBox(height: 20),
            Text(
              _getResultMessage(result),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t(context, "Zatvori"), style: TextStyle(color: Colors.pink)),
          )
        ],
      ),
    );
  }

  // LOGIKA ZA PRIKAZ LOTTIE ANIMACIJE U DIJALOGU
  Widget _getResultAnimation(int score) {
    if (score >= 80) return Lottie.asset('assets/fireworks.json');
    if (score <= 40) return Lottie.asset('assets/rain.json');
    return Lottie.asset('assets/vaga.json'); // Vaga sa suncem i oblakom
  }

  String _getResultMessage(int score) {
    if (score >= 80) return t(context, "Savršen spoj! Prava ljubav.");
    if (score >= 50) return t(context, "Ima hemije, vredi pokušati!");
    if (score > 0) return t(context, "Bolje da ostanete prijatelji...");
    return t(context, "Potpuna katastrofa!");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeumorphicTheme.baseColor(context),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            const SizedBox(height: 10),
            
            // GLAVNO SRCE SA KONTROLEROM (BEZ SPEED PARAMETRA)
            _isExploded 
              ? Icon(Icons.heart_broken, size: 150, color: Colors.grey) // Ovde može Lottie eksplozija
              : Lottie.asset(
  'assets/love.json',
  height: 200, // Sada će ovo raditi
  width: 200,
  fit: BoxFit.contain, // Ovo tera animaciju da se raširi dok ne udari u ivice
  controller: _heartController,
  onLoaded: (comp) => _heartController.duration = comp.duration,
),
            
            const SizedBox(height: 10),
            _buildInputField(t(context, "Tvoje ime"), _name1Controller),
            SizedBox(height: 20),
            _buildInputField(t(context, "Ime simpatije"), _name2Controller),
            SizedBox(height: 40),
            
            NeumorphicButton(
              onPressed: _calculate,
              style: NeumorphicStyle(
                shape: NeumorphicShape.flat,
                boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
                color: Colors.pink[50],
                depth: 8,
              ),
              padding: EdgeInsets.symmetric(vertical: 18, horizontal: 50),
              child: Text(
                t(context, "Izračunaj procenat"),
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.pink, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildInputField(String hint, TextEditingController controller) {
  // Proveravamo da li je tamna tema aktivna (radi i za sistemsku)
  final isDark = NeumorphicTheme.isUsingDark(context);
  
  return Neumorphic(
    style: NeumorphicStyle(
      depth: -5,
      boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(15)),
      // Osiguravamo da je unutrašnjost polja ispravne boje
      color: NeumorphicTheme.baseColor(context),
    ),
    child: TextField(
      controller: controller,
      // Eksplicitno postavljamo boju na osnovu isDark
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: isDark ? Colors.white54 : Colors.black45,
        ),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.all(18),
      ),
    ),
  );
}
}