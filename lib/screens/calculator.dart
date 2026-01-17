import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:ljubavnikalkulator/ui/ui_tokens.dart';
import '../engine/AstroEngine.dart';
import '../helpers/translate_helper.dart';
import '../widgets/loading_overlay.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/services.dart';
import '../models/history_item.dart'; 
import '../services/history_service.dart';
import 'dart:math';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';

class CalculatorPage extends StatefulWidget {
  @override
  _CalculatorPageState createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> with TickerProviderStateMixin {
  final TextEditingController _name1Controller = TextEditingController();
  final TextEditingController _name2Controller = TextEditingController();
  RewardedAd? _rewardedAd;
bool _isAdLoading = false;
bool _isAdvancedUnlocked = false; // ti već imaš, samo ostaje

  late AnimationController _heartController;

  
  final ScreenshotController _shot = ScreenshotController();
// --- KINESKI HOROSKOP ---
String? _chinese1, _chinese2;

final List<String> _chineseSigns = [
  "Pacov", "Bivo", "Tigar", "Zec", "Zmaj", "Zmija",
  "Konj", "Koza", "Majmun", "Petao", "Pas", "Svinja"
];

// --- HOBIJI ---
final List<String> _hobbyOptions = [
  "Muzika", "Filmovi", "Knjige", "Putovanja", "Sport", "Teretana",
  "Kuvanje", "Priroda", "Fotografija", "Umetnost", "Ples", "Igrice",
  "Tehnologija", "Moda", "Društvene igre", "Volontiranje"
];

final Set<String> _hobbies1 = {};
final Set<String> _hobbies2 = {};

  
  // --- NOVI PARAMETRI ---
  String? _sun1, _asc1, _moon1;
  String? _sun2, _asc2, _moon2;

  final List<String> _signs = [
    "Ovan", "Bik", "Blizanci", "Rak", "Lav", "Devica",
    "Vaga", "Škorpija", "Strelac", "Jarac", "Vodolija", "Ribe"
  ];

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
    _name1Controller.addListener(_updateSpeed);
    _name2Controller.addListener(_updateSpeed);
  }

  @override
  void dispose() {
    _name1Controller.dispose();
    _name2Controller.dispose();
    _heartController.dispose();
        _rewardedAd?.dispose();
_rewardedAd = null;
    super.dispose();



  }

  void _updateSpeed() {
    setState(() {
      if (_name1Controller.text.isNotEmpty || _name2Controller.text.isNotEmpty) {
        _heartController.duration = const Duration(milliseconds: 600);
      } else {
        _heartController.duration = const Duration(seconds: 2);
      }
    });
  }

  Widget _buildShareCard(
  BuildContext ctx, {
  required String appName,
  required String name1,
  required String name2,
  required int score,
  required String title,
  required String body,
  required String tip,
  required List<String> highlights,
  required Map<String, int> breakdown,
}) {
  return Neumorphic(
    style: NeumorphicStyle(
      depth: 6,
      boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
      color: NeumorphicTheme.baseColor(ctx),
    ),
    padding: const EdgeInsets.all(16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          appName,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            color: Colors.pink[700],
          ),
        ),
        const SizedBox(height: 6),
        Text(t(ctx, "Rezultat"),
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),

        Text("$name1 ❤ $name2",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.pink[500])),
        const SizedBox(height: 8),

