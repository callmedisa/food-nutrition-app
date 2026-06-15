// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kazakh (`kk`).
class AppLocalizationsKk extends AppLocalizations {
  AppLocalizationsKk([String locale = 'kk']) : super(locale);

  @override
  String get appTitle => 'NutriScan';

  @override
  String get navHome => 'Басты';

  @override
  String get navStats => 'Статистика';

  @override
  String get navProfile => 'Профиль';

  @override
  String get labelCalories => 'Калориялар';

  @override
  String get labelProtein => 'Белоктар';

  @override
  String get labelFat => 'Майлар';

  @override
  String get labelCarbs => 'Көмірсулар';

  @override
  String get labelKcal => 'ккал';

  @override
  String get labelGrams => 'г';

  @override
  String get labelPer100g => '100 г өнімге';

  @override
  String homeCaloriesOf(int goal) {
    return '$goal ккалдан';
  }

  @override
  String homeRemaining(int n) {
    return 'Қалды: $n ккал';
  }

  @override
  String get homeSetupProfile => 'Профильді баптаңыз ▸';

  @override
  String get homeMeals => 'Тамақтану';

  @override
  String homeMealsCount(int n) {
    return '$n жазба';
  }

  @override
  String get homeEmpty => 'Тағам жазбалары жоқ';

  @override
  String get homeEmptyHint => '«Тағам қосу» немесе\nфотосурет түсіріңіз';

  @override
  String get homeAddFood => 'Тағам қосу';

  @override
  String homeMacroOf(int goal) {
    return '$goal г-нан';
  }

  @override
  String get cameraTitle => 'Тағамды тану';

  @override
  String get cameraHint => 'Камераны тағамға\nбағыттаңыз';

  @override
  String get cameraAnalyzing => 'Тағам талдануда...';

  @override
  String get cameraProcessing => 'ML-модель суретті өңдеуде';

  @override
  String get cameraCheckServer => 'Сервер тексерілуде...';

  @override
  String get cameraSending => 'Сурет жіберілуде...';

  @override
  String cameraWarmingUp(int n) {
    return 'Модель дайындалуда, әрекет $n/3...';
  }

  @override
  String get cameraRecognized => 'Танылды:';

  @override
  String cameraConfidence(int n) {
    return 'Дәлдік: $n%';
  }

  @override
  String get cameraAlternatives => 'Дұрыс емес пе? Дұрысын таңдаңыз:';

  @override
  String get cameraTryAgain => 'Қайталау';

  @override
  String get cameraAddToDiary => 'Күнделікке қосу';

  @override
  String get cameraTakePhoto => 'Фотосурет түсіру';

  @override
  String get cameraGallery => 'Галереядан таңдау';

  @override
  String get cameraErrorNoBackend =>
      'Backend іске қосылмаған.\n\nСерверді іске қосыңыз:\ncd backend && python -m uvicorn main:app --reload';

  @override
  String get cameraErrorTimeout =>
      'Уақыт асып кетті. 30 секундтан кейін қайталаңыз.';

  @override
  String get cameraErrorConnection =>
      'Қосылу қатесі. Backend іске қосылғанын тексеріңіз.';

  @override
  String get cameraRetry => 'Қайталап көру';

  @override
  String get cameraOfflineMode => 'Офлайн режимі';

  @override
  String get statsTitle => 'Статистика';

  @override
  String get statsAverage => 'Орташа';

  @override
  String get statsGoal => 'Мақсат';

  @override
  String get statsDaysLogged => 'Жазылған\nкүндер';

  @override
  String get statsChartTitle => '7 күн бойы калориялар';

  @override
  String get statsOnTrack => 'Қалыпты';

  @override
  String get statsOverGoal => 'Асып кетті';

  @override
  String get statsByDay => 'Күндер бойынша';

  @override
  String get statsToday => 'Бүгін';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get profileSave => 'Сақтау';

  @override
  String get profilePersonal => 'Жеке деректер';

  @override
  String get profileName => 'Аты';

  @override
  String get profileAge => 'Жасы';

  @override
  String get profileWeight => 'Салмақ (кг)';

  @override
  String get profileHeight => 'Бойы (см)';

  @override
  String get profileMale => 'Ер';

  @override
  String get profileFemale => 'Әйел';

  @override
  String get profileActivity => 'Белсенділік деңгейі';

  @override
  String get profileCalorieGoal => 'Калория нормасы:';

  @override
  String get profileActivitySedentary => 'Отырықшы өмір салты';

  @override
  String get profileActivityLight => 'Жеңіл белсенділік (аптасына 1-3 рет)';

  @override
  String get profileActivityModerate => 'Орташа (аптасына 3-5 рет)';

  @override
  String get profileActivityActive => 'Жоғары (аптасына 6-7 рет)';

  @override
  String get profileActivityVeryActive => 'Өте жоғары (спортшы)';

  @override
  String get settingsLanguage => 'Тіл';

  @override
  String get settingsLangRu => 'Русский';

  @override
  String get settingsLangKk => 'Қазақша';

  @override
  String get settingsLangEn => 'English';

  @override
  String get settingsTheme => 'Тақырып';

  @override
  String get settingsThemeSystem => 'Жүйелік';

  @override
  String get settingsThemeLight => 'Жарық';

  @override
  String get settingsThemeDark => 'Күңгірт';

  @override
  String get addFoodTitle => 'Тағам қосу';

  @override
  String get addFoodSearch => 'Өнімді іздеу...';

  @override
  String get addFoodServing => 'Порция (г)';

  @override
  String get addFoodAdd => 'Күнделікке қосу';

  @override
  String get addFoodSelectFirst => 'Өнімді таңдаңыз';

  @override
  String get validRequired => 'Міндетті өріс';

  @override
  String get validPositive => 'Оң сан енгізіңіз';
}
