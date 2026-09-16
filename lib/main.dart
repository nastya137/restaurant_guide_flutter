import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_project/app_theme.dart';
import 'package:flutter_project/real_restaurant_api.dart';
import 'package:flutter_project/restaurant_list_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const RestaurantGuideApp());
}

class RestaurantGuideApp extends StatelessWidget {
  const RestaurantGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ресторанный гид',
      theme: AppTheme.light,
      home: const RegistrationScreen(),
    );
  }
}

class Restaurant {
  final String id;
  final String name;
  final String photoUrl;
  final double rating;
  final String cuisine;
  final List<String> features;
  final int averageCheck;
  final String description;
  final String address;
  final String phone;

  const Restaurant({
    required this.id,
    required this.name,
    required this.photoUrl,
    required this.rating,
    required this.cuisine,
    required this.features,
    required this.averageCheck,
    required this.description,
    required this.address,
    required this.phone,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] as String,
      name: json['name'] as String,
      photoUrl: json['photoUrl'] as String,
      rating: (json['rating'] as num).toDouble(),
      cuisine: json['cuisine'] as String,
      features: List<String>.from(json['features'] as List),
      averageCheck: json['averageCheck'] as int,
      description: json['description'] as String,
      address: json['address'] as String,
      phone: json['phone'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'photoUrl': photoUrl,
    'rating': rating,
    'cuisine': cuisine,
    'features': features,
    'averageCheck': averageCheck,
    'description': description,
    'address': address,
    'phone': phone,
  };
}

class Booking {
  final String id;
  final String restaurantId;
  final String restaurantName;
  final DateTime dateTime;
  final int persons;
  final String comment;

  const Booking({
    required this.id,
    required this.restaurantId,
    required this.restaurantName,
    required this.dateTime,
    required this.persons,
    required this.comment,
  });

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
    id: json['id'] as String,
    restaurantId: json['restaurantId'] as String,
    restaurantName: json['restaurantName'] as String,
    dateTime: DateTime.parse(json['dateTime'] as String),
    persons: json['persons'] as int,
    comment: json['comment'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'restaurantId': restaurantId,
    'restaurantName': restaurantName,
    'dateTime': dateTime.toIso8601String(),
    'persons': persons,
    'comment': comment,
  };
}

class RestaurantFilter {
  final String cuisine;
  final bool wifi;
  final bool parking;
  final bool kidsMenu;
  final RangeValues averageCheckRange;

  const RestaurantFilter({
    required this.cuisine,
    required this.wifi,
    required this.parking,
    required this.kidsMenu,
    required this.averageCheckRange,
  });

  RestaurantFilter copyWith({
    String? cuisine,
    bool? wifi,
    bool? parking,
    bool? kidsMenu,
    RangeValues? averageCheckRange,
  }) {
    return RestaurantFilter(
      cuisine: cuisine ?? this.cuisine,
      wifi: wifi ?? this.wifi,
      parking: parking ?? this.parking,
      kidsMenu: kidsMenu ?? this.kidsMenu,
      averageCheckRange: averageCheckRange ?? this.averageCheckRange,
    );
  }

  static const defaults = RestaurantFilter(
    cuisine: 'Все',
    wifi: false,
    parking: false,
    kidsMenu: false,
    averageCheckRange: RangeValues(0, 5000),
  );
}

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  bool _consent = false;

  late RealRestaurantApi _api;
  late Future<void> _init;

  @override
  void initState() {
    super.initState();
    _init = _initApiAndUser();
  }

  Future<void> _initApiAndUser() async {
    final baseUrl = dotenv.env['BASE_URL'];
    if (baseUrl == null) throw Exception('BASE_URL not set in .env');
    _api = RealRestaurantApi(baseUrl: baseUrl);
  }

  Future<int> _getOrCreateUserId(
    String name,
    String phone,
    String email,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId');
    if (userId == null) {
      final digitsOnly = phone.replaceAll(RegExp(r'\D'), '');
      if (digitsOnly.length >= 10) {
        final localDigits = digitsOnly.substring(1);
        userId = int.tryParse(localDigits) ?? 0;
      } else {
        userId = 0;
      }
      await prefs.setInt('userId', userId);
    }
    return userId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите телефон';
    }

    final reg = RegExp(r'^\+7-\d{3}-\d{3}-\d{2}-\d{2}$');

    if (!reg.hasMatch(value)) {
      return 'Введите номер полностью';
    }