        Text(title, style: TextStyle(fontSize: 16, color: Colors.pink[600], fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),

        Center(
          child: Text(
            "$score%",
            style: TextStyle(fontSize: 44, fontWeight: FontWeight.bold, color: Colors.pink[400]),
          ),
        ),

        const SizedBox(height: 10),
        Text(body, style: const TextStyle(fontSize: 13)),
        const SizedBox(height: 14),

        Neumorphic(
          style: NeumorphicStyle(
            depth: -3,
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(14)),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t(ctx, "Savet"), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.pink[600])),
              const SizedBox(height: 6),
              Text(tip, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(height: 14),

        if (highlights.isNotEmpty) ...[
          Text(t(ctx, "Zašto ovako?"), style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...highlights.map((x) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text("• $x", style: const TextStyle(fontSize: 12)),
              )),
          const SizedBox(height: 12),
        ],

        Text(t(ctx, "Raspodela"), style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...breakdown.entries.map((e) {
          final v = e.value;
          final sign = v >= 0 ? "+$v" : "$v";
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(t(ctx, e.key), style: const TextStyle(fontSize: 12)),
                Text(
                  sign,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: v >= 0 ? Colors.green[700] : Colors.red[700],
                  ),
                ),
              ],
            ),
          );
        }).toList(),

        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            "Otvori $appName\nUnesi 2 imena • tapni „Izračunaj“",
            textAlign: TextAlign.center,
            softWrap: true,
            style: TextStyle(
              fontSize: 11,
              height: 1.25,
              color: Colors.pink[700],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}


  Future<void> _calculate() async {
  final name1 = _name1Controller.text.trim();
  final name2 = _name2Controller.text.trim();
  if (name1.isEmpty || name2.isEmpty) return;

  //HapticFeedback.lightImpact();
buzz();

  LoadingOverlay.show(context, t(context, "Mešamo osećanja...", listen: false));

  Future.delayed(const Duration(seconds: 3), () async {
    if (!mounted) return;
    //HapticFeedback.mediumImpact();
buzz();
    LoadingOverlay.hide();

    // 0..100
    final nameScore = AstroEngine.calculateNameMatch(name1, name2).clamp(0, 100);

    // advanced komponente (svaka 0..100)
    final astro = _isAdvancedUnlocked ? _astroScore0to100() : (score: 50, highlights: <String>[]);
    final chinese = _isAdvancedUnlocked ? _chineseScore0to100() : (score: 50, highlights: <String>[]);
    final hobbies = _isAdvancedUnlocked ? _hobbyScore0to100() : (score: 50, highlights: <String>[]);

    // highlight list
    final highlights = <String>[
      ...astro.highlights,
      ...chinese.highlights,
      ...hobbies.highlights,
    ];

    // Weighted mix: name ima najveći uticaj, advanced fino pomeri ali ne “nabije plafon”
    final double finalRaw = _isAdvancedUnlocked
        ? (nameScore * 0.55 + astro.score * 0.25 + chinese.score * 0.10 + hobbies.score * 0.10)
        : nameScore.toDouble();

    final int finalScore = finalRaw.round().clamp(0, 100);

    final copy = _generateResultCopy(finalScore);

    // Breakdown sad ima smisla: prikazujemo doprinos (koliko poena je svako “dodalo” u mix)
    final breakdown = _isAdvancedUnlocked
        ? <String, int>{
            "Imena": (nameScore * 0.55).round(),
            "Astro": (astro.score * 0.25).round(),
            "Kineski": (chinese.score * 0.10).round(),
            "Hobiji": (hobbies.score * 0.10).round(),
          }
        : <String, int>{
            "Imena": finalScore,
            "Astro": 0,
            "Kineski": 0,
            "Hobiji": 0,
          };

    try {
      final result = HistoryItem(
        name1: name1,
        name2: name2,
        score: finalScore,
        message: copy.title,
        date: DateTime.now(),
        sun1: _sun1, asc1: _asc1, moon1: _moon1,
        sun2: _sun2, asc2: _asc2, moon2: _moon2,
      );
      await HistoryService.saveResult(result);
    } catch (e) {
      debugPrint("Greška pri snimanju: $e");
    }
//HapticFeedback.heavyImpact();
buzz();

    _showResult(
      finalScore,
      title: copy.title,
      body: copy.body,
      highlights: highlights,
      breakdown: breakdown,
      name1: name1,
      name2: name2,
    );
  });
}
Future<void> buzz() async {
  final has = await Vibration.hasVibrator() ?? false;
  if (!has) return;

  Vibration.vibrate(duration: 40); // kratko i jasno
}

