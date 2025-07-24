import 'package:hive/hive.dart';

class CacheService {
  final box = Hive.box('weatherCache');

  void cacheWeather(String city, Map<String, dynamic> weatherJson) {
    box.put(city.toLowerCase(), weatherJson);
  }

  Map<String, dynamic>? getCachedWeather(String city) {
    return box.get(city.toLowerCase());
  }
}