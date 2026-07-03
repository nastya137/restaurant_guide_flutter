import 'package:flutter/material.dart';
import 'package:flutter_project/real_restaurant_api.dart';
import 'package:flutter_project/restaurant_detail_screen.dart';
import 'booking_repository.dart';
import 'main.dart';
import 'filter_screen.dart';
import 'my_bookings_screen.dart';

class RestaurantListScreen extends StatefulWidget {
  final RealRestaurantApi api;
  final String userName;
  final int userId;

  const RestaurantListScreen({
    super.key,
    required this.api,
    required this.userName,
    required this.userId,
  });

  @override
  State<RestaurantListScreen> createState() => _RestaurantListScreenState();
}

class _RestaurantListScreenState extends State<RestaurantListScreen> {
  List<Restaurant> _restaurants = [];
  bool _loading = true;
  String? _error;
  RestaurantFilter _filter = RestaurantFilter.defaults;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await widget.api.fetchRestaurants();
      setState(() { _restaurants = data; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  List<Restaurant> get _filteredRestaurants {
    return _restaurants.where((r) {
      if (_filter.cuisine != 'Все' && r.cuisine != _filter.cuisine) {
        return false;
      }

      if (r.averageCheck < _filter.averageCheckRange.start ||
          r.averageCheck > _filter.averageCheckRange.end) {
        return false;
      }

      if (_filter.wifi && !r.features.contains('WiFi')) return false;
      if (_filter.parking && !r.features.contains('Парковка')) return false;
      if (_filter.kidsMenu && !r.features.contains('Детское меню')) {
        return false;
      }

      return true;
    }).toList();
  }

  Future<void> _openFilter() async {
    final result = await Navigator.push<RestaurantFilter>(
      context,
      MaterialPageRoute(
        builder: (_) => FilterScreen(filter: _filter),
      ),
    );

    if (result != null) {
      setState(() {
        _filter = result;
      });
    }
  }

  void _openDetails(Restaurant restaurant) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RestaurantDetailScreen(
          restaurant: restaurant,
          api: widget.api,
          userId: widget.userId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Рестораны • ${widget.userName}'),
        actions: [
          IconButton(onPressed: _openFilter, icon: const Icon(Icons.filter_list)),
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
          IconButton(
            icon: const Icon(Icons.book_online),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MyBookingsScreen(
                    api: widget.api,
                    userId: widget.userId,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Ошибка: $_error'))
          : RefreshIndicator(
        onRefresh: _load,
        child: ListView.builder(
          itemCount: _filteredRestaurants.length,
          itemBuilder: (context, index) {
            final r = _filteredRestaurants[index];
            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                leading: Image.network(
                  r.photoUrl,
                  width: 60,
                  fit: BoxFit.cover,
                ),
                title: Text(r.name),
                subtitle: Text(
                  '${r.cuisine} • ⭐ ${r.rating} • ${r.averageCheck}₽',
                ),
                onTap: () => _openDetails(r),
              ),
            );
          },
        ),
      ),
    );
  }
}
