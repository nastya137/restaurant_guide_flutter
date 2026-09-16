import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'app_widgets.dart';
import 'main.dart';

class FilterScreen extends StatefulWidget {
  final RestaurantFilter filter;

  const FilterScreen({super.key, required this.filter});

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
          TextButton(onPressed: _reset, child: const Text('Сбросить')),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        physics: const BouncingScrollPhysics(),
        children: [
          const SectionTitle('Кухня'),
          const SizedBox(height: 6),
          Text(
            'Выберите направление, которое хочется сегодня.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 9,
            runSpacing: 9,
            children: _cuisines.map((cuisine) {
              final selected = cuisine == _cuisine;
              return ChoiceChip(
                label: Text(cuisine),
                selected: selected,
                showCheckmark: false,
                avatar: selected
                    ? const Icon(
                        Icons.check_rounded,
                        size: 18,
                        color: AppColors.olive,
                      )
                    : null,
                onSelected: (_) {
                  setState(() {
                    _cuisine = cuisine;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          const SectionTitle('Удобства'),
          const SizedBox(height: 14),
          Card(
            child: Column(
              children: [
                _FilterToggleTile(
                  icon: Icons.wifi_rounded,
                  title: 'Wi-Fi',
                  subtitle: 'Беспроводной интернет для гостей',
                  value: _wifi,
                  onChanged: (value) => setState(() => _wifi = value),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 68),
                  child: Divider(),
                ),
                _FilterToggleTile(
                  icon: Icons.local_parking_rounded,
                  title: 'Парковка',
                  subtitle: 'Можно приехать на автомобиле',
                  value: _parking,
                  onChanged: (value) => setState(() => _parking = value),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 68),
                  child: Divider(),
                ),
                _FilterToggleTile(
                  icon: Icons.child_care_rounded,
                  title: 'Детское меню',
                  subtitle: 'Подойдёт для семейного ужина',
                  value: _kidsMenu,
                  onChanged: (value) => setState(() => _kidsMenu = value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const SectionTitle('Средний чек'),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _PriceLabel(
                          caption: 'От',
                          value: '${_range.start.round()} ₽',
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          color: AppColors.muted,
                          size: 20,
                        ),
                      ),
                      Expanded(
                        child: _PriceLabel(
                          caption: 'До',
                          value: '${_range.end.round()} ₽',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  RangeSlider(
                    values: _range,
                    min: 0,
                    max: 5000,
                    divisions: 10,
                    labels: RangeLabels(
                      '${_range.start.round()} ₽',
                      '${_range.end.round()} ₽',
                    ),
                    onChanged: (value) {
                      setState(() {
                        _range = value;
                      });
                    },
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '0 ₽',
                        style: TextStyle(color: AppColors.muted, fontSize: 12),
                      ),
                      Text(
                        '5 000 ₽',
                        style: TextStyle(color: AppColors.muted, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          12 + MediaQuery.paddingOf(context).bottom,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.outline)),
        ),
        child: ElevatedButton.icon(
          onPressed: _apply,
          icon: const Icon(Icons.check_rounded),
          label: const Text('Показать рестораны'),
        ),
      ),
    );
  }
}

class _FilterToggleTile extends StatelessWidget {
  const _FilterToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: value,
      onChanged: (newValue) => onChanged(newValue ?? false),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      secondary: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.oliveSoft,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Icon(icon, color: AppColors.olive, size: 21),
      ),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}

class _PriceLabel extends StatelessWidget {
  const _PriceLabel({required this.caption, required this.value});

  final String caption;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(caption, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 2),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
