import 'dart:math';
import 'package:lunar/lunar.dart' as lunar;

class AstroEngine {
  static const List<String> _zodiac = [
    "Ovan",
    "Bik",
    "Blizanci",
    "Rak",
    "Lav",
    "Devica",
    "Vaga",
    "Škorpija",
    "Strelac",
    "Jarac",
    "Vodolija",
    "Ribe",
  ];

  // =========================
  // Public API (što ti već zoveš)
  // =========================

  /// Tvoj postojeći poziv iz AscendantPage:
  /// AstroEngine.getFullNatalData(_selectedDate, hour, minute, lat: _lat, lon: _lon, timeZoneOffset: offset)
  static Map<String, String> getFullNatalData(
  DateTime birthDate,
  int hour,
  int minute, {
  required double lat,
  required double lon,
  Duration? timeZoneOffset,
}) {
  final local = DateTime(birthDate.year, birthDate.month, birthDate.day, hour, minute);
  final utc = (timeZoneOffset != null) ? local.subtract(timeZoneOffset) : local.toUtc();

  print("LOCAL: $local");
  print("UTC:   $utc  isUtc=${utc.isUtc}");
  print("LAT/LON: $lat / $lon");

  final sun = getZodiacSign(birthDate);
  final moon = getMoonSignUtc(utc);
  final asc = calculateAscendantUtc(utc, lat: lat, lon: lon);

  return {"sun": sun, "moon": moon, "ascendant": asc};
}

/// Kineski znak (po godini)
static Map<String, String> getChineseZodiac(int year) {
  List<String> signs = [
    "Majmun", "Petao", "Pas", "Svinja", "Pacov", "Bivo", 
    "Tigar", "Zec", "Zmaj", "Zmija", "Konj", "Koza"
  ];

  Map<String, String> descriptions = {
      "Pacov": "Pametan, snalažljiv i šarmantan. Lako se prilagođava svakoj situaciji.",
      "Bivo": "Vredan, pouzdan i odlučan. Osoba na koju se svi mogu osloniti.",
      "Tigar": "Hrabar, samouveren i rođeni vođa. Voli izazove i rizik.",
      "Zec": "Nežan, elegantan i ljubazan. Izbegava konflikte i voli mir.",
      "Zmaj": "Moćan, entuzijastičan i pun energije. Sreća ga često prati.",
      "Zmija": "Mudra, misteriozna i intuitivna. Duboko razmišlja pre svakog koraka.",
      "Konj": "Slobodouman, energičan i voli društvo. Ne voli ograničenja.",
      "Koza": "Kreativna, mirna i saosećajna. Ima umetničku dušu.",
      "Majmun": "Duhovit, inteligentan i inovativan. Uvek pronađe rešenje za problem.",
      "Petao": "Precizan, marljiv i iskren. Voli da sve bude pod konac.",
      "Pas": "Veran, pošten i zaštitnički nastrojen. Najbolji prijatelj kojeg možeš imati.",
      "Svinja": "Dobrodušna, velikodušna i iskrena. Uživa u lepim stvarima u životu.",
    };
  
  // Kineski ciklus počinje od godine koja pripada Pacovu
  // Modulo 12 određuje znak
  int index = year % 12;
  String sign = signs[index];

  List<String> elements = ["Metal", "Voda", "Drvo", "Vatra", "Zemlja"];
  // Element se menja svake dve godine
  int elementIndex = ((year % 10) / 2).floor();
  String element = elements[elementIndex % 5];

  return {"sign": sign, "element": element, "description": descriptions[sign] ?? "Opis nije dostupan."};
}

