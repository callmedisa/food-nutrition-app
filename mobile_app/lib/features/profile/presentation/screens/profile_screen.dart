import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_nutrition_app/l10n/app_localizations.dart';
import '../../../../providers.dart';
import '../../domain/entities/user_profile.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _age;
  late final TextEditingController _weight;
  late final TextEditingController _height;
  String _gender   = 'male';
  String _activity = 'moderate';
  bool _saving = false;
  bool _initialized = false;

  @override
  void dispose() {
    if (_initialized) {
      _name.dispose();
      _age.dispose();
      _weight.dispose();
      _height.dispose();
    }
    super.dispose();
  }

  void _initFromProfile(UserProfile? p) {
    if (_initialized) return;
    _name    = TextEditingController(text: p?.name     ?? '');
    _age     = TextEditingController(text: p?.age.toString()    ?? '');
    _weight  = TextEditingController(text: p?.weight.toString() ?? '');
    _height  = TextEditingController(text: p?.height.toString() ?? '');
    _gender  = p?.gender   ?? 'male';
    _activity = p?.activity ?? 'moderate';
    _initialized = true;
  }

  UserProfile? _buildProfile() {
    try {
      return UserProfile(
        name: _name.text.trim(),
        age: int.parse(_age.text),
        weight: double.parse(_weight.text),
        height: double.parse(_height.text),
        gender: _gender,
        activity: _activity,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final p = _buildProfile();
    if (p == null) return;
    setState(() => _saving = true);
    await ref.read(profileNotifierProvider.notifier).saveProfile(p);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileNotifierProvider);
    final l = AppLocalizations.of(context)!;
    final localeAsync = ref.watch(localeNotifierProvider);
    final currentLangCode = localeAsync.valueOrNull?.languageCode ?? 'ru';

    return profileAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFF4CAF82)))),
      error: (e, _) => Scaffold(body: Center(child: Text(e.toString()))),
      data: (profile) {
        _initFromProfile(profile);
        final preview = _buildProfile()?.calorieGoal;
        return Scaffold(
          appBar: AppBar(
            title: Text(l.profileTitle),
            backgroundColor: const Color(0xFF4CAF82),
            foregroundColor: Colors.white,
            actions: [
              TextButton(
                onPressed: _saving ? null : _save,
                child: Text(l.profileSave, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          body: Form(
            key: _formKey,
            onChanged: () => setState(() {}),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (preview != null) _buildCaloriePreview(preview, l),
                const SizedBox(height: 16),
                _section(l.profilePersonal, [
                  _textField(_name, l.profileName, Icons.person_outline, required: true, l: l),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: _numField(_age,    l.profileAge,    Icons.cake_outlined, l: l)),
                    const SizedBox(width: 12),
                    Expanded(child: _numField(_weight, l.profileWeight, Icons.monitor_weight_outlined, decimal: true, l: l)),
                    const SizedBox(width: 12),
                    Expanded(child: _numField(_height, l.profileHeight, Icons.height,                  decimal: true, l: l)),
                  ]),
                  const SizedBox(height: 12),
                  _genderRow(l),
                ]),
                const SizedBox(height: 12),
                _section(l.profileActivity, [_activityDropdown(l)]),
                const SizedBox(height: 16),
                // ── Language switcher (LocaleNotifier) ─────────────────────
                _section(l.settingsLanguage, [
                  Row(children: [
                    _langBtn('RU', 'ru', currentLangCode),
                    const SizedBox(width: 8),
                    _langBtn('ҚАЗ', 'kk', currentLangCode),
                    const SizedBox(width: 8),
                    _langBtn('EN',  'en', currentLangCode),
                  ]),
                ]),
                const SizedBox(height: 80),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCaloriePreview(int cal, AppLocalizations l) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [Color(0xFF4CAF82), Color(0xFF2E7D5E)],
          begin: Alignment.topLeft, end: Alignment.bottomRight),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(children: [
      const Icon(Icons.local_fire_department, color: Colors.white, size: 32),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l.profileCalorieGoal, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        Text('$cal ${l.labelKcal}',
            style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
      ]),
    ]),
  );

  Widget _section(String title, List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
        ),
        child: Column(children: children),
      ),
    ],
  );

  Widget _textField(TextEditingController ctrl, String label, IconData icon, {required bool required, required AppLocalizations l}) {
    return TextFormField(
      controller: ctrl,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon), border: const OutlineInputBorder()),
      validator: required ? (v) => (v == null || v.trim().isEmpty) ? l.validRequired : null : null,
    );
  }

  Widget _numField(TextEditingController ctrl, String label, IconData icon, {bool decimal = false, required AppLocalizations l}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: decimal ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(decimal ? r'\d+\.?\d*' : r'\d+'))],
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon), border: const OutlineInputBorder()),
      validator: (v) {
        if (v == null || v.isEmpty) return l.validRequired;
        final n = double.tryParse(v);
        if (n == null || n <= 0) return l.validPositive;
        return null;
      },
    );
  }

  Widget _genderRow(AppLocalizations l) => Row(children: [
    Expanded(child: _genderBtn(l.profileMale,   'male')),
    const SizedBox(width: 8),
    Expanded(child: _genderBtn(l.profileFemale, 'female')),
  ]);

  Widget _genderBtn(String label, String value) {
    final selected = _gender == value;
    return OutlinedButton(
      onPressed: () => setState(() => _gender = value),
      style: OutlinedButton.styleFrom(
        backgroundColor: selected ? const Color(0xFF4CAF82).withOpacity(0.1) : null,
        side: BorderSide(color: selected ? const Color(0xFF4CAF82) : Colors.grey),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Text(label, style: TextStyle(color: selected ? const Color(0xFF4CAF82) : null)),
    );
  }

  Widget _activityDropdown(AppLocalizations l) {
    final options = {
      'sedentary':   l.profileActivitySedentary,
      'light':       l.profileActivityLight,
      'moderate':    l.profileActivityModerate,
      'active':      l.profileActivityActive,
      'very_active': l.profileActivityVeryActive,
    };
    return DropdownButtonFormField<String>(
      value: _activity,
      decoration: InputDecoration(labelText: l.profileActivity, border: const OutlineInputBorder()),
      items: options.entries.map((e) =>
          DropdownMenuItem(value: e.key, child: Text(e.value, overflow: TextOverflow.ellipsis))
      ).toList(),
      onChanged: (v) => setState(() => _activity = v!),
    );
  }

  Widget _langBtn(String label, String code, String currentCode) {
    final selected = currentCode == code;
    return ElevatedButton(
      onPressed: () => ref.read(localeNotifierProvider.notifier).setLocale(code),
      style: ElevatedButton.styleFrom(
        backgroundColor: selected ? const Color(0xFF4CAF82) : Colors.grey[200],
        foregroundColor: selected ? Colors.white : Colors.black87,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        elevation: 0,
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}