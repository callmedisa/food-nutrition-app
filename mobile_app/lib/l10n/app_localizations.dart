import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_kk.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('kk'),
    Locale('ru')
  ];

  /// No description provided for @appTitle.
  ///
  /// In ru, this message translates to:
  /// **'NutriScan'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In ru, this message translates to:
  /// **'Главная'**
  String get navHome;

  /// No description provided for @navStats.
  ///
  /// In ru, this message translates to:
  /// **'Статистика'**
  String get navStats;

  /// No description provided for @navProfile.
  ///
  /// In ru, this message translates to:
  /// **'Профиль'**
  String get navProfile;

  /// No description provided for @labelCalories.
  ///
  /// In ru, this message translates to:
  /// **'Калории'**
  String get labelCalories;

  /// No description provided for @labelProtein.
  ///
  /// In ru, this message translates to:
  /// **'Белки'**
  String get labelProtein;

  /// No description provided for @labelFat.
  ///
  /// In ru, this message translates to:
  /// **'Жиры'**
  String get labelFat;

  /// No description provided for @labelCarbs.
  ///
  /// In ru, this message translates to:
  /// **'Углеводы'**
  String get labelCarbs;

  /// No description provided for @labelKcal.
  ///
  /// In ru, this message translates to:
  /// **'ккал'**
  String get labelKcal;

  /// No description provided for @labelGrams.
  ///
  /// In ru, this message translates to:
  /// **'г'**
  String get labelGrams;

  /// No description provided for @labelPer100g.
  ///
  /// In ru, this message translates to:
  /// **'на 100 г продукта'**
  String get labelPer100g;

  /// No description provided for @homeCaloriesOf.
  ///
  /// In ru, this message translates to:
  /// **'из {goal} ккал'**
  String homeCaloriesOf(int goal);

  /// No description provided for @homeRemaining.
  ///
  /// In ru, this message translates to:
  /// **'Осталось: {n} ккал'**
  String homeRemaining(int n);

  /// No description provided for @homeSetupProfile.
  ///
  /// In ru, this message translates to:
  /// **'Настройте профиль ▸'**
  String get homeSetupProfile;

  /// No description provided for @homeMeals.
  ///
  /// In ru, this message translates to:
  /// **'Приёмы пищи'**
  String get homeMeals;

  /// No description provided for @homeMealsCount.
  ///
  /// In ru, this message translates to:
  /// **'{n} записей'**
  String homeMealsCount(int n);

  /// No description provided for @homeEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Нет записей о еде'**
  String get homeEmpty;

  /// No description provided for @homeEmptyHint.
  ///
  /// In ru, this message translates to:
  /// **'Нажмите «Добавить еду» или\nсделайте фото блюда'**
  String get homeEmptyHint;

  /// No description provided for @homeAddFood.
  ///
  /// In ru, this message translates to:
  /// **'Добавить еду'**
  String get homeAddFood;

  /// No description provided for @homeMacroOf.
  ///
  /// In ru, this message translates to:
  /// **'из {goal} г'**
  String homeMacroOf(int goal);

  /// No description provided for @cameraTitle.
  ///
  /// In ru, this message translates to:
  /// **'Распознавание еды'**
  String get cameraTitle;

  /// No description provided for @cameraHint.
  ///
  /// In ru, this message translates to:
  /// **'Наведите камеру\nна блюдо'**
  String get cameraHint;

  /// No description provided for @cameraAnalyzing.
  ///
  /// In ru, this message translates to:
  /// **'Анализирую блюдо...'**
  String get cameraAnalyzing;

  /// No description provided for @cameraProcessing.
  ///
  /// In ru, this message translates to:
  /// **'ML-модель обрабатывает изображение'**
  String get cameraProcessing;

  /// No description provided for @cameraCheckServer.
  ///
  /// In ru, this message translates to:
  /// **'Проверяю сервер...'**
  String get cameraCheckServer;

  /// No description provided for @cameraSending.
  ///
  /// In ru, this message translates to:
  /// **'Отправляю изображение...'**
  String get cameraSending;

  /// No description provided for @cameraWarmingUp.
  ///
  /// In ru, this message translates to:
  /// **'Модель прогревается, попытка {n}/3...'**
  String cameraWarmingUp(int n);

  /// No description provided for @cameraRecognized.
  ///
  /// In ru, this message translates to:
  /// **'Распознано:'**
  String get cameraRecognized;

  /// No description provided for @cameraConfidence.
  ///
  /// In ru, this message translates to:
  /// **'Точность: {n}%'**
  String cameraConfidence(int n);

  /// No description provided for @cameraAlternatives.
  ///
  /// In ru, this message translates to:
  /// **'Не то блюдо? Выбери правильный вариант:'**
  String get cameraAlternatives;

  /// No description provided for @cameraTryAgain.
  ///
  /// In ru, this message translates to:
  /// **'Повторить'**
  String get cameraTryAgain;

  /// No description provided for @cameraAddToDiary.
  ///
  /// In ru, this message translates to:
  /// **'Добавить в дневник'**
  String get cameraAddToDiary;

  /// No description provided for @cameraTakePhoto.
  ///
  /// In ru, this message translates to:
  /// **'Сфотографировать'**
  String get cameraTakePhoto;

  /// No description provided for @cameraGallery.
  ///
  /// In ru, this message translates to:
  /// **'Выбрать из галереи'**
  String get cameraGallery;

  /// No description provided for @cameraErrorNoBackend.
  ///
  /// In ru, this message translates to:
  /// **'Backend не запущен.\n\nЗапусти сервер:\ncd backend && python -m uvicorn main:app --reload'**
  String get cameraErrorNoBackend;

  /// No description provided for @cameraErrorTimeout.
  ///
  /// In ru, this message translates to:
  /// **'Превышено время ожидания. Попробуй ещё раз через 30 секунд.'**
  String get cameraErrorTimeout;

  /// No description provided for @cameraErrorConnection.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка подключения. Проверь что backend запущен.'**
  String get cameraErrorConnection;

  /// No description provided for @cameraRetry.
  ///
  /// In ru, this message translates to:
  /// **'Попробовать снова'**
  String get cameraRetry;

  /// No description provided for @cameraOfflineMode.
  ///
  /// In ru, this message translates to:
  /// **'Офлайн-режим'**
  String get cameraOfflineMode;

  /// No description provided for @statsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Статистика'**
  String get statsTitle;

  /// No description provided for @statsAverage.
  ///
  /// In ru, this message translates to:
  /// **'Среднее'**
  String get statsAverage;

  /// No description provided for @statsGoal.
  ///
  /// In ru, this message translates to:
  /// **'Цель'**
  String get statsGoal;

  /// No description provided for @statsDaysLogged.
  ///
  /// In ru, this message translates to:
  /// **'Дней\nзаписей'**
  String get statsDaysLogged;

  /// No description provided for @statsChartTitle.
  ///
  /// In ru, this message translates to:
  /// **'Калории за 7 дней'**
  String get statsChartTitle;

  /// No description provided for @statsOnTrack.
  ///
  /// In ru, this message translates to:
  /// **'В норме'**
  String get statsOnTrack;

  /// No description provided for @statsOverGoal.
  ///
  /// In ru, this message translates to:
  /// **'Превышение'**
  String get statsOverGoal;

  /// No description provided for @statsByDay.
  ///
  /// In ru, this message translates to:
  /// **'По дням'**
  String get statsByDay;

  /// No description provided for @statsToday.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня'**
  String get statsToday;

  /// No description provided for @profileTitle.
  ///
  /// In ru, this message translates to:
  /// **'Профиль'**
  String get profileTitle;

  /// No description provided for @profileSave.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get profileSave;

  /// No description provided for @profilePersonal.
  ///
  /// In ru, this message translates to:
  /// **'Личные данные'**
  String get profilePersonal;

  /// No description provided for @profileName.
  ///
  /// In ru, this message translates to:
  /// **'Имя'**
  String get profileName;

  /// No description provided for @profileAge.
  ///
  /// In ru, this message translates to:
  /// **'Возраст'**
  String get profileAge;

  /// No description provided for @profileWeight.
  ///
  /// In ru, this message translates to:
  /// **'Вес (кг)'**
  String get profileWeight;

  /// No description provided for @profileHeight.
  ///
  /// In ru, this message translates to:
  /// **'Рост (см)'**
  String get profileHeight;

  /// No description provided for @profileMale.
  ///
  /// In ru, this message translates to:
  /// **'Мужской'**
  String get profileMale;

  /// No description provided for @profileFemale.
  ///
  /// In ru, this message translates to:
  /// **'Женский'**
  String get profileFemale;

  /// No description provided for @profileActivity.
  ///
  /// In ru, this message translates to:
  /// **'Уровень активности'**
  String get profileActivity;

  /// No description provided for @profileCalorieGoal.
  ///
  /// In ru, this message translates to:
  /// **'Ваша норма калорий:'**
  String get profileCalorieGoal;

  /// No description provided for @profileActivitySedentary.
  ///
  /// In ru, this message translates to:
  /// **'Сидячий образ жизни'**
  String get profileActivitySedentary;

  /// No description provided for @profileActivityLight.
  ///
  /// In ru, this message translates to:
  /// **'Лёгкая активность (1-3 раза/нед)'**
  String get profileActivityLight;

  /// No description provided for @profileActivityModerate.
  ///
  /// In ru, this message translates to:
  /// **'Умеренная (3-5 раз/нед)'**
  String get profileActivityModerate;

  /// No description provided for @profileActivityActive.
  ///
  /// In ru, this message translates to:
  /// **'Высокая (6-7 раз/нед)'**
  String get profileActivityActive;

  /// No description provided for @profileActivityVeryActive.
  ///
  /// In ru, this message translates to:
  /// **'Очень высокая (спортсмен)'**
  String get profileActivityVeryActive;

  /// No description provided for @settingsLanguage.
  ///
  /// In ru, this message translates to:
  /// **'Язык'**
  String get settingsLanguage;

  /// No description provided for @settingsLangRu.
  ///
  /// In ru, this message translates to:
  /// **'Русский'**
  String get settingsLangRu;

  /// No description provided for @settingsLangKk.
  ///
  /// In ru, this message translates to:
  /// **'Қазақша'**
  String get settingsLangKk;

  /// No description provided for @settingsLangEn.
  ///
  /// In ru, this message translates to:
  /// **'English'**
  String get settingsLangEn;

  /// No description provided for @settingsTheme.
  ///
  /// In ru, this message translates to:
  /// **'Тема оформления'**
  String get settingsTheme;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In ru, this message translates to:
  /// **'Системная'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In ru, this message translates to:
  /// **'Светлая'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In ru, this message translates to:
  /// **'Тёмная'**
  String get settingsThemeDark;

  /// No description provided for @addFoodTitle.
  ///
  /// In ru, this message translates to:
  /// **'Добавить еду'**
  String get addFoodTitle;

  /// No description provided for @addFoodSearch.
  ///
  /// In ru, this message translates to:
  /// **'Поиск продукта...'**
  String get addFoodSearch;

  /// No description provided for @addFoodServing.
  ///
  /// In ru, this message translates to:
  /// **'Порция (г)'**
  String get addFoodServing;

  /// No description provided for @addFoodAdd.
  ///
  /// In ru, this message translates to:
  /// **'Добавить в дневник'**
  String get addFoodAdd;

  /// No description provided for @addFoodSelectFirst.
  ///
  /// In ru, this message translates to:
  /// **'Выберите продукт'**
  String get addFoodSelectFirst;

  /// No description provided for @validRequired.
  ///
  /// In ru, this message translates to:
  /// **'Обязательное поле'**
  String get validRequired;

  /// No description provided for @validPositive.
  ///
  /// In ru, this message translates to:
  /// **'Введите положительное число'**
  String get validPositive;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'kk', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'kk':
      return AppLocalizationsKk();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
