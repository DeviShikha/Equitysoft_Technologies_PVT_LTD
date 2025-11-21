import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/weather_provider.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({Key? key}) : super(key: key);

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  bool _loadingCity = false;
  String? _loadingCityName;

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<WeatherProvider>(context);
    final favs = prov.favourites;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Favourites'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade800, Colors.blue.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          if (favs.isNotEmpty)
            IconButton(
              tooltip: 'Clear all favourites',
              icon: const Icon(Icons.delete_forever),
              onPressed: () => _confirmClearAll(context, prov),
            ),
        ],
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: favs.isEmpty
              ? _buildEmptyState(context)
              : RefreshIndicator(
                  onRefresh: () async {
                    prov.notifyListeners();
                  },
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: favs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final city = favs[index];
                      return Dismissible(
                        key: Key(city + index.toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          alignment: Alignment.centerRight,
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (_) => _confirmDeleteDialog(context, city),
                        onDismissed: (_) {
                          prov.removeFavourite(city);
                          ScaffoldMessenger.of(context).removeCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Removed "$city" from favourites'),
                              action: SnackBarAction(
                                label: 'UNDO',
                                onPressed: () {
                                  prov.addFavourite(city);
                                },
                              ),
                            ),
                          );
                        },
                        child: _buildCityCard(context, city, prov),
                      );
                    },
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildCityCard(BuildContext context, String city, WeatherProvider prov) {
    final isLoadingThis = _loadingCity && _loadingCityName == city;

    return Material(
      color: Colors.white.withOpacity(0.04),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: isLoadingThis
            ? null
            : () async {
                setState(() {
                  _loadingCity = true;
                  _loadingCityName = city;
                });
                try {
                  await prov.fetchByCity(city);
                  Navigator.of(context).pop();
                } finally {
                  if (mounted) {
                    setState(() {
                      _loadingCity = false;
                      _loadingCityName = null;
                    });
                  }
                }
              },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade600, Colors.blue.shade300],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  city.isNotEmpty ? city[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      city,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tap to view weather',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),

              if (isLoadingThis) ...[
                SizedBox(width: 8),
                const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
              ] else ...[
                IconButton(
                  tooltip: 'Remove favourite',
                  onPressed: () async {
                    final confirmed = await _confirmDeleteDialog(context, city);
                    if (confirmed) {
                      prov.removeFavourite(city);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Removed "$city"'),
                          action: SnackBarAction(label: 'UNDO', onPressed: () => prov.addFavourite(city)),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.delete, color: Colors.white),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_border, size: 78, color: Colors.white24),
          const SizedBox(height: 18),
          const Text(
            'No favourites yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Search for a city and tap the heart icon to save it here for quick access.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            icon: const Icon(Icons.search),
            label: const Text('Search city'),
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          )
        ],
      ),
    );
  }

  Future<bool> _confirmDeleteDialog(BuildContext context, String city) async {
    final r = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove favourite?'),
        content: Text('Do you want to remove "$city" from favourites?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('REMOVE')),
        ],
      ),
    );
    return r ?? false;
  }

  void _confirmClearAll(BuildContext context, WeatherProvider prov) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear all favourites?'),
        content: const Text('This will remove all saved favourite cities. Continue?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('CLEAR')),
        ],
      ),
    );

    if (confirmed == true) {
      final copy = List<String>.from(prov.favourites);
      for (final c in copy) {
        prov.removeFavourite(c);
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All favourites cleared')));
    }
  }
}
