import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:weatherapp/provider/weather_provider.dart';

class WeatherCard extends StatelessWidget {
  const WeatherCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<WeatherProvider>(context);
    final w = prov.weather!;
    final temp = prov.displayTemp();
    final unit = prov.tempUnit();

    final iconUrl = w.icon.isNotEmpty
        ? 'http://openweathermap.org/img/wn/${w.icon}@2x.png'
        : null;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  alignment: Alignment.center,
                  child: iconUrl != null
                      ? CachedNetworkImage(
                          imageUrl: iconUrl,
                          width: 64,
                          height: 64,
                          fit: BoxFit.contain,
                          placeholder: (c, u) => const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2)),
                          errorWidget: (c, u, e) =>
                              const Icon(Icons.wb_cloudy, size: 48),
                        )
                      : const Icon(Icons.wb_cloudy, size: 48),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        w.cityName,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        w.description,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                IconButton(
                  icon: Icon(
                    prov.favourites.contains(w.cityName)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: Colors.redAccent,
                  ),
                  onPressed: () {
                    final city = w.cityName;
                    if (city.isEmpty) return;

                    if (prov.favourites.contains(city)) {
                      prov.removeFavourite(city);
                    } else {
                      prov.addFavourite(city);
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              '${temp.toStringAsFixed(1)} $unit',
              style:
                  const TextStyle(fontSize: 48, fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(child: _InfoColumn(label: 'Humidity', value: '${w.humidity}%')),
                Expanded(child: _InfoColumn(label: 'Wind', value: '${(w.windSpeed * 3.6).toStringAsFixed(1)} km/h')),
                Expanded(child: _InfoColumn(label: 'Feels', value: _feelsLikeLabel(w.tempC, prov.isCelsius))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _feelsLikeLabel(double c, bool isC) {
    final val = isC ? c : (c * 9 / 5) + 32;
    return '${val.toStringAsFixed(0)}';
  }
}

class _InfoColumn extends StatelessWidget {
  final String label;
  final String value;
  const _InfoColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
