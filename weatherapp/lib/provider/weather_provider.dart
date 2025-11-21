import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:weatherapp/Modle/forecast.dart';
import 'package:weatherapp/Modle/weather.dart';
import '../services/weather_service.dart';
import '../services/location_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeatherProvider with ChangeNotifier {
  final WeatherService _service = WeatherService();
  final LocationService _location = LocationService();

  Weather? _weather;
  bool _loading = false;
  String? _error;
  bool _isCelsius = true;
  String? _lastCity;

  Weather? get weather => _weather;
  bool get loading => _loading;
  String? get error => _error;
  bool get isCelsius => _isCelsius;

  List<DailyForecast>? _forecast;
  List<DailyForecast>? get forecast => _forecast;

  List<String> _favourites = [];
  List<String> get favourites => _favourites;

  String? get lastCity => _lastCity;

  WeatherProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    _isCelsius = prefs.getBool('isCelsius') ?? true;
    _lastCity = prefs.getString('lastCity');

    _favourites = prefs.getStringList('favourites') ?? [];

    final cached = prefs.getString('cached_weather_model');
    if (cached != null) {
      try {
        final map = jsonDecode(cached) as Map<String, dynamic>;
        _weather = Weather(
          cityName: map['name'] ?? '',
          tempC: (map['temp'] ?? 0).toDouble(),
          humidity: (map['humidity'] ?? 0).toInt(),
          windSpeed: (map['wind'] ?? 0).toDouble(),
          description: map['description'] ?? '',
          icon: map['icon'] ?? '',
          lat: (map['lat'] ?? 0).toDouble(),
          lon: (map['lon'] ?? 0).toDouble(),
        );
      } catch (_) {
        _weather = null;
      }
    }

    final cachedForecast = prefs.getString('cached_forecast');
    if (cachedForecast != null) {
      try {
        final list = jsonDecode(cachedForecast) as List<dynamic>;
        _forecast = list.map((e) {
          final m = e as Map<String, dynamic>;
          return DailyForecast(
            dt: (m['dt'] ?? 0) as int,
            tempDay: (m['tempDay'] ?? 0).toDouble(),
            tempMin: (m['tempMin'] ?? 0).toDouble(),
            tempMax: (m['tempMax'] ?? 0).toDouble(),
            humidity: (m['humidity'] ?? 0) as int,
            windSpeed: (m['windSpeed'] ?? 0).toDouble(),
            description: m['description'] ?? '',
            icon: m['icon'] ?? '',
          );
        }).toList();
      } catch (_) {
        _forecast = null;
      }
    }

    if (_lastCity != null && _lastCity!.isNotEmpty) {
      fetchByCity(_lastCity!, useCache: true);
    } else {
      notifyListeners();
    }
  }

  Future<void> addFavourite(String city) async {
  if (!_favourites.contains(city)) {
    _favourites.add(city);
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('favourites', _favourites);
    notifyListeners();
  }
}

Future<void> removeFavourite(String city) async {
  _favourites.remove(city);
  final prefs = await SharedPreferences.getInstance();
  prefs.setStringList('favourites', _favourites);
  notifyListeners();
}


  void _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isCelsius', _isCelsius);
    if (_lastCity != null) await prefs.setString('lastCity', _lastCity!);
  }

  void toggleUnit() {
    _isCelsius = !_isCelsius;
    _savePrefs();
    notifyListeners();
  }

  Future<void> _saveCache() async {
    if (_weather == null) return;
    final prefs = await SharedPreferences.getInstance();

    final weatherMap = {
      'name': _weather!.cityName,
      'temp': _weather!.tempC,
      'humidity': _weather!.humidity,
      'wind': _weather!.windSpeed,
      'description': _weather!.description,
      'icon': _weather!.icon,
      'lat': _weather!.lat,
      'lon': _weather!.lon,
    };

    await prefs.setString('cached_weather_model', jsonEncode(weatherMap));

    if (_forecast != null) {
      final list = _forecast!
          .map(
            (f) => {
              'dt': f.dt,
              'tempDay': f.tempDay,
              'tempMin': f.tempMin,
              'tempMax': f.tempMax,
              'humidity': f.humidity,
              'windSpeed': f.windSpeed,
              'description': f.description,
              'icon': f.icon,
            },
          )
          .toList();
      await prefs.setString('cached_forecast', jsonEncode(list));
    }

    await prefs.setInt('cached_time', DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> fetchByCity(String city, {bool useCache = false}) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _lastCity = city;
      final w = await _service.fetchWeatherByCity(city);
      _weather = w;

      try {
        _forecast = await _service.fetch7DayForecast(w.lat, w.lon);
      } catch (_) {
        _forecast = null;
      }

      await _saveCache();
    } on CityNotFoundException catch (e) {
      _error = 'City not found: ${e.city}. Please check the spelling.';
    } on InvalidApiKeyException {
      _error = 'Invalid API key. Please set a valid API key in constants.';
    } on NetworkException catch (e) {
      _error = e.message; // 'No internet' or 'Timeout...'
    } on WeatherApiException catch (e) {
      _error = 'Server error: ${e.message}';
    } catch (e) {
      _error = 'Something went wrong. Please try again.';
    } finally {
      _loading = false;
      _savePrefs();
      notifyListeners();
    }
  }

  Future<void> fetchByLocation() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      Position pos = await _location.getCurrentLocation();
      final w = await _service.fetchWeatherByCoords(
        pos.latitude,
        pos.longitude,
      );
      _weather = w;
      _lastCity = w.cityName;

      try {
        _forecast = await _service.fetch7DayForecast(w.lat, w.lon);
      } catch (_) {
        _forecast = null;
      }

      await _saveCache();
    } on InvalidApiKeyException {
      _error = 'Invalid API key. Please set a valid API key in constants.';
    } on NetworkException catch (e) {
      _error = e.message;
    } on Exception catch (e) {
      final msg = e.toString();
      if (msg.contains('denied')) {
        _error =
            'Location permission denied. Please enable location for the app.';
      } else if (msg.contains('disabled')) {
        _error = 'Location services are disabled. Please enable GPS.';
      } else {
        _error = 'Failed to get location: $msg';
      }
    } finally {
      _loading = false;
      _savePrefs();
      notifyListeners();
    }
  }

 
  Future<void> refresh() async {
    if (_lastCity != null && _lastCity!.isNotEmpty) {
      await fetchByCity(_lastCity!);
    } else if (_weather != null && _weather!.cityName.isNotEmpty) {
      await fetchByCity(_weather!.cityName);
    } else {
      return;
    }
  }

  double displayTemp() {
    if (_weather == null) return 0;
    final c = _weather!.tempC;
    return _isCelsius ? c : (c * 9 / 5) + 32;
  }

  String tempUnit() => _isCelsius ? '°C' : '°F';
}