// Dart 3 record return: (bonus, highlights)
(int, List<String>) _calcAstroBonus() {
  int bonus = 0;
  final h = <String>[];

  // Sun
  if (_sun1 != null && _sun2 != null) {
    if (_sun1 == _sun2) {
      bonus += 10;
      h.add("Sun: isti znak (${_sun1}) (+10)");
    } else {
      final e1 = _elementOf(_sun1!);
      final e2 = _elementOf(_sun2!);
      if (e1 == e2) {
        bonus += 5;
        h.add("Sun: isti element ($e1) (+5)");
      } else if (_isComplementaryElement(e1, e2)) {
        bonus += 4;
        h.add("Sun: komplementarni elementi ($e1/$e2) (+4)");
      } else if (_isOppositeSign(_sun1!, _sun2!)) {
        bonus += 3;
        h.add("Sun: suprotni znaci (jak magnet) (+3)");
      }
    }
  }

  // Moon
  if (_moon1 != null && _moon2 != null && _moon1 == _moon2) {
    bonus += 6;
    h.add("Moon: isto emotivno čitanje (${_moon1}) (+6)");
  }

  // Asc
  if (_asc1 != null && _asc2 != null && _asc1 == _asc2) {
    bonus += 4;
    h.add("Asc: sličan “prvi utisak” (${_asc1}) (+4)");
  }

  bonus = bonus.clamp(-10, 25);
  return (bonus, h);
}

String _elementOf(String sign) {
  const fire = {"Ovan", "Lav", "Strelac"};
  const earth = {"Bik", "Devica", "Jarac"};
  const air = {"Blizanci", "Vaga", "Vodolija"};
  const water = {"Rak", "Škorpija", "Ribe"};

  if (fire.contains(sign)) return "Vatra";
  if (earth.contains(sign)) return "Zemlja";
  if (air.contains(sign)) return "Vazduh";
  return "Voda";
}

bool _isComplementaryElement(String a, String b) {
  final pair1 = (a == "Vatra" && b == "Vazduh") || (a == "Vazduh" && b == "Vatra");
  final pair2 = (a == "Zemlja" && b == "Voda") || (a == "Voda" && b == "Zemlja");
  return pair1 || pair2;
}

bool _isOppositeSign(String s1, String s2) {
  final idx1 = _signs.indexOf(s1);
  final idx2 = _signs.indexOf(s2);
  if (idx1 < 0 || idx2 < 0) return false;
  return (idx1 - idx2).abs() == 6;
}

(int, List<String>) _calcChineseBonus() {
  int bonus = 0;
  final h = <String>[];

  if (_chinese1 == null || _chinese2 == null) return (0, h);

  final a = _chinese1!;
  final b = _chinese2!;

  // Grupe kompatibilnosti (trine)
  const groups = [
    {"Pacov", "Zmaj", "Majmun"},
    {"Bivo", "Zmija", "Petao"},
    {"Tigar", "Konj", "Pas"},
    {"Zec", "Koza", "Svinja"},
  ];

  const opposites = {
    "Pacov": "Konj",
    "Bivo": "Koza",
    "Tigar": "Majmun",
    "Zec": "Petao",
    "Zmaj": "Pas",
    "Zmija": "Svinja",
  };

  if (a == b) {
    bonus += 4;
    h.add("Kineski: isti znak ($a) (+4)");
    return (bonus, h);
  }

  final sameGroup = groups.any((g) => g.contains(a) && g.contains(b));
  if (sameGroup) {
    bonus += 10;
    h.add("Kineski: odlična grupa ($a + $b) (+10)");
    return (bonus, h);
  }

  final opp = opposites[a];
  final oppReverse = opposites.entries.firstWhere(
    (e) => e.value == a,
    orElse: () => const MapEntry("", ""),
  ).key;

  if (opp == b || oppReverse == b) {
    bonus -= 4; // malo “izazova”, da rezultat bude realniji
    h.add("Kineski: suprotni znakovi ($a ↔ $b) (-4)");
    return (bonus, h);
  }

  bonus += 2;
  h.add("Kineski: neutralno, ali može da radi (+2)");
  return (bonus, h);
}

