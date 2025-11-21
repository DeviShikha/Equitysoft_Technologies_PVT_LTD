class DailyForecast {
  final int dt;
  final double tempDay;
  final double tempMin;
  final double tempMax;
  final int humidity;
  final double windSpeed;
  final String description;
  final String icon;

  DailyForecast({
    required this.dt,
    required this.tempDay,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.windSpeed,
    required this.description,
    required this.icon,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    final weather = (json['weather'] as List).first;
    return DailyForecast(
      dt: json['dt'],
      tempDay: (json['temp']['day'] as num).toDouble(),
      tempMin: (json['temp']['min'] as num).toDouble(),
      tempMax: (json['temp']['max'] as num).toDouble(),
      humidity: (json['humidity'] as num).toInt(),
      windSpeed: (json['wind_speed'] as num).toDouble(),
      description: weather['description'] ?? '',
      icon: weather['icon'] ?? '',
    );
  }

  /// Optional helper for loading from the cached-map shape we store in SharedPreferences
  factory DailyForecast.fromJsonForCache(Map<String, dynamic> m) {
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
  }
}
