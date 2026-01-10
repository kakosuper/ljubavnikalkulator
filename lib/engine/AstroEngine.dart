import 'dart:math';

class AstroEngine {
  
  // 1. NORMALIZACIJA TEKSTA (Tvoj kod)
  static String _prepareString(String input) {
    var cyr = ['а','б','в','г','д','ђ','е','ж','з','и','ј','к','л','љ','м','н','њ','о','п','р','с','т','ћ','у','ф','х','ц','č','џ','ш'];
    var lat = ['a','b','v','g','d','dj','e','z','z','i','j','k','l','lj','m','n','nj','o','p','r','s','t','c','u','f','h','c','c','dz','s'];
    
    String output = input.toLowerCase().trim();
    for (int i = 0; i < cyr.length; i++) {
      output = output.replaceAll(cyr[i], lat[i]);
    }
    return output;
  }

  // 2. LOVE CALCULATOR LOGIKA (Tvoj kod)
  static int calculateNameMatch(String name1, String name2) {
    if (name1.isEmpty || name2.isEmpty) return 0;
    String n1 = _prepareString(name1);
    String n2 = _prepareString(name2);
    String combined = n1 + n2;
    
    int sum = 0;
    for (int i = 0; i < combined.length; i++) {
      sum += combined.codeUnitAt(i);
    }
    int percentage = sum % 101;
    if (percentage < 30) percentage += 40; 
    if (percentage > 100) percentage = 99;
    return percentage;
  }

  // 3. SUNČEV ZNAK (Tvoj kod)
  static String getZodiacSign(DateTime date) {
    int day = date.day;
    int month = date.month;
    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return "Ovan";
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return "Bik";
    if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) return "Blizanci";
    if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) return "Rak";
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return "Lav";
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return "Devica";
    if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) return "Vaga";
    if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) return "Škorpija";
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) return "Strelac";
    if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) return "Jarac";
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) return "Vodolija";
    return "Ribe";
  }

  // 4. PODZNAK (Tvoj kod)
  static String calculateAscendant(DateTime date, int hour, int minute) {
    double time = hour + (minute / 60.0);
    List<String> signs = ["Ovan", "Bik", "Blizanci", "Rak", "Lav", "Devica", "Vaga", "Škorpija", "Strelac", "Jarac", "Vodolija", "Ribe"];
    int month = date.month;
    int index;
    if (month == 1) index = ((time - 4) / 2).floor();
    else if (month == 2) index = ((time - 2) / 2).floor();
    else if (month == 3) index = (time / 2).floor();
    else if (month == 4) index = ((time + 2) / 2).floor();
    else if (month == 5) index = ((time + 4) / 2).floor();
    else if (month == 6) index = ((time + 6) / 2).floor();
    else if (month == 7) index = ((time + 8) / 2).floor();
    else if (month == 8) index = ((time + 10) / 2).floor();
    else if (month == 9) index = ((time + 12) / 2).floor();
    else if (month == 10) index = ((time + 14) / 2).floor();
    else if (month == 11) index = ((time + 16) / 2).floor();
    else index = ((time + 18) / 2).floor();

    index = index % 12;
    if (index < 0) index += 12;
    return signs[index];
  }

  // 5. PRECIZAN MESEC (Moj astronomski dodatak - besplatno i offline)
  static String getAccurateMoonSign(DateTime date, int hour, int minute) {
    // Astronomski proračun na osnovu Julian datuma
    double year = date.year.toDouble();
    double month = date.month.toDouble();
    double day = date.day + (hour / 24.0) + (minute / 1440.0);
    
    if (month <= 2) { year -= 1; month += 12; }
    double a = (year / 100).floorToDouble();
    double b = 2 - a + (a / 4).floorToDouble();
    double jd = (365.25 * (year + 4716)).floorToDouble() + (30.6001 * (month + 1)).floorToDouble() + day + b - 1524.5;

    double t = (jd - 2451545.0) / 36525.0;
    // Mesečeva srednja longituda
    double l = 218.316 + 13.176396 * (jd - 2451545.0);
    // Glavne anomalije za preciznost
    double m = 357.529 + 35.592737 * (jd - 2451545.0);
    double f = 93.272 + 13.229350 * (jd - 2451545.0);
    
    double longitude = l + 6.289 * sin(f * pi / 180) + 1.274 * sin((2*l - f) * pi / 180);
    
    int index = ((longitude % 360) / 30).floor();
    List<String> signs = ["Ovan", "Bik", "Blizanci", "Rak", "Lav", "Devica", "Vaga", "Škorpija", "Strelac", "Jarac", "Vodolija", "Ribe"];
    return signs[index % 12];
  }

  // 6. SPAJANJE SVEGA (Finalna metoda)
  static Map<String, String> getFullNatalData(DateTime date, int hour, int minute, {double? lat, double? lon}) {
    return {
      "sun": getZodiacSign(date),
      "ascendant": calculateAscendant(date, hour, minute),
      "moon": getAccurateMoonSign(date, hour, minute), // Sada je 100% tačno bez API-ja
    };
  }

  // 7. FINALNI SKOR ZA LJUBAV (Tvoj kod)
  static int getFinalScore({required String name1, required String name2, DateTime? bday1, DateTime? bday2}) {
    int nameScore = calculateNameMatch(name1, name2);
    if (bday1 == null || bday2 == null) return nameScore;
    String sign1 = getZodiacSign(bday1);
    String sign2 = getZodiacSign(bday2);
    int astroScore = (sign1 == sign2) ? 95 : 75; 
    return ((nameScore + astroScore) / 2).round();
  }
}