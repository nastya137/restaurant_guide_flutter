import 'package:flutter/material.dart';
import 'package:flutter_project/real_restaurant_api.dart';
import 'main.dart';

class BookingScreen extends StatefulWidget {
  final Restaurant restaurant;
  final RealRestaurantApi api;
  final int userId;


  const BookingScreen({
    super.key,
    required this.restaurant,
    required this.api,
    required this.userId
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen>
    with SingleTickerProviderStateMixin {
  DateTime? _date;
  TimeOfDay? _time;
  final _personsController = TextEditingController();
  final _commentController = TextEditingController();

  bool _loading = false;

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scale = Tween(begin: 0.8, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    _personsController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
      initialDate: now,
    );

    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );

    if (picked != null) {
      setState(() => _time = picked);
    }
  }

  Future<void> _submit() async {
    if (_date == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, выберите дату')),
      );
      return;
    }
    if (_time == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, выберите время')),
      );
      return;
    }
    if (_time!.hour < 9 || _time!.hour >= 22) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Бронирование доступно с 9:00 до 22:00'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    final persons = int.tryParse(_personsController.text) ?? 1;
    final dateTime = DateTime(
      _date!.year,
      _date!.month,
      _date!.day,
      _time!.hour,
      _time!.minute,
    );

    setState(() => _loading = true);

    try {
      final booking = await widget.api.createBooking(
        restaurant: widget.restaurant,
        dateTime: dateTime,
        persons: persons,
        comment: _commentController.text,
        userId: widget.userId
      );
      setState(() => _loading = false);
      await _controller.forward();
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (_) => ScaleTransition(
          scale: _scale,
          child: FadeTransition(
            opacity: _fade,
            child: AlertDialog(
              title: const Text('Успешно!'),
              content: const Text('Бронь создана'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);          // закрыть диалог
                    Navigator.pop(context, booking); // вернуть бронь на предыдущий экран
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      setState(() => _loading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _date != null &&
        _time != null &&
        _personsController.text.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Бронирование')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(widget.restaurant.name,
              style: const TextStyle(fontSize: 20)),

          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: _pickDate,
            child: Text(_date == null
                ? 'Выбрать дату'
                : _date.toString().split(' ')[0]),
          ),

          ElevatedButton(
            onPressed: _pickTime,
            child: Text(_time == null
                ? 'Выбрать время'
                : _time!.format(context)),
          ),

          TextField(
            controller: _personsController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Количество персон'),
          ),

          TextField(
            controller: _commentController,
            decoration: const InputDecoration(labelText: 'Комментарий'),
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: canSubmit && !_loading ? _submit : null,
            child: _loading
                ? const CircularProgressIndicator()
                : const Text('Забронировать'),
          ),
        ],
      ),
    );
  }
}
