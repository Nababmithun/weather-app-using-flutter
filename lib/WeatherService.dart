import 'dart:convert';

import 'Weather.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String apiKey = 'e85b9ae6b455c4730ab9e316c5683bf3';
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  Future<Weather> fetchWeatherByCity(String city) async {
    final url = Uri.parse('$baseUrl?q=$city&units=metric&appid=$apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Weather.fromJson(json);
    } else {
      throw Exception('Failed to load weather');
    }
  }

  Future<Weather> fetchWeatherByLocation(double lat, double lon) async {
    final url = Uri.parse('$baseUrl?lat=$lat&lon=$lon&units=metric&appid=$apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Weather.fromJson(json);
    } else {
      throw Exception('Failed to load weather');
    }
  }
}