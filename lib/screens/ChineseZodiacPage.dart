import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:lottie/lottie.dart';
import '../engine/AstroEngine.dart';
import '../helpers/translate_helper.dart';
import '../widgets/loading_overlay.dart';

class ChineseZodiacPage extends StatefulWidget {
  @override
  _ChineseZodiacPageState createState() => _ChineseZodiacPageState();
}

class _ChineseZodiacPageState extends State<ChineseZodiacPage> {
  int _selectedYear = DateTime.now().year;

  void _calculateChinese() {
    final loadingMsg = t(context, "Konsultujemo drevne mudrace...", listen: false);
    LoadingOverlay.show(context, loadingMsg);
    
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      LoadingOverlay.hide();
      
      final result = AstroEngine.getChineseZodiac(_selectedYear);
      _showResult(result['sign']!, result['element']!, result['description']!);
    });
  }

  void _showResult(String sign, String element, String description) {
  // Uzimamo boju teksta iz teme (bela u tamnoj, crna u svetloj temi)
  final isDark = NeumorphicTheme.isUsingDark(context);
final dynamicTextColor = isDark ? Colors.white : Colors.black87;

final dialogBg = isDark ? const Color(0xFF1F1F1F) : NeumorphicTheme.baseColor(context);
final secondaryText = isDark ? Colors.white70 : Colors.black54;
final dividerColor = isDark ? Colors.white24 : Colors.black26;


  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: NeumorphicTheme.baseColor(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            t(context, "Tvoj kineski znak je:", listen: false), 
            style: TextStyle(color: dynamicTextColor, fontSize: 16) // FIX: Naslov
          ),
          const SizedBox(height: 15),
          _getZodiacIcon(sign), 
          const SizedBox(height: 10),
          Text(
            t(context, sign, listen: false), 
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.red[800])
          ),
          Text(
            "${t(context, "Element", listen: false)}: ${t(context, element, listen: false)}", 
            style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.blueGrey)
          ),
          const Divider(height: 30, color: Colors.grey),
          Text(
            t(context, description, listen: false),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14, 
              color: dynamicTextColor, // FIX: Description (Opis)
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          NeumorphicButton(
  onPressed: () => Navigator.pop(context),
  style: NeumorphicStyle(
    depth: 4,
    color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[200],
    boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(14)),
  ),
  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
  child: Text(
    t(context, "Zatvori", listen: false),
    style: TextStyle(color: dynamicTextColor, fontWeight: FontWeight.bold),
  ),
),
        ],
      ),
    ),
  );
}

  Widget _getZodiacIcon(String sign) {
    switch (sign) {
      case "Zmaj": return const Text("🐉", style: TextStyle(fontSize: 50));
      case "Tigar": return const Text("🐅", style: TextStyle(fontSize: 50));
      case "Zmija": return const Text("🐍", style: TextStyle(fontSize: 50));
      case "Pacov": return const Text("🐀", style: TextStyle(fontSize: 50));
      case "Bivo": return const Text("🐂", style: TextStyle(fontSize: 50));
      case "Zec": return const Text("🐇", style: TextStyle(fontSize: 50));
      case "Konj": return const Text("🐎", style: TextStyle(fontSize: 50));
      case "Koza": return const Text("🐐", style: TextStyle(fontSize: 50));
      case "Majmun": return const Text("🐒", style: TextStyle(fontSize: 50));
      case "Petao": return const Text("🐓", style: TextStyle(fontSize: 50));
      case "Pas": return const Text("🐕", style: TextStyle(fontSize: 50));
      case "Svinja": return const Text("🐖", style: TextStyle(fontSize: 50));
      default: return Icon(Icons.auto_awesome, size: 50, color: Colors.red[700]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = NeumorphicTheme.isUsingDark(context);
final textColor = isDark ? Colors.white : Colors.black87;

final fieldBg = isDark ? const Color(0xFF2A2A2A) : NeumorphicTheme.baseColor(context);
final dropdownBg = isDark ? const Color(0xFF1F1F1F) : NeumorphicTheme.baseColor(context);

    return Scaffold(
      backgroundColor: NeumorphicTheme.baseColor(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Lottie.asset('assets/chinese.json', height: 200, errorBuilder: (c,e,s) => Icon(Icons.auto_awesome, size: 100, color: textColor)),
            const SizedBox(height: 30),
            Text(t(context, "Izračunaj svoj znak u kineskom horoskopu!!!"), style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 30),
            Text(t(context, "Izaberi godinu rođenja:"), style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 20),
            Neumorphic(
  style: NeumorphicStyle(
    depth: -5,
    boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(15)),
    color: fieldBg,
  ),
  child: DropdownButtonHideUnderline(
    child: DropdownButton<int>(
      value: _selectedYear,
      isExpanded: true,
      dropdownColor: dropdownBg,
      icon: Icon(Icons.arrow_drop_down, color: textColor),

      // BITNO: ovo kontroliše boju selektovanog teksta (ono što vidiš zatvoreno)
      style: TextStyle(color: textColor, fontSize: 16),

      // BITNO: da selektovana vrednost bude ista kao u itemima
      selectedItemBuilder: (context) {
        return List.generate(100, (index) {
          final year = DateTime.now().year - index;
          return Center(
            child: Text(
              year.toString(),
              style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w600),
            ),
          );
        });
      },

      items: List.generate(100, (index) => DateTime.now().year - index)
          .map((year) => DropdownMenuItem<int>(
                value: year,
                child: Center(
                  child: Text(
                    year.toString(),
                    style: TextStyle(color: textColor, fontSize: 16),
                  ),
                ),
              ))
          .toList(),

      onChanged: (val) => setState(() => _selectedYear = val!),
    ),
  ),
),

            const SizedBox(height: 50),
            NeumorphicButton(
              onPressed: _calculateChinese,
              style: NeumorphicStyle(color: Colors.red[50], depth: 8),
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 50),
              child: Text(
                t(context, "Izračunaj"), 
                style: TextStyle(color: Colors.red[900], fontWeight: FontWeight.bold)
              ),
            ),
          ],
        ),
      ),
    );
  }
}