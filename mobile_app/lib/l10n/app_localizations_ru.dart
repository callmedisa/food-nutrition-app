// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'NutriScan';

  @override
  String get navHome => 'Главная';

  @override
  String get navStats => 'Статистика';

  @override
  String get navProfile => 'Профиль';

  @override
  String get labelCalories => 'Калории';

  @override
  String get labelProtein => 'Белки';

  @override
  String get labelFat => 'Жиры';

  @override
  String get labelCarbs => 'Углеводы';

  @override
  String get labelKcal => 'ккал';

  @override
  String get labelGrams => 'г';

  @override
  String get labelPer100g => 'на 100 г продукта';

  @override
  String homeCaloriesOf(int goal) {
    return 'из $goal ккал';
  }

  @override
  String homeRemaining(int n) {
    return 'Осталось: $n ккал';
  }

  @override
  String get homeSetupProfile => 'Настройте профиль ▸';

  @override
  String get homeMeals => 'Приёмы пищи';

  @override
  String homeMealsCount(int n) {
    return '$n записей';
  }

  @override
  String get homeEmpty => 'Нет записей о еде';

  @override
  String get homeEmptyHint => 'Нажмите «Добавить еду» или\nсделайте фото блюда';

  @override
  String get homeAddFood => 'Добавить еду';

  @override
  String homeMacroOf(int goal) {
    return 'из $goal г';
  }

  @override
  String get cameraTitle => 'Распознавание еды';

  @override
  String get cameraHint => 'Наведите камеру\nна блюдо';

  @override
  String get cameraAnalyzing => 'Анализирую блюдо...';

  @override
  String get cameraProcessing => 'ML-модель обрабатывает изображение';

  @override
  String get cameraCheckServer => 'Проверяю сервер...';

  @override
  String get cameraSending => 'Отправляю изображение...';

  @override
  String cameraWarmingUp(int n) {
    return 'Модель прогревается, попытка $n/3...';
  }

  @override
  String get cameraRecognized => 'Распознано:';

  @override
  String cameraConfidence(int n) {
    return 'Точность: $n%';
  }

  @override
  String get cameraAlternatives => 'Не то блюдо? Выбери правильный вариант:';

  @override
  String get cameraTryAgain => 'Повторить';

  @override
  String get cameraAddToDiary => 'Добавить в дневник';

  @override
  String get cameraTakePhoto => 'Сфотографировать';

  @override
  String get cameraGallery => 'Выбрать из галереи';

  @override
  String get cameraErrorNoBackend =>
      'Backend не запущен.\n\nЗапусти сервер:\ncd backend && python -m uvicorn main:app --reload';

  @override
  String get cameraErrorTimeout =>
      'Превышено время ожидания. Попробуй ещё раз через 30 секунд.';

  @override
  String get cameraErrorConnection =>
      'Ошибка подключения. Проверь что backend запущен.';

  @override
  String get cameraRetry => 'Попробовать снова';

  @override
  String get cameraOfflineMode => 'Офлайн-режим';

  @override
  String get statsTitle => 'Статистика';

  @override
  String get statsAverage => 'Среднее';

  @override
  String get statsGoal => 'Цель';

  @override
  String get statsDaysLogged => 'Дней\nзаписей';

  @override
  String get statsChartTitle => 'Калории за 7 дней';

  @override
  String get statsOnTrack => 'В норме';

  @override
  String get statsOverGoal => 'Превышение';

  @override
  String get statsByDay => 'По дням';

  @override
  String get statsToday => 'Сегодня';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get profileSave => 'Сохранить';

  @override
  String get profilePersonal => 'Личные данные';

  @override
  String get profileName => 'Имя';

  @override
  String get profileAge => 'Возраст';

  @override
  String get profileWeight => 'Вес (кг)';

  @override
  String get profileHeight => 'Рост (см)';

  @override
  String get profileMale => 'Мужской';

  @override
  String get profileFemale => 'Женский';

  @override
  String get profileActivity => 'Уровень активности';

  @override
  String get profileCalorieGoal => 'Ваша норма калорий:';

  @override
  String get profileActivitySedentary => 'Сидячий образ жизни';

  @override
  String get profileActivityLight => 'Лёгкая активность (1-3 раза/нед)';

  @override
  String get profileActivityModerate => 'Умеренная (3-5 раз/нед)';

  @override
  String get profileActivityActive => 'Высокая (6-7 раз/нед)';

  @override
  String get profileActivityVeryActive => 'Очень высокая (спортсмен)';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsLangRu => 'Русский';

  @override
  String get settingsLangKk => 'Қазақша';

  @override
  String get settingsLangEn => 'English';

  @override
  String get settingsTheme => 'Тема оформления';

  @override
  String get settingsThemeSystem => 'Системная';

  @override
  String get settingsThemeLight => 'Светлая';

  @override
  String get settingsThemeDark => 'Тёмная';

  @override
  String get addFoodTitle => 'Добавить еду';

  @override
  String get addFoodSearch => 'Поиск продукта...';

  @override
  String get addFoodServing => 'Порция (г)';

  @override
  String get addFoodAdd => 'Добавить в дневник';

  @override
  String get addFoodSelectFirst => 'Выберите продукт';

  @override
  String get validRequired => 'Обязательное поле';

  @override
  String get validPositive => 'Введите положительное число';
}
