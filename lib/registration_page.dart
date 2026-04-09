import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'main.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _agreement = false;

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите email';
    }
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!regex.hasMatch(value)) {
      return 'Некорректный email';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите телефон';
    }
    if (value.length < 16) {
      return 'Введите номер полностью';
    }
    return null;
  }


  void submit() {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreement) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Нужно согласие на обработку данных')),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantListPage(),
      ),
    );
  }


  void reset() {
    _formKey.currentState!.reset();
    setState(() {
      _agreement = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Регистрация')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Имя', style: TextStyle(fontSize: 18)),
              TextFormField(
                controller: _nameController,
                validator: (v) =>
                v == null || v.isEmpty ? 'Введите имя' : null,
              ),
              const SizedBox(height: 20),

              const Text('Email', style: TextStyle(fontSize: 18)),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: validateEmail,
              ),
              const SizedBox(height: 20),

              const Text('Телефон', style: TextStyle(fontSize: 18)),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  PhoneInputFormatter(),
                ],
                decoration: const InputDecoration(
                  hintText: '+7-XXX-XXX-XX-XX',
                ),
                validator: validatePhone,
              ),
              const SizedBox(height: 20),

              CheckboxListTile(
                value: _agreement,
                title: const Text('Согласие на обработку данных'),
                onChanged: (value) {
                  setState(() {
                    _agreement = value ?? false;
                  });
                },
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  ElevatedButton(
                    onPressed: submit,
                    child: const Text('Зарегистрироваться'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: reset,
                    child: const Text('Сброс'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
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
    if (digits.startsWith('7')) {
      digits = digits.substring(1);
    }
    if (digits.length > 10) {
      digits = digits.substring(0, 10);
    }

    String formatted = '+7';

    if (digits.isNotEmpty) formatted += '-${digits.substring(0, digits.length.clamp(0, 3))}';
    if (digits.length > 3) formatted += '-${digits.substring(3, digits.length.clamp(3, 6))}';
    if (digits.length > 6) formatted += '-${digits.substring(6, digits.length.clamp(6, 8))}';
    if (digits.length > 8) formatted += '-${digits.substring(8, digits.length.clamp(8, 10))}';

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
