import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:weatherapp/Modle/forecast.dart';
import 'package:weatherapp/Modle/weather.dart';
import '../constants.dart';

class WeatherService {
  final String _apiKey = OPENWEATHER_API_KEY;

  Future<List<DailyForecast>> fetch7DayForecast(double lat, double lon) async {
    final uri = Uri.https('api.openweathermap.org', '/data/2.5/onecall', {
      'lat': lat.toString(),
      'lon': lon.toString(),
      'exclude': 'current,minutely,hourly,alerts',
      'appid': _apiKey,
      'units': 'metric',
    });

    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        final List daily = json['daily'] as List;
        return daily.map((e) => DailyForecast.fromJson(e)).toList();
      } else {
        throw WeatherApiException('Forecast failed: ${res.statusCode}');
      }
    } on SocketException {
      throw NetworkException('No internet connection.');
    } on TimeoutException {
      throw NetworkException('Request timed out.');
    }
  }
  
  Future<Weather> fetchWeatherByCity(String city) async {
    final uri = Uri.https('api.openweathermap.org', '/data/2.5/weather', {
      'q': city,
      'appid': _apiKey,
      'units': 'metric',
    });

    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        return Weather.fromJson(json);
      } else if (res.statusCode == 404) {
        throw CityNotFoundException(city);
      } else if (res.statusCode == 401) {
        throw InvalidApiKeyException();
      } else {
        String msg = 'Unexpected error (code: ${res.statusCode})';
        try {
          final body = jsonDecode(res.body);
          if (body is Map && body['message'] != null) msg = body['message'];
        } catch (_) {}
        throw WeatherApiException(msg);
      }
    } on SocketException {
      throw NetworkException('No internet connection.');
    } on TimeoutException {
      throw NetworkException('Request timed out. Please try again.');
    } catch (e) {
      rethrow;
    }
  }

  Future<Weather> fetchWeatherByCoords(double lat, double lon) async {
    final uri = Uri.https('api.openweathermap.org', '/data/2.5/weather', {
      'lat': lat.toString(),
      'lon': lon.toString(),
      'appid': _apiKey,
      'units': 'metric',
    });

    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        return Weather.fromJson(json);
      } else if (res.statusCode == 401) {
        throw InvalidApiKeyException();
      } else {
        String msg = 'Unexpected error (code: ${res.statusCode})';
        try {
          final body = jsonDecode(res.body);
          if (body is Map && body['message'] != null) msg = body['message'];
        } catch (_) {}
        throw WeatherApiException(msg);
      }
    } on SocketException {
      throw NetworkException('No internet connection.');
    } on TimeoutException {
      throw NetworkException('Request timed out. Please try again.');
    } catch (e) {
      rethrow;
    }
  }
}

class CityNotFoundException implements Exception {
  final String city;
  CityNotFoundException(this.city);
  @override
  String toString() => 'City "$city" not found';
}

class WeatherApiException implements Exception {
  final String message;
  WeatherApiException(this.message);
  @override
  String toString() => message;
}

class InvalidApiKeyException implements Exception {
  @override
  String toString() => 'Invalid API key';
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  @override
  String toString() => message;
}
