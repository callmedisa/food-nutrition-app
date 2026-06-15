import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:food_nutrition_app/l10n/app_localizations.dart';

import 'core/theme/app_theme.dart';
import 'features/diary/presentation/screens/home_screen.dart';
import 'features/diary/presentation/screens/stats_screen.dart';
import 'features/profile/presentation/screens/profile_screen.dart';
import 'providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  runApp(const ProviderScope(child: NutriScanApp()));
}

// NutriScanApp — корневой виджет, ConsumerWidget слушает LocaleNotifier
// для смены языка без перезапуска приложения.
class NutriScanApp extends ConsumerWidget {
  const NutriScanApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeAsync = ref.watch(localeNotifierProvider);
    final locale = localeAsync.valueOrNull ?? const Locale('ru');

    return MaterialApp(
      title: 'NutriScan',
      debugShowCheckedModeBanner: false,

      // Светлая и тёмная темы (переключается по системному режиму устройства)
      theme:      AppTheme.light,
      darkTheme:  AppTheme.dark,
      themeMode:  ThemeMode.system,

      // Трёхязычный интерфейс: RU / KK / EN
      locale: locale,
      supportedLocales: const [
        Locale('ru'),
        Locale('kk'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      home: const SplashScreen(),
    );
  }
}

// SplashScreen показывается при старте (~280 мс), пока загружается профиль.
// После загрузки автоматически переходит на RootScreen.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<dynamic>>(profileNotifierProvider, (_, next) {
      if (!next.isLoading && context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const RootScreen()),
        );
      }
    });

    return const Scaffold(
      backgroundColor: Color(0xFF4CAF82),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, color: Colors.white, size: 80),
            SizedBox(height: 16),
            Text(
              'NutriScan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Умный счётчик калорий',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            SizedBox(height: 48),
            CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
          ],
        ),
      ),
    );
  }
}

// RootScreen — BottomNavigationBar с тремя вкладками
class RootScreen extends ConsumerStatefulWidget {
  const RootScreen({super.key});

  @override
  ConsumerState<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends ConsumerState<RootScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    final screens = [
      const HomeScreen(),
      const StatsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _tab < 2 ? _tab : 0,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) {
          if (i == 2) {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileScreen()));
            return;
          }
          setState(() => _tab = i);
        },
        backgroundColor: Theme.of(context).cardColor,
        indicatorColor: const Color(0xFF4CAF82).withOpacity(0.15),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home, color: Color(0xFF4CAF82)),
            label: l.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart_outlined),
            selectedIcon: const Icon(Icons.bar_chart, color: Color(0xFF4CAF82)),
            label: l.navStats,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outlined),
            selectedIcon: const Icon(Icons.person, color: Color(0xFF4CAF82)),
            label: l.navProfile,
          ),
        ],
      ),
    );
  }
}