import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:intl/intl.dart'; 
import 'package:ljubavnikalkulator/engine/AstroEngine.dart';
import 'package:ljubavnikalkulator/ui/ui_tokens.dart';
import '../helpers/translate_helper.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../services/astro_service.dart';
import 'package:timezone/timezone.dart' as tz;




class AscendantPage extends StatefulWidget {
  @override
  _AscendantPageState createState() => _AscendantPageState();
}

class _AscendantPageState extends State<AscendantPage> {
  final TextEditingController _cityController = TextEditingController();
  String _selectedCity = "Beograd, Serbia";
double _lat = 44.8125;
double _lon = 20.4612;
  DateTime _selectedDate = DateTime(1995, 1, 1);
  TimeOfDay _selectedTime = const TimeOfDay(hour: 12, minute: 0);

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
  showGeneralDialog(
  context: context,
  barrierDismissible: false,
  pageBuilder: (context, anim1, anim2) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: UiTokens.pagePadding,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Lottie.asset(
                      'assets/stars.json',
                      height: 250,
                      errorBuilder: (c, e, s) =>
                          const CircularProgressIndicator(color: Colors.pink),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      t(context, "Čitamo zvezde..."),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  },
);



  Future.delayed(const Duration(seconds: 2), () {
    Navigator.pop(context);

    // --- TAČNA TZ KONVERZIJA (ne zavisi od telefona) ---
    final loc = tz.getLocation('Europe/Belgrade');

    final birthLocal = tz.TZDateTime(
      loc,
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final birthUtc = birthLocal.toUtc();

    // Debug (da vidiš da nije +6h ili neka glupost)
    // Očekuješ za Srbiju 1991-09-27: offset +02:00 (CEST)
    // i UTC = local - 2h
    debugPrint("BIRTH LOCAL: $birthLocal  offset=${birthLocal.timeZoneOffset}");
    debugPrint("BIRTH UTC:   $birthUtc   isUtc=${birthUtc.isUtc}");
    debugPrint("LAT/LON: $_lat / $_lon");

    // --- RAČUNANJE: Sun po lokalnom datumu, Moon + Asc po UTC ---
    final sun = AstroEngine.getZodiacSign(DateTime(
      birthLocal.year,
      birthLocal.month,
      birthLocal.day,
    ));

    final moon = AstroEngine.getMoonSignUtc(birthUtc);

    final asc = AstroEngine.calculateAscendantUtc(
      birthUtc,
      lat: _lat,
      lon: _lon,
    );

    final natalData = <String, String>{
      "sun": sun,
      "moon": moon,
      "ascendant": asc,
    };

    _showAscendantResult(natalData);
  });
}


