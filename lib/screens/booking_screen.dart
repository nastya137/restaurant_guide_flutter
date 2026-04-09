import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  List<dynamic> _bookings = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // ЗАГЛУШКА API (замени на свой backend при наличии)
      final response = await http.get(
        Uri.parse('https://json.flutter.su/echo'),
      );

      if (response.statusCode == 200) {
        // имитация списка броней
        final data = jsonDecode(response.body);

        setState(() {
          _bookings = [
            {
              "id": 1,
              "restaurant": "Tokyo Sushi",
              "date": "2026-04-10",
              "time": "18:00"
            },
            {
              "id": 2,
              "restaurant": "Italiano",
              "date": "2026-04-11",
              "time": "20:00"
            }
          ];
          _isLoading = false;
        });
      } else {
        throw Exception("Ошибка загрузки");
      }
    } catch (e) {
      setState(() {
        _error = "Ошибка загрузки данных";
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteBooking(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('https://json.flutter.su/echo'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _bookings.removeWhere((b) => b['id'] == id);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Бронь отменена")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ошибка удаления")),
      );
    }
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Отмена бронирования"),
        content: const Text("Вы уверены, что хотите отменить бронь?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Нет"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteBooking(id);
            },
            child: const Text("Да"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Мои брони")),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())

          : _error != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _fetchBookings,
              child: const Text("Повторить"),
            )
          ],
        ),
      )

          : _bookings.isEmpty
          ? const Center(child: Text("Бронирований нет"))

          : ListView.builder(
        itemCount: _bookings.length,
        itemBuilder: (context, index) {
          final booking = _bookings[index];

          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text(booking['restaurant']),
              subtitle: Text(
                "${booking['date']} • ${booking['time']}",
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () =>
                    _confirmDelete(booking['id']),
              ),
            ),
          );
        },
      ),
    );
  }
}