({int score, List<String> highlights}) _astroScore0to100() {
  int score = 50;
  final h = <String>[];

  // Sun
  if (_sun1 != null && _sun2 != null) {
    if (_sun1 == _sun2) {
      score += 22;
      h.add("Sun: isti znak (${_sun1})");
    } else {
      final e1 = _elementOf(_sun1!);
      final e2 = _elementOf(_sun2!);

      if (e1 == e2) {
        score += 12;
        h.add("Sun: isti element ($e1)");
      } else if (_isComplementaryElement(e1, e2)) {
        score += 10;
        h.add("Sun: komplementarni elementi ($e1/$e2)");
      } else if (_isOppositeSign(_sun1!, _sun2!)) {
        score += 6;
        h.add("Sun: suprotni znaci (magnet)");
      } else {
        score -= 6;
        h.add("Sun: različiti elementi (traži dogovor)");
      }
    }
  } else {
    h.add("Sun: nije uneto za obe osobe");
  }

  // Moon (emocionalna kompatibilnost)
  if (_moon1 != null && _moon2 != null) {
    if (_moon1 == _moon2) {
      score += 14;
      h.add("Moon: isto emotivno čitanje (${_moon1})");
    } else {
      final e1 = _elementOf(_moon1!);
      final e2 = _elementOf(_moon2!);
      if (e1 == e2) {
        score += 8;
        h.add("Moon: isti element ($e1)");
      } else if (_isComplementaryElement(e1, e2)) {
        score += 6;
        h.add("Moon: komplementarni elementi ($e1/$e2)");
      } else {
        score -= 4;
        h.add("Moon: različit emotivni ritam");
      }
    }
  } else {
    h.add("Moon: nije uneto za obe osobe");
  }

  // Asc (prvi utisak / stil)
  if (_asc1 != null && _asc2 != null) {
    if (_asc1 == _asc2) {
      score += 8;
      h.add("Asc: sličan prvi utisak (${_asc1})");
    } else {
      final e1 = _elementOf(_asc1!);
      final e2 = _elementOf(_asc2!);
      if (e1 == e2) {
        score += 4;
        h.add("Asc: sličan stil (isti element)");
      } else {
        score -= 2;
        h.add("Asc: različit nastup");
      }
    }
  } else {
    h.add("Asc: nije uneto za obe osobe");
  }

  score = score.clamp(0, 100);
  return (score: score, highlights: h);
}