  void _showAscendantResult(Map<String, String> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: NeumorphicTheme.baseColor(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Text(t(context, "Tvoj Natal"), textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildResultRow(t(context, "Sunce"), t(context, data['sun']!), Icons.wb_sunny, Colors.orange),
            const Divider(),
            _buildResultRow(t(context, "Podznak"), t(context, data['ascendant']!), Icons.expand_less, Colors.deepPurple),
            const Divider(),
            _buildResultRow(t(context, "Mesec"), t(context, data['moon']!), Icons.nightlight_round, Colors.blueGrey),
            const SizedBox(height: 25),
            
            Neumorphic(
              style: NeumorphicStyle(
                depth: -3,
                boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(15)),
              ),
              padding: const EdgeInsets.all(15),
              child: Text(
                _getSignDescription(data['ascendant']!), 
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
        actions: [
          NeumorphicButton(
            onPressed: () => Navigator.pop(context),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(t(context, "Zatvori"), style: const TextStyle(color: Colors.pink)),
          )
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          Text(
            value, 
            style: TextStyle(color: Colors.pink[400], fontWeight: FontWeight.bold, fontSize: 16)
          ),
        ],
      ),
    );
  }

  String _getSignDescription(String? sign) {
    Map<String, String> descriptions = {
      "Ovan": "Energični i hrabri, uvek idete prvi i volite izazove.",
      "Bik": "Stabilni i pouzdani, uživate u lepoti i životnim zadovoljstvima.",
      "Blizanci": "Radoznali i društveni, uvek imate spremnu pravu reč.",
      "Rak": "Osećajni i intuitivni, veoma ste povezani sa domom i porodicom.",
      "Lav": "Srdačni i harizmatični, volite da inspirišete druge oko sebe.",
      "Devica": "Precizni i analitični, uvek primećujete detalje koje drugi propuste.",
      "Vaga": "Šarmantni i diplomatični, težite balansu i harmoniji u svemu.",
      "Škorpija": "Misteriozni i intenzivni, posedujete neverovatnu unutrašnju snagu.",
      "Strelac": "Avanturisti i optimisti, uvek tražite dublji smisao života.",
      "Jarac": "Ambiciozni i disciplinovani, sigurnim koracima idete ka vrhu.",
      "Vodolija": "Originalni i nezavisni, razmišljate ispred svog vremena.",
      "Ribe": "Sanjari i empatični, imate bogat unutrašnji svet i maštu.",
    };
    return descriptions[sign] ?? "Zanimljiva ličnost sa puno skrivenih talenata.";
  }

Widget _buildCityField() {
  return Neumorphic(
    style: NeumorphicStyle(depth: 4, boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(15))),
    child: TypeAheadField<Map<String, dynamic>>(
      // OVO JE KLJUČNO: Povezujemo kontroler
      controller: _cityController, 
      debounceDuration: const Duration(milliseconds: 500),
      suggestionsCallback: (search) async {
        return await AstroService.searchCities(search);
      },
      builder: (context, controller, focusNode) {
        return TextField(
          controller: controller, // Koristi isti kontroler ovde
          focusNode: focusNode,
          style: TextStyle(color: NeumorphicTheme.defaultTextColor(context)),
          decoration: InputDecoration(
            hintText: t(context, "Mesto rođenja"),
            prefixIcon: Icon(Icons.location_city, color: Colors.pink[300]),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(18),
          ),
        );
      },
      itemBuilder: (context, city) {
        return ListTile(
          tileColor: NeumorphicTheme.baseColor(context),
          title: Text(city['name'], style: TextStyle(color: NeumorphicTheme.defaultTextColor(context))),
        );
      },
      onSelected: (city) {
        setState(() {
          _selectedCity = city['name'];
          _cityController.text = city['name']; // Upisujemo ceo naziv u polje
          _lat = city['lat'];
          _lon = city['lon'];
        });
      },
      emptyBuilder: (context) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(t(context, "Grad nije pronađen. Probaj latinično.")),
      ),
    ),
  );
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
            Lottie.asset(
              'assets/vaga.json', 
              height: 200,
              errorBuilder: (c, e, s) => Icon(Icons.auto_awesome, size: 100, color: Colors.pink[200]),
            ),
            
const SizedBox(height: 20),
            _buildPickerCard(
              title: t(context, "Datum rođenja"),
              value: DateFormat('dd.MM.yyyy').format(_selectedDate),
              icon: Icons.calendar_today,
              onTap: _pickDate,
            ),

            const SizedBox(height: 20),

            _buildPickerCard(
              title: t(context, "Vreme rođenja"),
              value: _selectedTime.format(context),
              icon: Icons.access_time,
              onTap: _pickTime,
            ),

            const SizedBox(height: 10),

            
            _buildCityField(),

            const SizedBox(height: 60),

            NeumorphicButton(
              onPressed: _calculateAscendant,
              style: NeumorphicStyle(
                shape: NeumorphicShape.flat,
                boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
                color: Colors.pink[50],
                depth: 8,
              ),
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 50),
              child: Text(
                t(context, "Otkrij podznak"),
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.pink, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

 Widget _buildPickerCard({
  required String title,
  required String value,
  required IconData icon,
  required VoidCallback onTap,
}) {
  final isDark = NeumorphicTheme.isUsingDark(context);

  final titleColor = isDark ? Colors.white70 : Colors.black54;
  final valueColor = isDark ? Colors.white : Colors.black87;
  final iconColor = isDark ? Colors.pink[200] : Colors.pink[300];
  final editColor = isDark ? Colors.white54 : Colors.grey[500];

  return NeumorphicButton(
    onPressed: onTap,
    style: NeumorphicStyle(
      depth: 4,
      lightSource: LightSource.topLeft,
      boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(15)),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: titleColor, fontSize: 12)),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                ),
              ),
            ],
          ),
          const Spacer(),
          Icon(Icons.edit, size: 16, color: editColor),
        ],
      ),
    ),
  );
}

}