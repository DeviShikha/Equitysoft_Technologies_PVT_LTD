import 'package:flutter/material.dart';
import 'package:weatherapp/Modle/forecast.dart';
// import '../models/forecast.dart';
import 'package:intl/intl.dart';

class ForecastList extends StatelessWidget {
  final List<DailyForecast> list;
  final bool isCelsius;
  const ForecastList({required this.list, this.isCelsius = true});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: list.length,
        separatorBuilder: (_, __) => SizedBox(width: 8),
        itemBuilder: (context, i) {
          final f = list[i];
          final date = DateTime.fromMillisecondsSinceEpoch(f.dt * 1000);
          final day = DateFormat.E().format(date); // Mon, Tue...
          final temp = isCelsius ? f.tempDay : (f.tempDay * 9 / 5) + 32;
          final iconUrl = 'http://openweathermap.org/img/wn/${f.icon}@2x.png';

          return Container(
            width: 100,
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(day, style: TextStyle(color: Colors.white)),
                SizedBox(height: 6),
                Image.network(iconUrl, width: 40, height: 40, errorBuilder: (_, __, ___) => Icon(Icons.cloud, color: Colors.white)),
                SizedBox(height: 6),
                Text('${temp.toStringAsFixed(0)}°', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(f.description, style: TextStyle(color: Colors.white70, fontSize: 10), textAlign: TextAlign.center, maxLines: 1),
              ],
            ),
          );
        },
      ),
    );
  }
}
