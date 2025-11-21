import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weatherapp/provider/weather_provider.dart';
import 'package:weatherapp/screens/favourites_screen.dart';
import 'package:weatherapp/utils/weather_assets.dart';
import 'package:weatherapp/widgets/forecast_list.dart';
import '../widgets/weather_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _cityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<WeatherProvider>(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppBar(
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade800.withOpacity(0.9),
                  Colors.blue.shade400.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: Row(
            children: [
              Icon(Icons.wb_cloudy, color: Colors.white, size: 28),
              SizedBox(width: 10),
              Text(
                "Weather Pro",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          centerTitle: false,
          actions: [
  IconButton(
    icon: Icon(Icons.my_location, color: Colors.white),
    onPressed: () => prov.fetchByLocation(),
  ),

  IconButton(
    icon: Icon(Icons.refresh, color: Colors.white),
    onPressed: () {
      prov.refresh();
    },
  ),

  IconButton(
    icon: Icon(Icons.star, color: Colors.white),
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => FavouritesScreen()),
      );
    },
  ),

  SizedBox(width: 4),
],

        ),
      ),

      body: Stack(
        children: [
          Positioned.fill(
            child: prov.weather != null
                ? Image.asset(
                    backgroundForWeather(prov.weather!.description),
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(color: Colors.blue.shade600),
                  )
                : Container(color: Colors.blue.shade600),
          ),

          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.28),
            ),
          ),
         SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _cityController,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (v) => _search(prov),
                        decoration: InputDecoration(
                          hintText: 'Search city, e.g. Mumbai',
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: Icon(Icons.search),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => _search(prov),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 14,
                        ),
                      ),
                      child: Text('Search'),
                    ),
                  ],
                ),
                SizedBox(height: 18),

                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => prov.refresh(),
                    child: prov.loading
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 220),
                              Center(child: CircularProgressIndicator()),
                            ],
                          )
                        : prov.error != null
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            children: [
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24.0,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        size: 42,
                                        color: Colors.redAccent,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        prov.error!,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          ElevatedButton.icon(
                                            icon: Icon(Icons.refresh),
                                            label: Text('Retry'),
                                            onPressed: () {
                                              if (prov.lastCity != null &&
                                                  prov.lastCity!.isNotEmpty) {
                                                prov.fetchByCity(
                                                  prov.lastCity!,
                                                );
                                              } else if (prov.error!
                                                  .toLowerCase()
                                                  .contains('location')) {
                                                prov.fetchByLocation();
                                              } else {
                                                prov.fetchByCity(
                                                  'Delhi',
                                                ); 
                                              }
                                            },
                                          ),
                                          const SizedBox(width: 10),
                                          TextButton(
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (_) => AlertDialog(
                                                  title: Text('Troubleshoot'),
                                                  content: Text(
                                                    '• Check your internet connection\n'
                                                    '• Ensure app has background/mobile data enabled\n'
                                                    '• If using location, enable location permission\n'
                                                    '• Check your API key in constants.dart',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            context,
                                                          ),
                                                      child: Text('OK'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                            child: Text(
                                              'Help',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : prov.weather == null
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 120),
                              Center(
                                child: Icon(
                                  Icons.cloud,
                                  size: 80,
                                  color: Colors.white70,
                                ),
                              ),
                              SizedBox(height: 12),
                              Center(
                                child: Text(
                                  'Search for a city or use your location',
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ),
                            ],
                          )
                        : SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Column(
                              children: [
                                WeatherCard(),
                                SizedBox(height: 18),
                                if (prov.forecast != null &&
                                    prov.forecast!.isNotEmpty) ...[
                                  ForecastList(
                                    list: prov.forecast!,
                                    isCelsius: prov.isCelsius,
                                  ),
                                  SizedBox(height: 18),
                                ],

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Celsius',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Switch(
                                      value: prov.isCelsius,
                                      onChanged: (_) => prov.toggleUnit(),
                                    ),
                                    Text(
                                      'Fahrenheit',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
        ]
      ),
    );
  }

  void _search(WeatherProvider prov) {
    final city = _cityController.text.trim();
    if (city.isNotEmpty) {
      prov.fetchByCity(city);
      FocusScope.of(context).unfocus();
      _cityController.clear(); 
      
    }
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud, size: 80, color: Colors.white70),
          SizedBox(height: 12),
          Text(
            'Search for a city or use your location',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
