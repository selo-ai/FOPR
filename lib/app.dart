import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'config/theme.dart';
import 'services/database_service.dart';
import 'screens/home_screen.dart';

class FOPRApp extends StatefulWidget {
  const FOPRApp({super.key});

  // Global navigator key for accessing app state
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  // Static reference to app state for theme updates
  static FOPRAppState? _instance;
  static FOPRAppState? get instance => _instance;

  @override
  State<FOPRApp> createState() => FOPRAppState();
}

class FOPRAppState extends State<FOPRApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    FOPRApp._instance = this;
    _loadTheme();
  }

  @override
  void dispose() {
    FOPRApp._instance = null;
    super.dispose();
  }

  void _loadTheme() {
    final settings = DatabaseService.getSettings();
    setState(() {
      _themeMode = settings.themeMode;
    });
  }

  void updateTheme(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: FOPRApp.navigatorKey,
      title: 'FOPR',
      debugShowCheckedModeBanner: false,
      
      // Turkish localization
      locale: const Locale('tr', 'TR'),
      supportedLocales: const [
        Locale('tr', 'TR'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      
      theme: NLOTheme.lightTheme,
      darkTheme: NLOTheme.darkTheme,
      themeMode: _themeMode,
      home: const HomeScreen(),
    );
  }
}
