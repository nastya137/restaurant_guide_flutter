import 'package:app/screens/async_demo_screen.dart';
import 'package:app/screens/http_test_screen.dart';
import 'package:app/screens/posts_screen.dart';
import 'package:flutter/material.dart';
import 'registration_page.dart';
import 'restaurant_card.dart';
import 'about_page.dart';
import 'restaurant_detail_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Restaurant Booking',
      initialRoute: '/',
      routes: {
        '/': (context) => RegistrationPage(),
        '/restaurants': (context) => RestaurantListPage(),
        '/async': (context) => AsyncDemoScreen(),
        '/http': (context) => HttpTestScreen(),
        '/posts': (context) => PostsScreen(),
        '/about': (context) => AboutPage(),
      },
      onGenerateRoute: (settings) {
        final uri = Uri.parse(settings.name!);

        if (uri.pathSegments.length == 2 && uri.pathSegments[0] == 'restaurant') {
          final id = uri.pathSegments[1];
          return MaterialPageRoute(
            builder: (context) => RestaurantDetailPage(id: id),
          );
        }
        return null;
      },
    );
  }
}

class Restaurant {
  final String title;
  final String description;
  final String? imageUrl;
  final int likes;
  final bool isLiked;

  Restaurant({
    required this.title,
    required this.description,
    this.imageUrl,
    this.likes = 0,
    this.isLiked = false,
  });
}

class RestaurantListPage extends StatelessWidget {
  final List<Restaurant> restaurants = [
    Restaurant(
      title: 'Итальянский дворик',
      description: 'Уютный ресторан с пастой и пиццей.',
      imageUrl: 'https://picsum.photos/200',
      likes: 10,
      isLiked: true,
    ),
    Restaurant(
      title: 'Суши Хаус',
      description: 'Свежие роллы и японская кухня.',
      likes: 5,
    ),
    Restaurant(
      title: 'Русская трапеза',
      description: 'Традиционные блюда русской кухни.',
      imageUrl: 'https://picsum.photos/201',
      likes: 2,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Рестораны')),
      body: ListView.separated(
        itemCount: restaurants.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final item = restaurants[index];
          return RestaurantCard(
            title: item.title,
            text: item.description,
            imageUrl: item.imageUrl,
            num: item.likes,
            like: item.isLiked,
          );
        },
      ),
    );
  }
}