({int score, List<String> highlights}) _chineseScore0to100() {
  int score = 50;
  final h = <String>[];

  if (_chinese1 == null || _chinese2 == null) {
    h.add("Kineski: nije izabrano za obe osobe");
    return (score: score, highlights: h);
  }

  final a = _chinese1!;
  final b = _chinese2!;

  const groups = [
    {"Pacov", "Zmaj", "Majmun"},
    {"Bivo", "Zmija", "Petao"},
    {"Tigar", "Konj", "Pas"},
    {"Zec", "Koza", "Svinja"},
  ];

  const opposites = {
    "Pacov": "Konj",
    "Bivo": "Koza",
    "Tigar": "Majmun",
    "Zec": "Petao",
    "Zmaj": "Pas",
    "Zmija": "Svinja",
  };

  if (a == b) {
    score += 12;
    h.add("Kineski: isti znak ($a)");
    return (score: score.clamp(0, 100), highlights: h);
  }

  final sameGroup = groups.any((g) => g.contains(a) && g.contains(b));
  if (sameGroup) {
    score += 22;
    h.add("Kineski: odlična grupa ($a + $b)");
    return (score: score.clamp(0, 100), highlights: h);
  }

  final opp = opposites[a];
  final oppReverse = opposites.entries.firstWhere(
    (e) => e.value == a,
    orElse: () => const MapEntry("", ""),
  ).key;

  if (opp == b || oppReverse == b) {
    score -= 16;
    h.add("Kineski: suprotni znakovi ($a ↔ $b)");
    return (score: score.clamp(0, 100), highlights: h);
  }

  score += 6;
  h.add("Kineski: neutralno ($a + $b)");
  return (score: score.clamp(0, 100), highlights: h);
}
({int score, List<String> highlights}) _hobbyScore0to100() {
  int score = 50;
  final h = <String>[];

  if (_hobbies1.isEmpty || _hobbies2.isEmpty) {
    h.add("Hobiji: nije popunjeno za obe osobe");
    return (score: score, highlights: h);
  }

  final shared = _hobbies1.intersection(_hobbies2);

  if (shared.isEmpty) {
    score -= 18;
    h.add("Hobiji: bez zajedničkih (traži kompromis)");
    return (score: score.clamp(0, 100), highlights: h);
  }

  // maksimalno 8 zajedničkih za puni efekat
  final ratio = (shared.length / 8.0).clamp(0.0, 1.0);
  score += (35 * ratio).round(); // do +35

  final shown = shared.take(5).join(", ");
  h.add("Hobiji: zajednički ($shown${shared.length > 5 ? "…" : ""})");

  return (score: score.clamp(0, 100), highlights: h);
}



({String title, String body}) _generateResultCopy(int score) {
  final r = Random();

  String pick(List<String> options) => options[r.nextInt(options.length)];

  if (score >= 90) {
    return (
      title: pick(["Savršen spoj", "Brutalna hemija", "Kao da ste se dogovorili unapred"]),
      body: pick([
        "Ovo je onaj tip poklapanja gde stvari teku lako i kad ste umorni. Samo pazite da ne preskočite komunikaciju jer ‘ide samo od sebe’.",
        "Visok procenat znači dobar ritam, slične vrednosti i dosta prirodnog razumevanja. Čuvajte to kroz sitnice, ne kroz velike drame.",
        "Ovo je kombinacija koja obično ima i varnicu i stabilnost. Ako se potrudite oko dogovora, može da bude baš ozbiljno."
      ])
    );
  }

  if (score >= 75) {
    return (
      title: pick(["Veoma dobro", "Jak potencijal", "Ima ovo ‘nešto’"]),
      body: pick([
        "Odlično stojite, pogotovo ako se uhvatite na zajedničke rutine i interese. Mali nesporazumi su normalni, ali rešivi.",
        "Ovo je rezultat koji često znači: privlačnost + kompatibilnost. Ako ste iskreni jedno prema drugom, ide lagano.",
        "Dobar balans: ima i razlike (što drži zanimljivo) i sličnosti (što drži stabilno)."
      ])
    );
  }

  if (score >= 55) {
    return (
      title: pick(["Ima nade", "Solidna osnova", "Može da klikne"]),
      body: pick([
        "Niste ‘copy-paste’, ali to nije loše. Ako imate zajedničke stvari i dobar humor, ovo može da naraste.",
        "Rezultat kaže da je ključ u dogovoru i tempu. Ne forsirati, ali ni pustiti da se ohladi bez razloga.",
        "Ovo je odnos koji uspeva kad oboje ulažete malo svesno, a ne samo kad ‘ponese’."
      ])
    );
  }

  if (score >= 35) {
    return (
      title: pick(["Klimavo, ali moguće", "Treba više truda", "Zavisi od vas"]),
      body: pick([
        "Ovo obično znači: različite navike ili očekivanja. Ako pričate otvoreno, možete izbeći glupe svađe.",
        "Nije katastrofa, ali nije ni autopilot. Ako postoji poštovanje, može da se izgradi.",
        "Ovde pomažu zajednički hobiji i jasne granice. Bez toga, lako sklizne u frustraciju."
      ])
    );
  }

  return (
    title: pick(["Težak spoj", "Mnogo izazova", "Bez filtera: naporno"]),
    body: pick([
      "Ovo je rezultat gde lako dolazi do nesporazuma. Ne znači da je nemoguće, ali traži mnogo zrelosti i strpljenja.",
      "Ako vas drži samo varnica, brzo se istroši. Ako imate jaku vrednosnu bazu, onda može da se radi na tome.",
      "Ovo često bude ‘privlačno, ali komplikovano’. Ako se stalno sudarate, možda nije vredno energije."
    ])
  );
}


