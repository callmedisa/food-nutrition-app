// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'NutriScan';

  @override
  String get navHome => 'Home';

  @override
  String get navStats => 'Statistics';

  @override
  String get navProfile => 'Profile';

  @override
  String get labelCalories => 'Calories';

  @override
  String get labelProtein => 'Protein';

  @override
  String get labelFat => 'Fat';

  @override
  String get labelCarbs => 'Carbs';

  @override
  String get labelKcal => 'kcal';

  @override
  String get labelGrams => 'g';

  @override
  String get labelPer100g => 'per 100g';

  @override
  String homeCaloriesOf(int goal) {
    return 'of $goal kcal';
  }

  @override
  String homeRemaining(int n) {
    return 'Remaining: $n kcal';
  }

  @override
  String get homeSetupProfile => 'Set up profile ▸';

  @override
  String get homeMeals => 'Meals';

  @override
  String homeMealsCount(int n) {
    return '$n records';
  }

  @override
  String get homeEmpty => 'No food records';

  @override
  String get homeEmptyHint => 'Tap «Add food» or\ntake a photo of a dish';

  @override
  String get homeAddFood => 'Add food';

  @override
  String homeMacroOf(int goal) {
    return 'of $goal g';
  }

  @override
  String get cameraTitle => 'Food Recognition';

  @override
  String get cameraHint => 'Point the camera\nat your dish';

  @override
  String get cameraAnalyzing => 'Analyzing dish...';

  @override
  String get cameraProcessing => 'ML model processing image';

  @override
  String get cameraCheckServer => 'Checking server...';

  @override
  String get cameraSending => 'Sending image...';

  @override
  String cameraWarmingUp(int n) {
    return 'Model warming up, attempt $n/3...';
  }

  @override
  String get cameraRecognized => 'Recognized:';

  @override
  String cameraConfidence(int n) {
    return 'Confidence: $n%';
  }

  @override
  String get cameraAlternatives => 'Wrong dish? Choose the correct one:';

  @override
  String get cameraTryAgain => 'Try again';

  @override
  String get cameraAddToDiary => 'Add to diary';

  @override
  String get cameraTakePhoto => 'Take photo';

  @override
  String get cameraGallery => 'Choose from gallery';

  @override
  String get cameraErrorNoBackend =>
      'Backend is not running.\n\nStart the server:\ncd backend && python -m uvicorn main:app --reload';

  @override
  String get cameraErrorTimeout =>
      'Request timed out. Try again in 30 seconds.';

  @override
  String get cameraErrorConnection =>
      'Connection error. Check that the backend is running.';

  @override
  String get cameraRetry => 'Try again';

  @override
  String get cameraOfflineMode => 'Offline mode';

  @override
  String get statsTitle => 'Statistics';

  @override
  String get statsAverage => 'Average';

  @override
  String get statsGoal => 'Goal';

  @override
  String get statsDaysLogged => 'Days\nlogged';

  @override
  String get statsChartTitle => 'Calories for 7 days';

  @override
  String get statsOnTrack => 'On track';

  @override
  String get statsOverGoal => 'Over goal';

  @override
  String get statsByDay => 'By day';

  @override
  String get statsToday => 'Today';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileSave => 'Save';

  @override
  String get profilePersonal => 'Personal data';

  @override
  String get profileName => 'Name';

  @override
  String get profileAge => 'Age';

  @override
  String get profileWeight => 'Weight (kg)';

  @override
  String get profileHeight => 'Height (cm)';

  @override
  String get profileMale => 'Male';

  @override
  String get profileFemale => 'Female';

  @override
  String get profileActivity => 'Activity level';

  @override
  String get profileCalorieGoal => 'Your calorie goal:';

  @override
  String get profileActivitySedentary => 'Sedentary lifestyle';

  @override
  String get profileActivityLight => 'Light activity (1-3 times/week)';

  @override
  String get profileActivityModerate => 'Moderate (3-5 times/week)';

  @override
  String get profileActivityActive => 'High (6-7 times/week)';

  @override
  String get profileActivityVeryActive => 'Very high (athlete)';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLangRu => 'Русский';

  @override
  String get settingsLangKk => 'Қазақша';

  @override
  String get settingsLangEn => 'English';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get addFoodTitle => 'Add food';

  @override
  String get addFoodSearch => 'Search food...';

  @override
  String get addFoodServing => 'Serving (g)';

  @override
  String get addFoodAdd => 'Add to diary';

  @override
  String get addFoodSelectFirst => 'Select a product';

  @override
  String get validRequired => 'Required field';

  @override
  String get validPositive => 'Enter a positive number';
}
