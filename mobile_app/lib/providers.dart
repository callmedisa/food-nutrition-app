// Barrel-export всех Riverpod-провайдеров.
// Импортируйте этот файл в screens — он даёт доступ ко всей DI-цепочке.
export 'core_providers.dart';
export 'features/classification/presentation/notifiers/classification_notifier.dart';
export 'features/diary/presentation/notifiers/diary_notifier.dart';
export 'features/diary/presentation/notifiers/stats_notifier.dart';
export 'features/profile/presentation/notifiers/locale_notifier.dart';
export 'features/profile/presentation/notifiers/profile_notifier.dart';