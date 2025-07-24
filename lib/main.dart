import 'package:flutter/material.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'service/CacheService.dart';
import 'service/LocationService.dart';
import 'model/Weather.dart';
import 'service/WeatherService.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('weatherCache');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: WeatherHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WeatherHomePage extends StatefulWidget {
  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  final WeatherService _weatherService = WeatherService();
  final LocationService _locationService = LocationService();
  final CacheService _cacheService = CacheService();

  Weather? _weather;
  bool _loading = false;
  String _error = '';
  final _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchWeatherByLocation();
  }

  Future<void> _fetchWeatherByLocation() async {
    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final position = await _locationService.getCurrentPosition();
      final weather = await _weatherService.fetchWeatherByLocation(
        position.latitude,
        position.longitude,
      );
      _cacheService.cacheWeather('current_location', weather.toJson());
      setState(() => _weather = weather);
    } catch (e) {
      final cached = _cacheService.getCachedWeather('current_location');
      if (cached != null) {
        setState(() {
          _weather = Weather.fromJson(cached);
        });
      } else {
        setState(() {
          _error = e.toString();
        });
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _fetchWeatherByCity() async {
    final city = _cityController.text.trim();
    if (city.isEmpty) return;

    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final weather = await _weatherService.fetchWeatherByCity(city);
      _cacheService.cacheWeather(city, weather.toJson());
      setState(() => _weather = weather);
    } catch (e) {
      final cached = _cacheService.getCachedWeather(city);
      if (cached != null) {
        setState(() {
          _weather = Weather.fromJson(cached);
        });
      } else {
        setState(() {
          _error = 'Could not fetch weather for "$city".';
        });
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Weather App')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _cityController,
              decoration: InputDecoration(
                hintText: 'Enter city',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _fetchWeatherByCity,
                ),
              ),
              onSubmitted: (_) => _fetchWeatherByCity(),
            ),
            SizedBox(height: 20),

            if (_loading)
              Center(child: CircularProgressIndicator())
            else if (_error.isNotEmpty)
              Text(_error, style: TextStyle(color: Colors.red))
            else
              Expanded(
                child: ListView(
                  children: [
                    Text(
                      'Weather Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text('Temperature:', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(width: 10),
                        Text(_weather != null ? '${_weather!.temperature}°C' : '—'),
                      ],
                    ),
                    Row(
                      children: [
                        Text('Condition:', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(width: 10),
                        Text(_weather != null ? _weather!.description : '—'),
                      ],
                    ),
                    Row(
                      children: [
                        Text('Humidity:', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(width: 10),
                        Text(_weather != null ? '${_weather!.humidity}%' : '—'),
                      ],
                    ),
                    Row(
                      children: [
                        Text('Wind Speed:', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(width: 10),
                        Text(_weather != null ? '${_weather!.windSpeed} m/s' : '—'),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
