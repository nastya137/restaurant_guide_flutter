import 'package:flutter/material.dart';
import 'main.dart';
import 'restaurant_list_screen.dart';

class FilterScreen extends StatefulWidget {
  final RestaurantFilter filter;

  const FilterScreen({
    super.key,
    required this.filter,
  });

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late String _cuisine;
  late bool _wifi;
  late bool _parking;
  late bool _kidsMenu;
  late RangeValues _range;

  final List<String> _cuisines = [
    'Все',
    'Итальянская',
    'Японская',
    'Русская',
    'Вегетарианская',
  ];

  @override
  void initState() {
    super.initState();
    _cuisine = widget.filter.cuisine;
    _wifi = widget.filter.wifi;
    _parking = widget.filter.parking;
    _kidsMenu = widget.filter.kidsMenu;
    _range = widget.filter.averageCheckRange;
  }

  void _apply() {
    final result = RestaurantFilter(
      cuisine: _cuisine,
      wifi: _wifi,
      parking: _parking,
      kidsMenu: _kidsMenu,
      averageCheckRange: _range,
    );

    Navigator.pop(context, result);
  }

  void _reset() {
    setState(() {
      _cuisine = RestaurantFilter.defaults.cuisine;
      _wifi = false;
      _parking = false;
      _kidsMenu = false;
      _range = RestaurantFilter.defaults.averageCheckRange;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Фильтры'),
        actions: [
          TextButton(
            onPressed: _reset,
            child: const Text('Сброс'),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Кухня',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          ..._cuisines.map((c) {
            return RadioListTile<String>(
              title: Text(c),
              value: c,
              groupValue: _cuisine,
              onChanged: (value) {
                setState(() {
                  _cuisine = value!;
                });
              },
            );
          }),

          const Divider(),

          const Text(
            'Дополнительно',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          CheckboxListTile(
            title: const Text('WiFi'),
            value: _wifi,
            onChanged: (v) => setState(() => _wifi = v ?? false),
          ),

          CheckboxListTile(
            title: const Text('Парковка'),
            value: _parking,
            onChanged: (v) => setState(() => _parking = v ?? false),
          ),

          CheckboxListTile(
            title: const Text('Детское меню'),
            value: _kidsMenu,
            onChanged: (v) => setState(() => _kidsMenu = v ?? false),
          ),

          const Divider(),

          const Text(
            'Средний чек',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          RangeSlider(
            values: _range,
            min: 0,
            max: 5000,
            divisions: 10,
            labels: RangeLabels(
              '${_range.start.round()}₽',
              '${_range.end.round()}₽',
            ),
            onChanged: (v) {
              setState(() {
                _range = v;
              });
            },
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: _apply,
            child: const Text('Применить'),
          ),
        ],
      ),
    );
  }
}
