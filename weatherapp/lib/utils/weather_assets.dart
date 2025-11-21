String backgroundForWeather(String main) {
  final m = main.toLowerCase();
  if (m.contains('clear')) return 'assets/backgrounds/clear.jpg';
  if (m.contains('cloud')) return 'assets/backgrounds/clouds.jpg';
  if (m.contains('rain') || m.contains('drizzle')) return 'assets/backgrounds/rain.jpg';
  if (m.contains('snow')) return 'assets/backgrounds/snow.jpg';
  if (m.contains('thunder')) return 'assets/backgrounds/thunder.jpg';
  return 'assets/backgrounds/mist.jpg';
}
