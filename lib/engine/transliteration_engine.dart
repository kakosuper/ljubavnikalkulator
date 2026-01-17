class TransliterationEngine {
  static const Map<String, String> _latToCyr = {
    'lj': 'љ', 'Lj': 'Љ', 'LJ': 'Љ',
    'nj': 'њ', 'Nj': 'Њ', 'NJ': 'Њ',

    // ⚠️ dz -> џ ostaje, ali ćemo dodati izuzetak za "podznak"
    'dz': 'џ', 'Dz': 'Џ', 'DZ': 'Џ',
    'dž': 'џ', 'Dž': 'Џ', 'DŽ': 'Џ',

    'a': 'а', 'b': 'б', 'v': 'в', 'g': 'г', 'd': 'д', 'đ': 'ђ', 'e': 'е',
    'ž': 'ж', 'z': 'з', 'i': 'и', 'j': 'ј', 'k': 'к', 'l': 'л', 'm': 'м',
    'n': 'н', 'o': 'о', 'p': 'п', 'r': 'р', 's': 'с', 't': 'т', 'ć': 'ћ',
    'u': 'у', 'f': 'ф', 'h': 'х', 'c': 'ц', 'č': 'ч', 'š': 'ш',

    'A': 'А', 'B': 'Б', 'V': 'В', 'G': 'Г', 'D': 'Д', 'Đ': 'Ђ', 'E': 'Е',
    'Ž': 'Ж', 'Z': 'З', 'I': 'И', 'J': 'Ј', 'K': 'К', 'L': 'Л', 'M': 'М',
    'N': 'Н', 'O': 'О', 'P': 'П', 'R': 'Р', 'S': 'С', 'T': 'Т', 'Ć': 'Ћ',
    'U': 'У', 'F': 'Ф', 'H': 'Х', 'C': 'Ц', 'Č': 'Ч', 'Š': 'Ш',
  };

  // ✅ Izuzeci za reči koje ne smeju da prođu kroz "dz -> џ"
  static const Map<String, String> _exceptions = {
    'podznak': 'подзнак',
    'Podznak': 'Подзнак',
    'PODZNAK': 'ПОДЗНАК',

    // bonus: ako ti negde stoji sa razmakom / crticom
    'pod-znak': 'под-знак',
    'Pod-znak': 'Под-знак',
    'POD-ZNAK': 'ПОД-ЗНАК',
  };

  static String convertToCyrillic(String text) {
    if (text.isEmpty) return text;

    String output = text;

    // 1) Prvo rešimo izuzetke (pre digrafa), da "podznak" ne postane "поџнак"
    _exceptions.forEach((k, v) {
      output = output.replaceAll(k, v);
    });

    // 2) Dvoslovi/digrafi
    _latToCyr.forEach((key, value) {
      if (key.length > 1) {
        output = output.replaceAll(key, value);
      }
    });

    // 3) Ostala slova
    _latToCyr.forEach((key, value) {
      if (key.length == 1) {
        output = output.replaceAll(key, value);
      }
    });

    return output;
  }
}
