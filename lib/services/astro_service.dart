import 'dart:convert';
import 'package:http/http.dart' as http;

class AstroService {
  static Future<List<Map<String, dynamic>>> searchCities(String query) async {
    if (query.length < 3) return [];

    // Koristimo Nominatim API (OpenStreetMap) koji je precizniji za Balkan
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=5&accept-language=sr,hr,bs,en');

    try {
      final response = await http.get(url, headers: {
        'Accept': 'application/json',
        'User-Agent': 'LjubavniKalkulator_v1' // Ovo je OBAVEZNO za Nominatim
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        return data.map((item) {
          // Formatiramo lep naziv: Grad, Država
          String city = item['address']['city'] ?? 
                        item['address']['town'] ?? 
                        item['address']['village'] ?? 
                        item['display_name'].split(',')[0];
          String country = item['address']['country'] ?? "";

          return {
            'name': "$city, $country",
            'lat': double.parse(item['lat']),
            'lon': double.parse(item['lon']),
          };
        }).toList();
      }
    } catch (e) {
      print("Greška u pretrazi gradova: $e");
    }
    return [];
  }
}