String _tipForScore(int score) {
  if (score >= 90) return "Ne preskačite dogovor oko sitnica";
  if (score >= 70) return "Najviše dobijate kad imate zajedničku rutinu";
  if (score >= 50) return "Ovo radi ako komunicirate tempo";
  if (score >= 30) return "Bez granica, ovo postaje naporno";
  return "Ako nema poštovanja, ne gubite energiju";
}

void _showResult(
  int score, {
  required String title,
  required String body,
  required List<String> highlights,
  required Map<String, int> breakdown,
  required String name1,   // ✅ dodaj
  required String name2,   // ✅ dodaj
}) {
  final tip = _tipForScore(score);

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: NeumorphicTheme.baseColor(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Screenshot(
  controller: _shot,
  child: SingleChildScrollView(
    child: _buildShareCard(
      ctx,
      appName: "Ljubav i Zvezde",
      name1: name1,
      name2: name2,
      score: score,
      title: title,
      body: body,
      tip: tip,
      highlights: highlights,
      breakdown: breakdown,
    ),
  ),
),

      // ✅ dugmad dole (Share + OK)
     
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
actions: [
  Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Row(
        children: [
          Expanded(
            child: NeumorphicButton(
              onPressed: () async {
                final image = await _shot.capture(pixelRatio: 2.0);
                if (image == null) return;

                await Share.shareXFiles(
                  [
                    XFile.fromData(
                      image,
                      name: "rezultat.png",
                      mimeType: "image/png",
                    ),
                  ],
                  text: "Ljubavni Kalkulator • $score% • $title\nUnesi 2 imena i tapni „Izračunaj“.",
                );
              },
              style: NeumorphicStyle(
                depth: 4,
                color: Colors.pink[50],
                boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(14)),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  t(ctx, "Podeli"),
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.pink[700]),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: NeumorphicButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: NeumorphicStyle(
                depth: 4,
                color: Colors.pink[50],
                boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(14)),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  t(ctx, "OK"),
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.pink[700]),
                ),
              ),
            ),
          ),
        ],
      ),

      const SizedBox(height: 12),

      // ✅ Footer ide ispod dugmadi (nije u Row)

      const SizedBox(height: 6),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Text(
          "Preuzmi aplikaciju i probaj i ti.",
          textAlign: TextAlign.center,
          softWrap: true,
          style: const TextStyle(
            fontSize: 10,
            height: 1.2,
            color: Color.fromARGB(137, 255, 233, 233),
          ),
        ),
      ),
    ],
  ),
],

    ),
  );
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: UiTokens.pagePadding,
        child: Column(
          children: [
            
            SizedBox(
          height: 280,
          width: 280,
          child: Lottie.asset(
            'assets/love.json',
            controller: _heartController,
            fit: BoxFit.contain,
          ),
        ),
            //const SizedBox(height: 30),
            _buildInputField(t(context, "Tvoje ime"), _name1Controller),
            const SizedBox(height: 20),
            _buildInputField(t(context, "Ime simpatije"), _name2Controller),
            const SizedBox(height: 30),
            
            // --- ADVANCED SEKCIJA ---
            _buildAdvancedSection(),
            
            const SizedBox(height: 40),
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

  void _unlockAdvancedViaAd() {
  if (_isAdLoading) return;

  setState(() => _isAdLoading = true);

  void _showRewardedAd() {
  final ad = _rewardedAd;
  if (ad == null) return;

  ad.fullScreenContentCallback = FullScreenContentCallback(
    onAdDismissedFullScreenContent: (ad) {
      ad.dispose();
      _rewardedAd = null;
    },
    onAdFailedToShowFullScreenContent: (ad, err) {
      ad.dispose();
      _rewardedAd = null;
      debugPrint("Rewarded show failed: ${err.message}");
    },
  );

  ad.show(onUserEarnedReward: (ad, reward) {
    if (!mounted) return;
    setState(() => _isAdvancedUnlocked = true); // unlock dok app radi
  });
}

  RewardedAd.load(
    adUnitId: 'ca-app-pub-2037911978579872/8440637260',
    request: const AdRequest(),
    rewardedAdLoadCallback: RewardedAdLoadCallback(
      onAdLoaded: (ad) {
        _rewardedAd = ad;
        if (!mounted) return;
        setState(() => _isAdLoading = false);
        _showRewardedAd();
      },
      onAdFailedToLoad: (err) {
        if (!mounted) return;
        setState(() => _isAdLoading = false);
        debugPrint("Rewarded failed: ${err.message}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t(context, "Reklama nije dostupna trenutno. Probaj opet."))),
        );
      },
    ),
  );
}

  Widget _buildAdvancedSection() {
  // LOCKED VIEW
  if (!_isAdvancedUnlocked) {
    return Neumorphic(
      style: NeumorphicStyle(
        depth: 6,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(18)),
        color: Colors.amber[50],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.lock, color: Colors.orange[700]),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    t(context, "Napredni kalkulator (Astro + Hobiji + Kineski)"),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              t(context, "Otključaj da dodaš astro profil, kineski horoskop i hobije. Rezultat dobija detaljnije tumačenje."),
              style: TextStyle(fontSize: 12, color: Colors.brown[700]),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 12),
            NeumorphicButton(
  onPressed: _isAdLoading ? null : _unlockAdvancedViaAd,
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (_isAdLoading)
        const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
      else
        Icon(Icons.play_circle_fill, color: Colors.pink[400]),
      const SizedBox(width: 10),
      Text(
        _isAdLoading ? t(context, "Učitavam...") : t(context, "Otključaj (gledaj reklamu)"),
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.pink[600]),
      ),
    ],
  ),
),


          ],
        ),
      ),
    );
  }

  // UNLOCKED VIEW
  return Neumorphic(
    style: NeumorphicStyle(
      depth: 6,
      boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(18)),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.pink[400]),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  t(context, "Napredni kalkulator"),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              NeumorphicButton(
                onPressed: () {
                  setState(() {
                    _sun1 = _asc1 = _moon1 = null;
                    _sun2 = _asc2 = _moon2 = null;
                    _chinese1 = _chinese2 = null;
                    _hobbies1.clear();
                    _hobbies2.clear();
                  });
                },
                style: NeumorphicStyle(
                  depth: 2,
                  color: Colors.grey[100],
                  boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Text(t(context, "Reset"), style: const TextStyle(fontSize: 12)),
              ),
            ],
          ),

          const SizedBox(height: 14),
          _sectionTitle(Icons.star, "Astro profil (Sun, Moon, Asc)"),

          const SizedBox(height: 10),
          _profileBlock(
            title: "Ti",
            sun: _sun1, asc: _asc1, moon: _moon1,
            onSun: (v) => setState(() => _sun1 = v),
            onAsc: (v) => setState(() => _asc1 = v),
            onMoon: (v) => setState(() => _moon1 = v),
          ),

          const SizedBox(height: 12),
          _profileBlock(
            title: "Simpatija",
            sun: _sun2, asc: _asc2, moon: _moon2,
            onSun: (v) => setState(() => _sun2 = v),
            onAsc: (v) => setState(() => _asc2 = v),
            onMoon: (v) => setState(() => _moon2 = v),
          ),

          const SizedBox(height: 18),
          _sectionTitle(Icons.pets, "Kineski horoskop"),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildPicker(
                  hint: "Tvoj znak",
                  value: _chinese1,
                  items: _chineseSigns,
                  onChanged: (v) => setState(() => _chinese1 = v),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildPicker(
                  hint: "Znak simpatije",
                  value: _chinese2,
                  items: _chineseSigns,
                  onChanged: (v) => setState(() => _chinese2 = v),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),
          _sectionTitle(Icons.interests, "Hobiji"),
          const SizedBox(height: 10),
          Text(t(context, "Ti"), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          _hobbyChips(_hobbies1),

          const SizedBox(height: 14),
          Text(t(context, "Simpatija"), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          _hobbyChips(_hobbies2),
        ],
      ),
    ),
  );
}

