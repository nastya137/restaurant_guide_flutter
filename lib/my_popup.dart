import 'package:flutter/material.dart';

class MyPopup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: AlertDialog(
        title: Text('Ваш ответ:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Больше'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Меньше'),
          ),
        ],
      ),
    );
  }
}