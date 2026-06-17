import 'package:flutter/material.dart';
import 'screens/main_navigation.dart';

void main() {
  runApp(const DebrideApp());
}

class DebrideApp extends StatelessWidget {
  const DebrideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Débridé',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF264C72),
          primary: const Color(0xFFE58B24), // Orange lanière
          secondary: const Color(0xFF264C72), // Bleu semelle
          surface: Colors.white,
          background: const Color(0xFFF5F7FA), // Fond doux gris/bleuté
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
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
      home: const MainNavigation(),
    );
  }
}
