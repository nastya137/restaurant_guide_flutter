import 'package:flutter/material.dart';
import 'package:flutter_project/real_restaurant_api.dart';

import 'app_theme.dart';
import 'app_widgets.dart';
import 'booking_screen.dart';
import 'main.dart';

class RestaurantDetailScreen extends StatelessWidget {
  final Restaurant restaurant;
  final RealRestaurantApi api;
  final int userId;

  const RestaurantDetailScreen({
    super.key,
    required this.restaurant,
    required this.api,
    required this.userId,
  });

  Widget _buildReview(
    BuildContext context,
    String author,
    int rating,
    String text,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.oliveSoft,
                  child: Text(
                    author.characters.first,
                    style: const TextStyle(
                      color: AppColors.olive,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    author,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentSoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: AppColors.accent,
                        size: 17,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '$rating.0',
                        style: const TextStyle(
                          color: AppColors.ink,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(text, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }

  Future<void> _openBooking(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            BookingScreen(restaurant: restaurant, api: api, userId: userId),
      ),
    );
    if (result != null && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Бронь успешно создана')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            stretch: true,
            backgroundColor: AppColors.olive,
            foregroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            title: Text(
              restaurant.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Stack(
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
                        colors: [Color(0x44000000), Color(0xAA000000)],
                        stops: [0, 1],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 9),
                  Text(
                    restaurant.cuisine,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: AppColors.muted),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _MetricCard(
                          icon: Icons.star_rounded,
                          value: restaurant.rating.toStringAsFixed(1),
                          label: 'Рейтинг',
                          accent: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MetricCard(
                          icon: Icons.receipt_long_outlined,
                          value: '${restaurant.averageCheck} ₽',
                          label: 'Средний чек',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const SectionTitle('О ресторане'),
                  const SizedBox(height: 12),
                  Text(
                    restaurant.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        children: [
                          _ContactRow(
                            icon: Icons.location_on_outlined,
                            label: 'Адрес',
                            value: restaurant.address,
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 62),
                            child: Divider(),
                          ),
                          _ContactRow(
                            icon: Icons.phone_outlined,
                            label: 'Телефон',
                            value: restaurant.phone,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (restaurant.features.isNotEmpty) ...[
                    const SizedBox(height: 30),
                    const SectionTitle('Удобства'),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 9,
                      runSpacing: 9,
                      children: restaurant.features
                          .map(
                            (feature) => Chip(
                              avatar: Icon(
                                _featureIcon(feature),
                                color: AppColors.olive,
                                size: 18,
                              ),
                              label: Text(feature),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 32),
                  const SectionTitle('Отзывы гостей'),
                  const SizedBox(height: 14),
                  _buildReview(
                    context,
                    'Анна',
                    5,
                    'Отличное место! Очень вкусная паста и приятная атмосфера.',
                  ),
                  const SizedBox(height: 12),
                  _buildReview(
                    context,
                    'Максим',
                    4,
                    'Хороший ресторан, но долго ждали заказ.',
                  ),
                  const SizedBox(height: 12),
                  _buildReview(
                    context,
                    'Ольга',
                    5,
                    'Лучший ресторан в городе! Рекомендую десерты.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          12 + MediaQuery.paddingOf(context).bottom,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.outline)),
        ),
        child: ElevatedButton.icon(
          onPressed: () => _openBooking(context),
          icon: const Icon(Icons.calendar_month_outlined),
          label: const Text('Забронировать столик'),
        ),
      ),
    );
  }

  IconData _featureIcon(String feature) {
    final normalized = feature.toLowerCase();
    if (normalized.contains('wifi')) return Icons.wifi_rounded;
    if (normalized.contains('парк')) return Icons.local_parking_rounded;
    if (normalized.contains('дет')) return Icons.child_care_rounded;
    return Icons.check_circle_outline_rounded;
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.value,
    required this.label,
    this.accent = false,
  });

  final IconData icon;
  final String value;
  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent ? AppColors.accentSoft : AppColors.oliveSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: accent ? AppColors.accent : AppColors.olive,
            size: 25,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(label, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.oliveSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.olive, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
