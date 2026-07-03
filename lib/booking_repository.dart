import 'dart:async';
import 'main.dart';

class BookingRepository {
  final List<Booking> _storage = [];

  Future<List<Booking>> getBookings() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.from(_storage);
  }

  Future<Booking> addBooking(Booking booking) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _storage.add(booking);
    return booking;
  }

  Future<bool> deleteBooking(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _storage.removeWhere((b) => b.id == id);
    return true;
  }
}