  /// Sunčev znak (po datumu)
  static String getZodiacSign(DateTime date) {
    final d = date.day;
    final m = date.month;

    if ((m == 3 && d >= 21) || (m == 4 && d <= 19)) return "Ovan";
    if ((m == 4 && d >= 20) || (m == 5 && d <= 20)) return "Bik";
    if ((m == 5 && d >= 21) || (m == 6 && d <= 20)) return "Blizanci";
    if ((m == 6 && d >= 21) || (m == 7 && d <= 22)) return "Rak";
    if ((m == 7 && d >= 23) || (m == 8 && d <= 22)) return "Lav";
    if ((m == 8 && d >= 23) || (m == 9 && d <= 22)) return "Devica";
    if ((m == 9 && d >= 23) || (m == 10 && d <= 22)) return "Vaga";
    if ((m == 10 && d >= 23) || (m == 11 && d <= 21)) return "Škorpija";
    if ((m == 11 && d >= 22) || (m == 12 && d <= 21)) return "Strelac";
    if ((m == 12 && d >= 22) || (m == 1 && d <= 19)) return "Jarac";
    if ((m == 1 && d >= 20) || (m == 2 && d <= 18)) return "Vodolija";
    return "Ribe";
  }

  /// Mesec (tropical) iz UTC vremena, aproksimacija dovoljno dobra za znak
  static String getMoonSignUtc(DateTime utc) {
    final jd = _julianDayUtc(utc);
    final d = jd - 2451545.0;

    double Lp = _normDeg(218.316 + 13.176396 * d);
    double D = _normDeg(297.850 + 12.190749 * d);
    double Mp = _normDeg(134.963 + 13.064993 * d);

    double lon = Lp
        + 6.289 * sin(_deg2rad(Mp))
        + 1.274 * sin(_deg2rad(2 * D - Mp))
        + 0.658 * sin(_deg2rad(2 * D))
        + 0.214 * sin(_deg2rad(2 * Mp))
        + 0.110 * sin(_deg2rad(D));

    lon = _normDeg(lon);
    return _zodiac[(lon ~/ 30) % 12];
  }

  /// Podznak (ASC) iz UTC vremena + lokacije (lat/lon u stepenima, lon EAST pozitivno)
 static String calculateAscendantUtc(DateTime utc, {required double lat, required double lon}) {
  final jd = _julianDayUtc(utc);
  final T = (jd - 2451545.0) / 36525.0;

  double gmst = 280.46061837
      + 360.98564736629 * (jd - 2451545.0)
      + 0.000387933 * T * T
      - (T * T * T) / 38710000.0;
  gmst = _normDeg(gmst);

  // LST: longitude east-positive (Srbija je +)
  final lst = _normDeg(gmst + lon);

  final theta = _deg2rad(lst);
  final phi = _deg2rad(lat);

  // obliquity
  final eps = _deg2rad(23.439291 - 0.0130042 * T);

  // ✅ ISPRAVNA ASC formula (ovo ti daje Vodolija 23.54° za tvoj primer)
  final lam = atan2(
    -cos(theta),
    sin(theta) * cos(eps) + tan(phi) * sin(eps),
  );

  double ascDeg = _normDeg(_rad2deg(lam) + 180.0);

  const signs = [
    "Ovan", "Bik", "Blizanci", "Rak", "Lav", "Devica",
    "Vaga", "Škorpija", "Strelac", "Jarac", "Vodolija", "Ribe"
  ];

  return signs[(ascDeg ~/ 30) % 12];
}


static Map<String, String> getFullNatalDataUtc(DateTime utc, {required double lat, required double lon}) {
  return {
    "ascendant": calculateAscendantUtc(utc, lat: lat, lon: lon),
    "moon": getMoonSignUtc(utc),
    // Sun obično ide po lokalnom datumu, ali za tvoju app može i ovako:
    "sun": getZodiacSign(DateTime(utc.year, utc.month, utc.day)),
  };
}



  // =========================
  // Helpers
  // =========================

  static double _julianDayUtc(DateTime utc) {
    // utc MUST be in UTC
    final y0 = utc.year;
    final m0 = utc.month;
    final day = utc.day +
        (utc.hour + utc.minute / 60.0 + utc.second / 3600.0 + utc.millisecond / 3600000.0) / 24.0;

    int y = y0;
    int m = m0;
    if (m <= 2) {
      y -= 1;
      m += 12;
    }

    final A = y ~/ 100;
    final B = 2 - A + (A ~/ 4);

    return (365.25 * (y + 4716)).floorToDouble()
        + (30.6001 * (m + 1)).floorToDouble()
        + day
        + B
        - 1524.5;
  }

