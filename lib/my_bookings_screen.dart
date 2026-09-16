import 'package:flutter/material.dart';
import 'package:flutter_project/main.dart';
import 'package:flutter_project/real_restaurant_api.dart';

import 'app_theme.dart';
import 'app_widgets.dart';

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
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final bookings = await widget.api.fetchBookings(widget.userId);
      setState(() {
        _bookings = bookings;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _deleteBooking(String id) async {
    try {
      await widget.api.deleteBooking(id);
      await _loadBookings();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ошибка удаления: $e')));
      }
    }
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        icon: Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(
            color: AppColors.accentSoft,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.event_busy_outlined,
            color: AppColors.accent,
            size: 29,
          ),
        ),
        title: const Text('Отменить бронь?'),
        content: const Text(
          'Бронирование будет удалено. Это действие нельзя отменить.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Оставить'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteBooking(id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              minimumSize: const Size(0, 52),
            ),
            child: const Text('Отменить'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final local = dt.toLocal();
    String pad(int n) => n.toString().padLeft(2, '0');
    return '${pad(local.day)}.${pad(local.month)}.${local.year} · ${pad(local.hour)}:${pad(local.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои брони'),
        actions: [
          IconButton(
            onPressed: _loadBookings,
            tooltip: 'Обновить',
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2.5));
    }

    if (_error != null) {
      return AppStateView(
        icon: Icons.cloud_off_outlined,
        title: 'Не удалось загрузить брони',
        message: 'Попробуйте обновить страницу через несколько секунд.',
        actionLabel: 'Повторить',
        onAction: _loadBookings,
      );
    }

    if (_bookings.isEmpty) {
      return const AppStateView(
        icon: Icons.calendar_month_outlined,
        title: 'Пока нет бронирований',
        message:
            'Выберите ресторан и забронируйте столик — все детали появятся здесь.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      color: AppColors.olive,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        itemCount: _bookings.length + 1,
        separatorBuilder: (context, index) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Предстоящие визиты',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 7),
                  Text(
                    '${_bookings.length} ${_bookingWord(_bookings.length)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          final booking = _bookings[index - 1];
          return _BookingCard(
            booking: booking,
            formattedDate: _formatDateTime(booking.dateTime),
            onDelete: () => _confirmDelete(booking.id),
          );
        },
      ),
    );
  }

  String _bookingWord(int count) {
    final mod100 = count % 100;
    final mod10 = count % 10;
    if (mod100 >= 11 && mod100 <= 14) return 'бронирований';
    if (mod10 == 1) return 'бронирование';
    if (mod10 >= 2 && mod10 <= 4) return 'бронирования';
    return 'бронирований';
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({
    required this.booking,
    required this.formattedDate,
    required this.onDelete,
  });

  final Booking booking;
  final String formattedDate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.olive,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.restaurant_rounded,
                    color: Colors.white,
                    size: 23,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.restaurantName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 5),
                      const Row(
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppColors.oliveSoft,
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              child: Text(
                                'Подтверждено',
                                style: TextStyle(
                                  color: AppColors.olive,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  tooltip: 'Отменить бронь',
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.accentSoft,
                    foregroundColor: AppColors.accent,
                  ),
                  icon: const Icon(Icons.delete_outline_rounded, size: 21),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Divider(),
            const SizedBox(height: 15),
            Wrap(
              spacing: 18,
              runSpacing: 12,
              children: [
                _BookingInfo(
                  icon: Icons.calendar_today_outlined,
                  value: formattedDate,
                ),
                _BookingInfo(
                  icon: Icons.people_outline_rounded,
                  value: '${booking.persons} чел.',
                ),
              ],
            ),
            if (booking.comment.trim().isNotEmpty) ...[
              const SizedBox(height: 15),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  booking.comment,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BookingInfo extends StatelessWidget {
  const _BookingInfo({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 19, color: AppColors.muted),
        const SizedBox(width: 7),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
