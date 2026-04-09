import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('О программе')),
      body: Center(
        child: Text('Приложение для бронирования ресторанов\nАвтор: https://github.com/nastya137'),
      ),
    );
  }
}