import 'package:flutter/material.dart';
import '../my_popup.dart';

class RestaurantListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Рестораны'),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              Navigator.pushNamed(context, '/about');
            },
          ),
          IconButton(
            icon: Icon(Icons.access_time),
            onPressed: () => Navigator.pushNamed(context, '/async'),
          ),
          IconButton(
            icon: Icon(Icons.http),
            onPressed: () => Navigator.pushNamed(context, '/http'),
          ),
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () => Navigator.pushNamed(context, '/posts'),
          ),
        ],
      ),
      body: Center(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/restaurant/123');
              },
              child: Text('Открыть ресторан ID=123'),
            ),
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  PageRouteBuilder(
                    opaque: false,
                    pageBuilder: (_, __, ___) => MyPopup(),
                    transitionsBuilder: (_, animation, __, child) {
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: animation,
                          child: child,
                        ),
                      );
                    },
                  ),
                );

                if (result != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result ? 'Больше' : 'Меньше'),
                      backgroundColor: result ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
              child: Text('Загадать число'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/about');
              },
              child: Text('О программе'),
            ),
          ],
        ),
      ),
    );
  }
}
