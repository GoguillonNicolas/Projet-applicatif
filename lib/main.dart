import 'package:flutter/material.dart';
import 'screens/main_navigation.dart';

void main() {
  runApp(const DebrideApp());
}

class DebrideApp extends StatefulWidget {
  const DebrideApp({super.key});

  @override
  State<DebrideApp> createState() => _DebrideAppState();
}

class _DebrideAppState extends State<DebrideApp> {
  bool _isDarkMode = false;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Débridé',
      debugShowCheckedModeBanner: false,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF264C72),
          brightness: Brightness.light,
          primary: const Color(0xFFE58B24), // Orange lanière
          secondary: const Color(0xFF264C72), // Bleu semelle
          surface: Colors.white,
          background: const Color(0xFFF5F7FA), // Fond doux gris/bleuté
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        dividerColor: const Color(0xFFE2E8F0),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            color: Color(0xFF1A2D42),
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
          bodyMedium: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 14,
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF264C72),
          brightness: Brightness.dark,
          primary: const Color(0xFFE58B24), // Orange lanière
          secondary: const Color(0xFF90CAF9), // Bleu semelle plus clair
          surface: const Color(0xFF1E293B), // Fond de carte sombre slate
          background: const Color(0xFF0F172A), // Fond de page sombre slate
        ),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        dividerColor: const Color(0xFF334155),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
          bodyMedium: TextStyle(
            color: Color(0xFF94A3B8), // Slate plus clair pour la lisibilité
            fontSize: 14,
          ),
        ),
      ),
      home: MainNavigation(
        isDarkMode: _isDarkMode,
        onThemeToggled: _toggleTheme,
      ),
    );
  }
}