Widget _sectionTitle(IconData icon, String text) {
  return Row(
    children: [
      Icon(icon, size: 18, color: Colors.pink[400]),
      const SizedBox(width: 8),
      Text(
        t(context, text),
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.pink),
      ),
    ],
  );
}

Widget _profileBlock({
  required String title,
  required String? sun,
  required String? asc,
  required String? moon,
  required ValueChanged<String?> onSun,
  required ValueChanged<String?> onAsc,
  required ValueChanged<String?> onMoon,
}) {
  return Neumorphic(
    style: NeumorphicStyle(
      depth: -3,
      boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
    ),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(t(context, title), style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildPicker(hint: "Sun", value: sun, items: _signs, onChanged: onSun)),
              const SizedBox(width: 8),
              Expanded(child: _buildPicker(hint: "Asc", value: asc, items: _signs, onChanged: onAsc)),
              const SizedBox(width: 8),
              Expanded(child: _buildPicker(hint: "Moon", value: moon, items: _signs, onChanged: onMoon)),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _buildPicker({
  required String hint,
  required String? value,
  required List<String> items,
  required ValueChanged<String?> onChanged,
}) {
  return Neumorphic(
    style: NeumorphicStyle(
      depth: -2,
      boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          hint: Text(t(context, hint), style: const TextStyle(fontSize: 12)),
          items: items.map((v) => DropdownMenuItem(value: v, child: Text(t(context, v)))).toList(),
          onChanged: onChanged,
        ),
      ),
    ),
  );
}