  static double _deg2rad(double d) => d * pi / 180.0;
  static double _rad2deg(double r) => r * 180.0 / pi;

  static double _normDeg(double x) {
    x %= 360.0;
    if (x < 0) x += 360.0;
    return x;
  }

  // Ako ti treba i dalje LoveCalculator procenat:
  static int calculateNameMatch(String a, String b) {
    // (ostavi svoju logiku ako već imaš)
    final s1 = _simpleScore(a);
    final s2 = _simpleScore(b);
    final diff = (s1 - s2).abs();
    return (100 - (diff % 100)).clamp(1, 99);
  }

  static int _simpleScore(String s) {
    final t = s.trim().toLowerCase();
    int sum = 0;
    for (final code in t.codeUnits) {
      if (code >= 97 && code <= 122) sum += (code - 96);
    }
    return sum;
  }
static Map<String, String> getChineseZodiacByDate(DateTime birthDate) {
  // bitno: samo datum, bez vremena
  final d = DateTime(birthDate.year, birthDate.month, birthDate.day);

  final l = lunar.Lunar.fromDate(d);

  // Kineski zodiac (ShengXiao) za LUNARNU godinu (tj. pre/posle Chinese New Year je automatski rešeno)
  final shengXiaoCn = l.getYearShengXiao(); // npr. 鼠, 牛, 虎...
  final ganCn = l.getYearGan(); // npr. 甲乙丙丁...

  final sign = _shengXiaoCnToSr(shengXiaoCn);
  final element = _ganToElementSr(ganCn);

  final desc = _chineseDesc(sign, element);

  return {
    "sign": sign,
    "element": element,
    "description": desc,
    "lunarYear": l.getYear().toString(), // zgodno za debug
  };
}

static String _shengXiaoCnToSr(String cn) {
  const map = {
    "鼠": "Pacov",
    "牛": "Bivo",
    "虎": "Tigar",
    "兔": "Zec",
    "龙": "Zmaj",
    "蛇": "Zmija",
    "马": "Konj",
    "羊": "Koza",
    "猴": "Majmun",
    "鸡": "Petao",
    "狗": "Pas",
    "猪": "Svinja",
  };
  return map[cn] ?? "Nepoznato";
}

// Heavenly stem -> element (WuXing)
static String _ganToElementSr(String ganCn) {
  const wood = {"甲", "乙"};
  const fire = {"丙", "丁"};
  const earth = {"戊", "己"};
  const metal = {"庚", "辛"};
  const water = {"壬", "癸"};

  if (wood.contains(ganCn)) return "Drvo";
  if (fire.contains(ganCn)) return "Vatra";
  if (earth.contains(ganCn)) return "Zemlja";
  if (metal.contains(ganCn)) return "Metal";
  if (water.contains(ganCn)) return "Voda";
  return "Nepoznato";
}

static String _chineseDesc(String sign, String element) {
  // kratko i “premium” neutralno; možeš kasnije proširiti
  final base = {
    "Pacov": "Brz um, snalažljivost i jak instinkt.",
    "Bivo": "Stabilnost, upornost i mirna snaga.",
    "Tigar": "Hrabrost, impuls i liderstvo.",
    "Zec": "Takt, elegancija i osećaj za balans.",
    "Zmaj": "Ambicija, harizma i ‘velika’ energija.",
    "Zmija": "Intuicija, strategija i misterioznost.",
    "Konj": "Sloboda, energija i direktnost.",
    "Koza": "Kreativnost, empatija i nežna priroda.",
    "Majmun": "Duhovitost, inteligencija i improvizacija.",
    "Petao": "Perfekcionizam, disciplina i stav.",
    "Pas": "Lojalnost, pravednost i zaštitnički duh.",
    "Svinja": "Toplina, velikodušnost i uživanje u životu.",
  }[sign] ?? "Karakteristična energija znaka.";

  return "$base Dominantni element: $element.";
}

  
}
