class UserProfile {
  final String name;
  final int age;
  final double weight;
  final double height;
  final String gender;   // 'male' | 'female'
  final String activity; // 'sedentary' | 'light' | 'moderate' | 'active' | 'very_active'

  const UserProfile({
    required this.name,
    required this.age,
    required this.weight,
    required this.height,
    required this.gender,
    required this.activity,
  });

  static const activityFactors = {
    'sedentary': 1.2,
    'light': 1.375,
    'moderate': 1.55,
    'active': 1.725,
    'very_active': 1.9,
  };

  // Формула Mifflin–St Jeor
  int get calorieGoal {
    double bmr = 10 * weight + 6.25 * height - 5 * age;
    bmr += gender == 'male' ? 5 : -161;
    return (bmr * (activityFactors[activity] ?? 1.55)).round();
  }

  int get proteinGoal => (weight * 1.6).round();
  int get fatGoal => (calorieGoal * 0.25 / 9).round();
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