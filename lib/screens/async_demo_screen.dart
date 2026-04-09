import 'package:flutter/material.dart';

class SandGlass {
  int _sand = 0;

  int time() => _sand;

  Future<void> tick() async {
    _sand = 100;
    while (_sand > 0) {
      await Future.delayed(const Duration(milliseconds: 100));
      _sand--;
      print('Sand: $_sand');
    }
  }
}
class AsyncDemoScreen extends StatefulWidget {
  @override
  _AsyncDemoScreenState createState() => _AsyncDemoScreenState();
}

class _AsyncDemoScreenState extends State<AsyncDemoScreen> {
  SandGlass clock = SandGlass();

  @override
  void initState() {
    super.initState();
    clock.tick();
  }

  Future<void> _reDrawWidget() async {
    while (clock.time() > 0) {
      await Future.delayed(const Duration(seconds: 1));
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    _reDrawWidget();

    return Scaffold(
      appBar: AppBar(title: Text('Асинхронность')),
      body: Center(
        child: Text(
          'Осталось: ${clock.time()}',
          style: TextStyle(fontSize: 30),
        ),
      ),
    );
  }
}
