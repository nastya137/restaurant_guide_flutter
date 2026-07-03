import 'package:flutter/material.dart';
import 'package:flutter_project/real_restaurant_api.dart';
import 'booking_screen.dart';
import 'main.dart';

class RestaurantDetailScreen extends StatelessWidget {
  final Restaurant restaurant;
  final RealRestaurantApi api;
  final int userId;


  RestaurantDetailScreen({
    super.key,
    required this.restaurant,
    required this.api,
    required this.userId,
  }) {
    debugPrint("DETAIL SCREEN LOADED WITH BOOKING REPO");
  }

  Widget _buildReview(String author, int rating, String text) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(author, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 12),
                Text('⭐' * rating), // звёзды
              ],
            ),
            const SizedBox(height: 6),
            Text(text),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(restaurant.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(restaurant.photoUrl),
          ),
          const SizedBox(height: 16),

          Text(
            restaurant.name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),
          Text('⭐ ${restaurant.rating} • ${restaurant.cuisine}'),

          const SizedBox(height: 8),
          Text('Средний чек: ${restaurant.averageCheck} ₽'),

          const SizedBox(height: 16),
          Text(restaurant.description),

          const SizedBox(height: 16),
          Text('Адрес: ${restaurant.address}'),
          Text('Телефон: ${restaurant.phone}'),

          const SizedBox(height: 24),

          Wrap(
            spacing: 8,
            children: restaurant.features
                .map((f) => Chip(label: Text(f)))
                .toList(),
          ),
          const SizedBox(height: 24),
          const Text(
            'Отзывы',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
// Статические примеры отзывов
          _buildReview('Анна', 5, 'Отличное место! Очень вкусная паста и приятная атмосфера.'),
          const SizedBox(height: 8),
          _buildReview('Максим', 4, 'Хороший ресторан, но долго ждали заказ.'),
          const SizedBox(height: 8),
          _buildReview('Ольга', 5, 'Лучший ресторан в городе! Рекомендую десерты.'),
          const SizedBox(height: 30),

          ElevatedButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BookingScreen(
                    restaurant: restaurant,
                    api: api,
                    userId: userId,
                  ),
                ),
              );
              if (result != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Бронь успешно создана')),
                );
              }
            },
            child: const Text('Забронировать столик'),
          ),
        ],
      ),
    );
  }
}

