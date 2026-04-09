import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HttpTestScreen extends StatefulWidget {
  @override
  _HttpTestScreenState createState() => _HttpTestScreenState();
}

class _HttpTestScreenState extends State<HttpTestScreen> {
  int _statusCode = 0;
  String _responseBody = '';
  bool _isLoading = false;

  Future<void> _sendGetRequest() async {
    setState(() => _isLoading = true);

    try {
      final response = await http.get(
        Uri.parse('https://json.flutter.su/echo'),
      );

      setState(() {
        _statusCode = response.statusCode;
        _responseBody = response.body;
      });
    } catch (e) {
      setState(() => _responseBody = 'Ошибка: $e');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _sendPostRequest() async {
    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('https://json.flutter.su/echo'),
        body: {'name': 'test', 'num': '10'},
      );

      setState(() {
        _statusCode = response.statusCode;
        _responseBody = response.body;
      });
    } catch (e) {
      setState(() => _responseBody = 'Ошибка: $e');
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('HTTP тесты')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _sendGetRequest,
              child: Text('GET'),
            ),
            ElevatedButton(
              onPressed: _sendPostRequest,
              child: Text('POST'),
            ),
            if (_isLoading) CircularProgressIndicator(),
            Text('Status: $_statusCode'),
            Expanded(child: SingleChildScrollView(child: Text(_responseBody))),
          ],
        ),
      ),
    );
  }
}
