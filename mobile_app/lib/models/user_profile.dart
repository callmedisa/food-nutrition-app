class UserProfile {
  final String name;
  final int age;
  final double weight; // kg
  final double height; // cm
  final String gender; // 'male' | 'female'
  final String activity; // 'sedentary' | 'light' | 'moderate' | 'active' | 'very_active'

  const UserProfile({
    required this.name,
    required this.age,
    required this.weight,
    required this.height,
    required this.gender,
    required this.activity,
  });

  static const _activityFactors = {
    'sedentary': 1.2,
    'light': 1.375,
    'moderate': 1.55,
    'active': 1.725,
    'very_active': 1.9,
  };

  static const activityLabels = {
    'sedentary': 'Сидячий образ жизни',
    'light': 'Лёгкая активность (1-3 раза/нед)',
    'moderate': 'Умеренная (3-5 раз/нед)',
    'active': 'Высокая (6-7 раз/нед)',
    'very_active': 'Очень высокая (спортсмен)',
  };

  int get calorieGoal {
    double bmr = 10 * weight + 6.25 * height - 5 * age;
    bmr += gender == 'male' ? 5 : -161;
    return (bmr * (_activityFactors[activity] ?? 1.55)).round();
  }

  // ~1.6g protein per kg bodyweight
  int get proteinGoal => (weight * 1.6).round();

  // ~25% of calories from fat
  int get fatGoal => (calorieGoal * 0.25 / 9).round();

  // Remaining calories from carbs
  int get carbGoal => ((calorieGoal - proteinGoal * 4 - fatGoal * 9) / 4).round();

  Map<String, dynamic> toMap() => {
    'name': name,
    'age': age,
    'weight': weight,
    'height': height,
    'gender': gender,
    'activity': activity,
  };

  factory UserProfile.fromMap(Map<String, dynamic> m) => UserProfile(
    name: m['name'] as String,
    age: m['age'] as int,
    weight: (m['weight'] as num).toDouble(),
    height: (m['height'] as num).toDouble(),
    gender: m['gender'] as String,
    activity: m['activity'] as String,
  );

  UserProfile copyWith({
    String? name,
    int? age,
    double? weight,
    double? height,
    String? gender,
    String? activity,
  }) => UserProfile(
    name: name ?? this.name,
    age: age ?? this.age,
    weight: weight ?? this.weight,
    height: height ?? this.height,
    gender: gender ?? this.gender,
    activity: activity ?? this.activity,
  );
}
