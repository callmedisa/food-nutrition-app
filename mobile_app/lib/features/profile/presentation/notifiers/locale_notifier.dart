import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/db/database_helper.dart';

// LocaleNotifier хранит текущую локаль в SQLite и уведомляет всё дерево виджетов.
// Вызывается из SettingsScreen при смене языка RU → KK → EN.
class LocaleNotifier extends AsyncNotifier<Locale> {
  @override
  Future<Locale> build() async {
    final saved = await DatabaseHelper.getSetting('locale');
    return _fromCode(saved ?? 'ru');
  }

  Future<void> setLocale(String langCode) async {
    await DatabaseHelper.saveSetting('locale', langCode);
    state = AsyncValue.data(_fromCode(langCode));
  }

  static Locale _fromCode(String code) {
    switch (code) {
      case 'kk': return const Locale('kk');
      case 'en': return const Locale('en');
      default:   return const Locale('ru');
    }
  }
}

final localeNotifierProvider =
    AsyncNotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);