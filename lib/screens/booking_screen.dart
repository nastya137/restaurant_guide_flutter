import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BookingScreen extends StatefulWidget {
  final int restaurantId;

  const BookingScreen({super.key, required this.restaurantId});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final TextEditingController _peopleController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  bool _isLoading = false;

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: DateTime.now(),
    );

    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  bool _validateBusinessRules() {
    if (_selectedDate == null || _selectedTime == null) return false;

    final now = DateTime.now();
    final selectedDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    // дата не раньше сегодня
    if (selectedDateTime.isBefore(now)) return false;

    // рабочие часы: 10:00 - 22:00
    if (_selectedTime!.hour < 10 || _selectedTime!.hour > 22) {
      return false;
    }

    return true;
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_validateBusinessRules()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Проверьте дату и время")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('https://json.flutter.su/echo'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "restaurantId": widget.restaurantId,
          "date": _selectedDate.toString(),
          "time": _selectedTime.toString(),
          "people": _peopleController.text,
          "comment": _commentController.text,
        }),
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        _showSuccessDialog();
      } else {
        throw Exception("Server error");
      }
    } catch (e) {
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ошибка бронирования")),
      );
    }
  }

  void _showSuccessDialog() {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        pageBuilder: (_, __, ___) => const _SuccessDialog(),
        transitionsBuilder: (_, animation, __, child) {
          final fade = Tween(begin: 0.0, end: 1.0).animate(animation);
          final scale = Tween(begin: 0.5, end: 1.0).animate(animation);

          return FadeTransition(
            opacity: fade,
            child: ScaleTransition(scale: scale, child: child),
          );
        },
      ),
    ).then((_) {
      Navigator.pop(context, true); // возврат на список ресторанов
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Бронирование")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              title: Text(_selectedDate == null
                  ? "Выберите дату"
                  : _selectedDate.toString()),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),

            ListTile(
              title: Text(_selectedTime == null
                  ? "Выберите время"
                  : _selectedTime!.format(context)),
              trailing: const Icon(Icons.access_time),
              onTap: _pickTime,
            ),

            TextFormField(
              controller: _peopleController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Количество персон"),
              validator: (v) =>
              (v == null || v.isEmpty) ? "Введите количество" : null,
            ),

            TextFormField(
              controller: _commentController,
              decoration: const InputDecoration(labelText: "Комментарий"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _isLoading ? null : _submitBooking,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Забронировать"),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessDialog extends StatelessWidget {
  const _SuccessDialog();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Бронирование успешно!",
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
