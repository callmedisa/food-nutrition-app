import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/user_profile.dart';
import '../services/database_service.dart';

class ProfileScreen extends StatefulWidget {
  final UserProfile? initial;
  final void Function(UserProfile) onSaved;

  const ProfileScreen({super.key, this.initial, required this.onSaved});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _age;
  late final TextEditingController _weight;
  late final TextEditingController _height;
  String _gender = 'male';
  String _activity = 'moderate';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.initial;
    _name = TextEditingController(text: p?.name ?? '');
    _age = TextEditingController(text: p?.age.toString() ?? '');
    _weight = TextEditingController(text: p?.weight.toString() ?? '');
    _height = TextEditingController(text: p?.height.toString() ?? '');
    _gender = p?.gender ?? 'male';
    _activity = p?.activity ?? 'moderate';
  }

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _weight.dispose();
    _height.dispose();
    super.dispose();
  }

  UserProfile _buildProfile() => UserProfile(
    name: _name.text.trim(),
    age: int.parse(_age.text),
    weight: double.parse(_weight.text),
    height: double.parse(_height.text),
    gender: _gender,
    activity: _activity,
  );

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final profile = _buildProfile();
    await DatabaseService.saveProfile(profile);
    widget.onSaved(profile);
    if (mounted) Navigator.of(context).pop();
  }

  int? get _previewCalories {
    try {
      return _buildProfile().calorieGoal;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cal = _previewCalories;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Профиль'),
        backgroundColor: const Color(0xFF4CAF82),
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: const Text('Сохранить', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        onChanged: () => setState(() {}),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (cal != null) _buildCaloriePreview(cal),
            const SizedBox(height: 16),
            _section('Личные данные', [
              _textField(_name, 'Имя', Icons.person_outline, required: true),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _numberField(_age, 'Возраст', 'лет', min: 10, max: 100)),
                const SizedBox(width: 12),
                Expanded(child: _numberField(_weight, 'Вес', 'кг', min: 30, max: 300, decimal: true)),
                const SizedBox(width: 12),
                Expanded(child: _numberField(_height, 'Рост', 'см', min: 100, max: 250, decimal: true)),
              ]),
            ]),
            const SizedBox(height: 16),
            _section('Пол', [
              Row(children: [
                Expanded(child: _genderBtn('male', '♂ Мужской')),
                const SizedBox(width: 12),
                Expanded(child: _genderBtn('female', '♀ Женский')),
              ]),
            ]),
            const SizedBox(height: 16),
            _section('Уровень активности', [
              ...UserProfile.activityLabels.entries.map((e) => _activityTile(e.key, e.value)),
            ]),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildCaloriePreview(int cal) {
    try {
      final p = _buildProfile();
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4CAF82), Color(0xFF2E7D5E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            const Text('Ваша норма калорий', style: TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 4),
            Text('$cal ккал/день', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _macroChip('Белки', '${p.proteinGoal} г', const Color(0xFF5B8BF5)),
                _macroChip('Жиры', '${p.fatGoal} г', const Color(0xFFFF8C42)),
                _macroChip('Углеводы', '${p.carbGoal} г', const Color(0xFFF5C842)),
              ],
            ),
          ],
        ),
      );
    } catch (_) {
      return const SizedBox.shrink();
    }
  }

  Widget _macroChip(String label, String value, Color color) => Column(
    children: [
      Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
    ],
  );

  Widget _section(String title, List<Widget> children) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
        const SizedBox(height: 12),
        ...children,
      ],
    ),
  );

  Widget _textField(TextEditingController ctrl, String label, IconData icon, {bool required = false}) =>
    TextFormField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF4CAF82)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4CAF82)),
        ),
      ),
      validator: required ? (v) => (v == null || v.trim().isEmpty) ? 'Обязательное поле' : null : null,
    );

  Widget _numberField(TextEditingController ctrl, String label, String suffix,
      {required double min, required double max, bool decimal = false}) =>
    TextFormField(
      controller: ctrl,
      keyboardType: decimal ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.allow(decimal ? RegExp(r'[\d.]') : RegExp(r'\d'))],
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4CAF82)),
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Введите';
        final n = double.tryParse(v);
        if (n == null) return 'Число';
        if (n < min || n > max) return '$min–$max';
        return null;
      },
    );

  Widget _genderBtn(String value, String label) {
    final selected = _gender == value;
    return GestureDetector(
      onTap: () => setState(() => _gender = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF4CAF82) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? const Color(0xFF4CAF82) : Colors.grey[300]!),
        ),
        child: Center(
          child: Text(label, style: TextStyle(
            color: selected ? Colors.white : Colors.black54,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          )),
        ),
      ),
    );
  }

  Widget _activityTile(String value, String label) {
    final selected = _activity == value;
    return GestureDetector(
      onTap: () => setState(() => _activity = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF4CAF82).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? const Color(0xFF4CAF82) : Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Icon(selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: selected ? const Color(0xFF4CAF82) : Colors.grey, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: TextStyle(
              color: selected ? const Color(0xFF2E7D5E) : Colors.black87,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            ))),
          ],
        ),
      ),
    );
  }
}