    return null;
  }

  String? _validateEmail(String? value) {
    final v = value?.trim() ?? '';
    final reg = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

    if (v.isEmpty) return 'Введите email';
    if (!reg.hasMatch(v)) return 'Некорректный email';

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _init,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _BrandMark(size: 72),
                  SizedBox(height: 24),
                  CircularProgressIndicator(strokeWidth: 2.5),
                ],
              ),
            ),
          );
        }
        return Scaffold(
          body: Stack(
            children: [
              const Positioned(
                right: -82,
                top: -86,
                child: _DecorativeCircle(size: 236, color: AppColors.oliveSoft),
              ),
              const Positioned(
                left: -54,
                top: 198,
                child: _DecorativeCircle(
                  size: 118,
                  color: AppColors.accentSoft,
                ),
              ),
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 26, 24, 32),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 520),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    _BrandMark(size: 48),
                                    SizedBox(width: 12),
                                    Text(
                                      'TABLE',
                                      style: TextStyle(
                                        color: AppColors.olive,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 2.2,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 54),
                                Text(
                                  'Ваш столик уже\nгде-то ждёт',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.displaySmall,
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  'Откройте лучшие места города и бронируйте их за пару касаний.',
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(color: AppColors.muted),
                                ),
                                const SizedBox(height: 30),
                                Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Давайте знакомиться',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleLarge,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Заполните данные, чтобы управлять своими бронями.',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                        ),
                                        const SizedBox(height: 22),
                                        TextFormField(
                                          controller: _nameController,
                                          textCapitalization:
                                              TextCapitalization.words,
                                          textInputAction: TextInputAction.next,
                                          decoration: const InputDecoration(
                                            labelText: 'Имя',
                                            hintText: 'Как к вам обращаться?',
                                            prefixIcon: Icon(
                                              Icons.person_outline_rounded,
                                            ),
                                          ),
                                          validator: (v) =>
                                              v == null || v.trim().isEmpty
                                              ? 'Введите имя'
                                              : null,
                                        ),
                                        const SizedBox(height: 14),
                                        TextFormField(
                                          controller: _phoneController,
                                          keyboardType: TextInputType.phone,
                                          textInputAction: TextInputAction.next,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                            PhoneInputFormatter(),
                                          ],
                                          decoration: const InputDecoration(
                                            labelText: 'Телефон',
                                            hintText: '+7-XXX-XXX-XX-XX',
                                            prefixIcon: Icon(
                                              Icons.phone_outlined,
                                            ),
                                          ),
                                          validator: validatePhone,
                                        ),
                                        const SizedBox(height: 14),
                                        TextFormField(
                                          controller: _emailController,
                                          decoration: const InputDecoration(
                                            labelText: 'Email',
                                            hintText: 'name@example.com',
                                            prefixIcon: Icon(
                                              Icons.alternate_email_rounded,
                                            ),
                                          ),
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          textInputAction: TextInputAction.done,
                                          validator: _validateEmail,
                                        ),
                                        const SizedBox(height: 12),
                                        CheckboxListTile(
                                          value: _consent,
                                          onChanged: (v) {
                                            setState(() {
                                              _consent = v ?? false;
                                            });
                                          },
                                          title: const Text(
                                            'Согласен на обработку данных',
                                          ),
                                          subtitle: const Text(
                                            'Данные нужны только для бронирования',
                                          ),
                                          contentPadding: EdgeInsets.zero,
                                          controlAffinity:
                                              ListTileControlAffinity.leading,
                                        ),
                                        const SizedBox(height: 12),
                                        ElevatedButton.icon(
                                          onPressed: () async {
                                            if (!_formKey.currentState!
                                                .validate()) {
                                              return;
                                            }
                                            if (!_consent) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Нужно дать согласие',
                                                  ),
                                                ),
                                              );
                                              return;
                                            }
                                            final userId =
                                                await _getOrCreateUserId(
                                                  _nameController.text.trim(),
                                                  _phoneController.text.trim(),
                                                  _emailController.text.trim(),
                                                );
                                            if (!context.mounted) return;
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    RestaurantListScreen(
                                                      api: _api,
                                                      userName: _nameController
                                                          .text
                                                          .trim(),
                                                      userId: userId,
                                                    ),
                                              ),
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.arrow_forward_rounded,
                                          ),
                                          label: const Text('Найти ресторан'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.olive,
        borderRadius: BorderRadius.circular(size * .32),
        boxShadow: const [
          BoxShadow(
            color: Color(0x24344638),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Icon(
        Icons.restaurant_menu_rounded,
        size: size * .5,
        color: Colors.white,
      ),
    );
  }
}

class _DecorativeCircle extends StatelessWidget {
  const _DecorativeCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    // убираем ведущую 7 или 8 (частый кейс)
    if (digits.startsWith('7') || digits.startsWith('8')) {
      digits = digits.substring(1);
    }

    if (digits.length > 10) {
      digits = digits.substring(0, 10);
    }

    final buffer = StringBuffer('+7');

    if (digits.isNotEmpty) {
      buffer.write('-${digits.substring(0, digits.length.clamp(0, 3))}');
    }
    if (digits.length > 3) {
      buffer.write('-${digits.substring(3, digits.length.clamp(3, 6))}');
    }
    if (digits.length > 6) {
      buffer.write('-${digits.substring(6, digits.length.clamp(6, 8))}');
    }
    if (digits.length > 8) {
      buffer.write('-${digits.substring(8, digits.length.clamp(8, 10))}');
    }

    final result = buffer.toString();

    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }
}
