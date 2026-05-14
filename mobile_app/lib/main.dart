import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'models/user_profile.dart';
import 'services/database_service.dart';
import 'screens/home_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ru', null);
  runApp(const NutriScanApp());
}

class NutriScanApp extends StatelessWidget {
  const NutriScanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriScan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF82),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
      ),
      home: const RootScreen(),
    );
  }
}

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _tab = 0;
  UserProfile? _profile;
  bool _profileLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final p = await DatabaseService.getProfile();
    if (mounted) setState(() { _profile = p; _profileLoaded = true; });
  }

  void _onProfileSaved(UserProfile p) {
    setState(() => _profile = p);
  }

  @override
  Widget build(BuildContext context) {
    if (!_profileLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFF4CAF82))),
      );
    }

    // First launch — no profile yet: show profile setup
    if (_profile == null && _tab != 2) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => ProfileScreen(
            initial: null,
            onSaved: (p) {
              _onProfileSaved(p);
              setState(() => _tab = 0);
            },
          ),
        ));
      });
    }

    final screens = [
      HomeScreen(profile: _profile),
      StatsScreen(profile: _profile),
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
            // Profile tab — open as a page (not IndexedStack)
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => ProfileScreen(
                initial: _profile,
                onSaved: _onProfileSaved,
              ),
            ));
            return;
          }
          setState(() => _tab = i);
        },
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFF4CAF82).withOpacity(0.15),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: Color(0xFF4CAF82)),
            label: 'Главная',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart, color: Color(0xFF4CAF82)),
            label: 'Статистика',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person, color: Color(0xFF4CAF82)),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}
