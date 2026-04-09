import 'package:flutter/material.dart';
import 'restaurant_favourite.dart';

class RestaurantCard extends StatelessWidget {
  final String title;
  final String text;
  final String? imageUrl;
  final int num;
  final bool like;

  const RestaurantCard({
    super.key,
    required this.title,
    required this.text,
    this.imageUrl,
    this.num = 0,
    this.like = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      color: Colors.black12,
      child: Row(
        children: [
          if (imageUrl != null)
            Image.network(imageUrl!, width: 100, height: 100, fit: BoxFit.cover),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          RestaurantFavourite(num: num, like: like),
        ],
      ),
    );
  }
}
