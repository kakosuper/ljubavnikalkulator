import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:intl/intl.dart'; // Za formatiranje datuma
import 'package:ljubavnikalkulator/engine/AstroEngine.dart';
import '../helpers/translate_helper.dart';
import 'package:lottie/lottie.dart';

class AscendantPage extends StatefulWidget {
  @override
  _AscendantPageState createState() => _AscendantPageState();
}

class _AscendantPageState extends State<AscendantPage> {
  DateTime _selectedDate = DateTime(1995, 1, 1);
  TimeOfDay _selectedTime = const TimeOfDay(hour: 12, minute: 0);

  // Funkcija za biranje datuma
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  // Funkcija za biranje vremena (Kružni sat)
  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
    }
  }

void _calculateAscendant() {
    // 1. Pokreni loading overlay sa animacijom sazvežđa
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      pageBuilder: (context, anim1, anim2) {
        return Scaffold(
          backgroundColor: NeumorphicTheme.baseColor(context).withOpacity(0.9),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                
                Lottie.asset('assets/stars.json', height: 250), // Tvoja nova animacija
                const SizedBox(height: 20),
                Text(
                  t(context, "Čitamo zvezde..."),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
    );

    // 2. Simuliraj proračun i prikaži rezultat nakon 2 sekunde
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // Zatvori loading

      String result = AstroEngine.calculateAscendant(
        _selectedDate,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      _showAscendantResult(result);
    });
  }

  void _showAscendantResult(String sign) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: NeumorphicTheme.baseColor(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome, color: Colors.amber, size: 50),
            const SizedBox(height: 20),
            Text(
              t(context, "Tvoj podznak je:"),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Neumorphic(
              style: const NeumorphicStyle(depth: 5, shape: NeumorphicShape.concave),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                t(context, sign), // Prevodi ime znaka (npr. "Ovan")
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.pink),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _getSignDescription(sign),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t(context, "Zatvori")),
          )
        ],
      ),
    );
  }

  String _getSignDescription(String sign) {
    // Ovde možeš dodati kratke opise za svaki podznak
    Map<String, String> descriptions = {
      "Ovan": "Energični i hrabri, uvek idete prvi.",
      "Lav": "Puni ste samopouzdanja i volite pažnju.",
      "Škorpija": "Misteriozni ste i veoma harizmatični.",
      // Dodaj ostale po želji...
    };
    return descriptions[sign] ?? "Zanimljiva ličnost sa puno potencijala.";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeumorphicTheme.baseColor(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Animacija horoskopa/sazvežđa
            Lottie.asset('assets/vaga.json', height: 200,),// Iskoristi vage 
            const SizedBox(height: 30),

            // KARTICA ZA DATUM
            _buildPickerCard(
              title: t(context, "Datum rođenja"),
              value: DateFormat('dd.MM.yyyy').format(_selectedDate),
              icon: Icons.calendar_today,
              onTap: _pickDate,
            ),

            const SizedBox(height: 20),

            // KARTICA ZA VREME (KRUŽNI SAT)
            _buildPickerCard(
              title: t(context, "Vreme rođenja"),
              value: _selectedTime.format(context),
              icon: Icons.access_time,
              onTap: _pickTime,
            ),

            const SizedBox(height: 40),

            NeumorphicButton(
              onPressed: _calculateAscendant,
              style: NeumorphicStyle(
                shape: NeumorphicShape.flat,
                boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
                color: Colors.pink[50],
              ),
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 50),
              child: Text(
                t(context, "Otkrij podznak"),
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.pink),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerCard({required String title, required String value, required IconData icon, required VoidCallback onTap}) {
    return NeumorphicButton(
      onPressed: onTap,
      style: NeumorphicStyle(
        depth: 4,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(15)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        child: Row(
          children: [
            Icon(icon, color: Colors.pink[300]),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: NeumorphicTheme.defaultTextColor(context))),
              ],
            ),
            const Spacer(),
            Icon(Icons.edit, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}