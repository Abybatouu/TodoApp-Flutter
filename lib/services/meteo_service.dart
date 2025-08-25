import 'dart:convert';
import 'package:http/http.dart' as http;

class MeteoService {
  static const String _apiKey = "4d2ab05eaa7834f6af59a30fd9c4f490"; //ma cle d'API OpenWeatherMap

  static Future<String> getMeteo(double lat, double lon) async {
    final url =
        "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric&lang=fr";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final temp = data["main"]["temp"];
        final desc = data["weather"][0]["description"];
        final city = data["name"];

        return "$temp°C à $city | $desc";
      } else {
        return "Erreur météo (${response.statusCode})";
      }
    } catch (e) {
      return "Erreur: $e";
    }
  }
}
