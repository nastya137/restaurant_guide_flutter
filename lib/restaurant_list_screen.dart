import 'package:flutter/material.dart';
import 'package:flutter_project/real_restaurant_api.dart';
import 'package:flutter_project/restaurant_detail_screen.dart';

import 'app_theme.dart';
import 'app_widgets.dart';
import 'filter_screen.dart';
import 'main.dart';
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
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await widget.api.fetchRestaurants();
      setState(() {
        _restaurants = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
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

  bool get _hasActiveFilters {
    return _filter.cuisine != RestaurantFilter.defaults.cuisine ||
        _filter.wifi ||
        _filter.parking ||
        _filter.kidsMenu ||
        _filter.averageCheckRange !=
            RestaurantFilter.defaults.averageCheckRange;
  }

  Future<void> _openFilter() async {
    final result = await Navigator.push<RestaurantFilter>(
      context,
      MaterialPageRoute(builder: (_) => FilterScreen(filter: _filter)),
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

  void _openBookings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            MyBookingsScreen(api: widget.api, userId: widget.userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 84,
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Добрый день, ${widget.userName}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 3),
            Text(
              'Куда отправимся сегодня?',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        actions: [
          SurfaceIconButton(
            icon: Icons.tune_rounded,
            tooltip: 'Фильтры',
            badge: _hasActiveFilters,
            onPressed: _openFilter,
          ),
          const SizedBox(width: 4),
          SurfaceIconButton(
            icon: Icons.calendar_month_outlined,
            tooltip: 'Мои брони',
            onPressed: _openBookings,
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2.5));
    }

    if (_error != null) {
      return AppStateView(
        icon: Icons.wifi_off_rounded,
        title: 'Не удалось загрузить места',
        message: 'Проверьте подключение к интернету и попробуйте ещё раз.',
        actionLabel: 'Повторить',
        onAction: _load,
      );
    }

    final restaurants = _filteredRestaurants;
    if (restaurants.isEmpty) {
      return AppStateView(
        icon: Icons.search_off_rounded,
        title: 'Ничего не нашли',
        message:
            'Попробуйте изменить параметры — подходящее место наверняка есть.',
        actionLabel: 'Изменить фильтры',
        onAction: _openFilter,
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.olive,
      backgroundColor: AppColors.surface,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        itemCount: restaurants.length + 1,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _ListHeading(
              count: restaurants.length,
              activeCuisine: _filter.cuisine == 'Все' ? null : _filter.cuisine,
            );
          }
          final restaurant = restaurants[index - 1];
          return _RestaurantCard(
            restaurant: restaurant,
            onTap: () => _openDetails(restaurant),
          );
        },
      ),
    );
  }
}

class _ListHeading extends StatelessWidget {
  const _ListHeading({required this.count, required this.activeCuisine});

  final int count;
  final String? activeCuisine;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Рестораны рядом',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              '$count ${_placeWord(count)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (activeCuisine != null) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('•', style: TextStyle(color: AppColors.muted)),
              ),
              Flexible(
                child: Text(
                  activeCuisine!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.olive,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  String _placeWord(int count) {
    final mod100 = count % 100;
    final mod10 = count % 10;
    if (mod100 >= 11 && mod100 <= 14) return 'мест';
    if (mod10 == 1) return 'место';
    if (mod10 >= 2 && mod10 <= 4) return 'места';
    return 'мест';
  }
}

class _RestaurantCard extends StatelessWidget {
  const _RestaurantCard({required this.restaurant, required this.onTap});

  final Restaurant restaurant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'restaurant-${restaurant.id}',
                    child: AppNetworkImage(url: restaurant.photoUrl),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0x66000000)],
                        stops: [0.48, 1],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 14,
                    right: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x22000000),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 18,
                            color: AppColors.accent,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            restaurant.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: AppColors.ink,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 17, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          restaurant.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          color: AppColors.olive,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Text(
                    '${restaurant.cuisine}  •  Средний чек ${restaurant.averageCheck} ₽',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (restaurant.features.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: restaurant.features
                          .take(3)
                          .map(
                            (feature) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.oliveSoft,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                feature,
                                style: const TextStyle(
                                  color: AppColors.olive,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
