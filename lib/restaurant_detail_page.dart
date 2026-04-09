import 'package:app/screens/booking_screen.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class RestaurantDetailPage extends StatelessWidget {
  final String id;

  RestaurantDetailPage({required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ресторан $id')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Детальная информация о ресторане $id'),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Назад'),
            ),
            ElevatedButton(
              onPressed: () {
                final random = Random().nextInt(100) + 1;
                Navigator.pop(context, random);
              },
              child: Text('Отправить результат'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookingScreen(restaurantId: restaurant.id),
                  ),
                );
              },
              child: const Text("Забронировать столик"),
            )
          ],
        ),
      ),
    );
  }
}