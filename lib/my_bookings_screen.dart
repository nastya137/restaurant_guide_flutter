import 'package:flutter/material.dart';
import 'package:flutter_project/real_restaurant_api.dart';
import 'package:flutter_project/main.dart';

class MyBookingsScreen extends StatefulWidget {
  final RealRestaurantApi api;
  final int userId;

  const MyBookingsScreen({super.key, required this.api, required this.userId});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  List<Booking> _bookings = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() { _loading = true; _error = null; });
    try {
      final bookings = await widget.api.fetchBookings(widget.userId);
      setState(() { _bookings = bookings; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _deleteBooking(String id) async {
    try {
      await widget.api.deleteBooking(id);
      await _loadBookings();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка удаления: $e')));
      }
    }
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Удалить бронь?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Нет')),
          TextButton(onPressed: () { Navigator.pop(context); _deleteBooking(id); }, child: const Text('Да')),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final local = dt.toLocal();
    String pad(int n) => n.toString().padLeft(2, '0');
    return '${pad(local.day)}.${pad(local.month)}.${local.year} ${pad(local.hour)}:${pad(local.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Мои брони')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Ошибка: $_error'))
          : _bookings.isEmpty
          ? const Center(child: Text('Бронирований нет'))
          : RefreshIndicator(
        onRefresh: _loadBookings,
        child: ListView.builder(
          itemCount: _bookings.length,
          itemBuilder: (context, index) {
            final b = _bookings[index];
            return ListTile(
              title: Text(b.restaurantName),
              subtitle: Text('${_formatDateTime(b.dateTime)} • ${b.persons} чел.'),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _confirmDelete(b.id),
              ),
            );
          },
        ),
      ),
    );
  }
}