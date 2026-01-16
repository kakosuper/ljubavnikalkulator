import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:lottie/lottie.dart';
import '../engine/AstroEngine.dart';
import '../helpers/translate_helper.dart';
import '../widgets/loading_overlay.dart';
import 'package:ljubavnikalkulator/ui/ui_tokens.dart';


class ChineseZodiacPage extends StatefulWidget {
  @override
  _ChineseZodiacPageState createState() => _ChineseZodiacPageState();
}

class _ChineseZodiacPageState extends State<ChineseZodiacPage> {
  DateTime _birthDate = DateTime(1995, 1, 1);

  Future<void> _pickBirthDate() async {
  final picked = await showDatePicker(
    context: context,
    initialDate: _birthDate,
    firstDate: DateTime(1900),
    lastDate: DateTime.now(),
  );

  if (picked != null) {
    setState(() => _birthDate = picked);
  }
}



  void _calculateChinese() {
    final loadingMsg = t(context, "Konsultujemo drevne mudrace...", listen: false);
    LoadingOverlay.show(context, loadingMsg);
    
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      LoadingOverlay.hide();
      
      final result = AstroEngine.getChineseZodiacByDate(_birthDate);
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
      backgroundColor: Colors.transparent,
  body: SingleChildScrollView(
        padding: UiTokens.pagePadding,
        child: Column(
          children: [
            const SizedBox(height: 20),
            Lottie.asset('assets/chinese.json', height: 200, errorBuilder: (c,e,s) => Icon(Icons.auto_awesome, size: 100, color: textColor)),
            const SizedBox(height: 30),
            Text(t(context, "Izračunaj svoj znak u kineskom horoskopu!!!"), style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 30),
            Text(t(context, "Izaberi godinu rođenja:"), style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 20),
            NeumorphicButton(
  onPressed: _pickBirthDate,
  style: NeumorphicStyle(
    depth: 4,
    boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(15)),
  ),
  child: Padding(
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "${_birthDate.day.toString().padLeft(2, '0')}.${_birthDate.month.toString().padLeft(2, '0')}.${_birthDate.year}",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: UiTokens.textPrimary(context), // ✅ dark=white, light=black
          ),
        ),
        Icon(
          Icons.calendar_today,
          size: 18,
          color: UiTokens.textPrimary(context), // ✅ isto
        ),
      ],
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