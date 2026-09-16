import 'dart:convert';
import 'package:http/http.dart' as http;
import 'main.dart'; // для моделей Restaurant, Booking

class RealRestaurantApi {
  final String baseUrl;
  final http.Client client;

  RealRestaurantApi({required this.baseUrl, http.Client? client})
      : client = client ?? http.Client();

  // 1. Получить все рестораны
  Future<List<Restaurant>> fetchRestaurants() async {
    final response = await client.get(Uri.parse('$baseUrl/restaraunts'));
    if (response.statusCode != 200) throw Exception('Ошибка загрузки ресторанов');
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Restaurant.fromJson(json)).toList();
  }

  // 2. Создать бронь
  Future<Booking> createBooking({
    required Restaurant restaurant,
    required DateTime dateTime,
    required int persons,
    required String comment,
    required int userId,
  }) async {
    final response = await client.post(
      Uri.parse('$baseUrl/bookings'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'restaurantId': restaurant.id,
        'restaurantName': restaurant.name,
        'dateTime': dateTime.toUtc().toIso8601String(),
        'persons': persons,
        'comment': comment,
        'userId': userId,
      }),
    );
    if (response.statusCode != 201) throw Exception('Не удалось создать бронь');
    return Booking.fromJson(jsonDecode(response.body));
  }

  // 3. Получить брони пользователя
  Future<List<Booking>> fetchBookings(int userId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/bookings?userId=$userId'),
    );
    if (response.statusCode != 200) throw Exception('Ошибка загрузки броней');
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Booking.fromJson(json)).toList();
  }

  // 4. Удалить бронь
  Future<bool> deleteBooking(String bookingId) async {
    final response = await client.delete(
      Uri.parse('$baseUrl/bookings/$bookingId'),
    );
    if (response.statusCode != 200) throw Exception('Не удалось удалить');
    return true;
  }
}
