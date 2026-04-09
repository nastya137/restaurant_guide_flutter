import 'package:flutter/material.dart';

class RestaurantFavourite extends StatefulWidget {
  final int num;
  final bool like;

  const RestaurantFavourite({
    super.key,
    required this.num,
    required this.like,
  });

  @override
  State<RestaurantFavourite> createState() => _RestaurantFavouriteState();
}

class _RestaurantFavouriteState extends State<RestaurantFavourite> {
  late int num;
  late bool like;

  @override
  void initState() {
    super.initState();
    num = widget.num;
    like = widget.like;
  }

  void pressButton() {
    setState(() {
      like = !like;
      like ? num++ : num--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('★ $num'),
        IconButton(
          icon: Icon(like ? Icons.star : Icons.star_border),
          color: Colors.blue[500],
          iconSize: 30,
          onPressed: pressButton,
        ),
      ],
    );
  }
}