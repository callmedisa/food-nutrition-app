// Инфраструктурные провайдеры Riverpod:
// DataSource → Repository → UseCase (без нотифаеров, чтобы избежать циклических импортов)
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/classification/data/datasources/api_datasource.dart';
import 'features/classification/data/datasources/platform_channel_datasource.dart';
import 'features/classification/data/repositories/classification_repository_impl.dart';
import 'features/classification/domain/repositories/classification_repository.dart';
import 'features/classification/domain/usecases/classify_image_usecase.dart';
import 'features/diary/data/datasources/diary_local_datasource.dart';
import 'features/diary/data/repositories/diary_repository_impl.dart';
import 'features/diary/domain/repositories/diary_repository.dart';
import 'features/diary/domain/usecases/add_meal_usecase.dart';
import 'features/diary/domain/usecases/delete_meal_usecase.dart';
import 'features/diary/domain/usecases/get_diary_usecase.dart';
import 'features/diary/domain/usecases/get_weekly_stats_usecase.dart';
import 'features/nutrition/data/repositories/nutrition_repository_impl.dart';
import 'features/nutrition/domain/repositories/nutrition_repository.dart';
import 'features/nutrition/domain/usecases/search_food_usecase.dart';
import 'features/profile/data/datasources/profile_local_datasource.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/domain/repositories/profile_repository.dart';
import 'features/profile/domain/usecases/get_profile_usecase.dart';
import 'features/profile/domain/usecases/save_profile_usecase.dart';

// ── Data Sources ──────────────────────────────────────────────────────────────
final profileDataSourceProvider =
    Provider<ProfileLocalDataSource>((_) => ProfileLocalDataSource());

final diaryDataSourceProvider =
    Provider<DiaryLocalDataSource>((_) => DiaryLocalDataSource());

final platformChannelDataSourceProvider =
    Provider<PlatformChannelDataSource>((_) => PlatformChannelDataSource());

final apiDataSourceProvider =
    Provider<ApiDataSource>((_) => ApiDataSource());

// ── Repositories ──────────────────────────────────────────────────────────────
final profileRepositoryProvider = Provider<ProfileRepository>((ref) =>
    ProfileRepositoryImpl(ref.read(profileDataSourceProvider)));

final diaryRepositoryProvider = Provider<DiaryRepository>((ref) =>
    DiaryRepositoryImpl(ref.read(diaryDataSourceProvider)));

final nutritionRepositoryProvider = Provider<NutritionRepository>(
    (_) => NutritionRepositoryImpl());

final classificationRepositoryProvider =
    Provider<ClassificationRepository>((ref) => ClassificationRepositoryImpl(
          ref.read(platformChannelDataSourceProvider),
          ref.read(apiDataSourceProvider),
        ));

// ── Use Cases ─────────────────────────────────────────────────────────────────
final getProfileUseCaseProvider = Provider<GetProfileUseCase>(
    (ref) => GetProfileUseCase(ref.read(profileRepositoryProvider)));

final saveProfileUseCaseProvider = Provider<SaveProfileUseCase>(
    (ref) => SaveProfileUseCase(ref.read(profileRepositoryProvider)));

final getDiaryUseCaseProvider = Provider<GetDiaryUseCase>(
    (ref) => GetDiaryUseCase(ref.read(diaryRepositoryProvider)));

final addMealUseCaseProvider = Provider<AddMealUseCase>(
    (ref) => AddMealUseCase(ref.read(diaryRepositoryProvider)));

final deleteMealUseCaseProvider = Provider<DeleteMealUseCase>(
    (ref) => DeleteMealUseCase(ref.read(diaryRepositoryProvider)));

final getWeeklyStatsUseCaseProvider = Provider<GetWeeklyStatsUseCase>(
    (ref) => GetWeeklyStatsUseCase(ref.read(diaryRepositoryProvider)));

final classifyImageUseCaseProvider = Provider<ClassifyImageUseCase>(
    (ref) => ClassifyImageUseCase(ref.read(classificationRepositoryProvider)));

final searchFoodUseCaseProvider = Provider<SearchFoodUseCase>(
    (ref) => SearchFoodUseCase(ref.read(nutritionRepositoryProvider)));