Widget _hobbyChips(Set<String> selected) {
  return Wrap(
    spacing: 8,
    runSpacing: 8,
    children: _hobbyOptions.map((h) {
      final isOn = selected.contains(h);
      return FilterChip(
        selected: isOn,
        label: Text(t(context, h)),
        onSelected: (_) {
          setState(() {
            if (isOn) {
              selected.remove(h);
            } else {
              selected.add(h);
            }
          });
        },
      );
    }).toList(),
  );
}


  Widget _buildAstroRow(String label, Function(String?) onS, Function(String?) onA, Function(String?) onM, String? s, String? a, String? m) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t(context, label), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Row(
          children: [
            _buildSmallPicker("Sun", s, onS),
            const SizedBox(width: 5),
            _buildSmallPicker("Asc", a, onA),
            const SizedBox(width: 5),
            _buildSmallPicker("Moon", m, onM),
          ],
        ),
      ],
    );
  }

  Widget _buildSmallPicker(String hint, String? value, Function(String?) onChanged) {
    return Expanded(
      child: Neumorphic(
        style: NeumorphicStyle(depth: -2, boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(10))),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            hint: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(hint, style: TextStyle(fontSize: 10)),
            ),
            isExpanded: true,
            items: _signs.map((sign) => DropdownMenuItem(
              value: sign, 
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(t(context, sign), style: TextStyle(fontSize: 11)),
              )
            )).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String hint, TextEditingController controller) {
    final isDark = NeumorphicTheme.isUsingDark(context);
    return Neumorphic(
      style: NeumorphicStyle(
        depth: -5,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(15)),
        color: NeumorphicTheme.baseColor(context),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black45),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(18),
        ),
      ),
    );
  }
}