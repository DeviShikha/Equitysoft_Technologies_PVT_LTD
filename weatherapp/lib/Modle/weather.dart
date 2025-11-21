// lib/Modle/weather.dart (modify existing)
class Weather {
  final String cityName;
  final double tempC;
  final int humidity;
  final double windSpeed;
  final String description;
  final String icon;
  final double lat;
  final double lon;

  Weather({
    required this.cityName,
    required this.tempC,
    required this.humidity,
    required this.windSpeed,
    required this.description,
    required this.icon,
    required this.lat,
    required this.lon,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    final main = json['main'] ?? {};
    final wind = json['wind'] ?? {};
    final weatherList = (json['weather'] as List<dynamic>?) ?? [];
    final weather = weatherList.isNotEmpty ? weatherList.first : null;
    final coord = json['coord'] ?? {};

    return Weather(
      cityName: json['name'] ?? '',
      tempC: (main['temp'] ?? 0).toDouble(),
      humidity: (main['humidity'] ?? 0).toInt(),
      windSpeed: (wind['speed'] ?? 0).toDouble(),
      description: weather != null ? (weather['description'] ?? '') : '',
      icon: weather != null ? (weather['icon'] ?? '') : '',
      lat: (coord['lat'] ?? 0).toDouble(),
      lon: (coord['lon'] ?? 0).toDouble(),
    );
  }
}
