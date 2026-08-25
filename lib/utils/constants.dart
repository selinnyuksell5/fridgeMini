import 'package:flutter/material.dart';

class AppConstants {
  // API Configuration
  static const String geminiApiKey = 'AIzaSyA3sPwsoour_Lx7eL94rIwrq7pbhFoxczw';
  static const String geminiModelName = 'gemini-2.5-flash';
  
  // App Info
  static const String appName = 'FridgeMini';
  static const String appVersion = '1.0.0';
  
  // Assets
  static const String logoPath = 'assets/images/logo.png';
  static const String placeholderImage = 'assets/images/placeholder.jpg';
  
  // Default Values
  static const int defaultPrepTime = 15;
  static const int defaultCookTime = 30;
  static const int defaultServings = 2;
  
  // API Endpoints (if any)
  static const String baseUrl = 'https://api.example.com';
  static const String recipesEndpoint = '$baseUrl/recipes';
  
  // Local Storage Keys
  static const String themeKey = 'isDarkMode';
  static const String favoritesKey = 'favorite_recipes';
  static const String recentSearchesKey = 'recent_searches';
}
 
 class AppTheme {
   // Light Theme
   static final ThemeData lightTheme = ThemeData(
     primarySwatch: Colors.blue,
     brightness: Brightness.light,
     scaffoldBackgroundColor: Colors.grey[50],
     appBarTheme: AppBarTheme(
       backgroundColor: Colors.blue,
       foregroundColor: Colors.white,
       elevation: 0,
       centerTitle: true,
       titleTextStyle: const TextStyle(
         fontSize: 20,
         fontWeight: FontWeight.bold,
       ),
     ),
     cardTheme: CardThemeData(
       elevation: 2,
       shape: RoundedRectangleBorder(
         borderRadius: BorderRadius.circular(12),
       ),
     ),
     inputDecorationTheme: InputDecorationTheme(
       border: OutlineInputBorder(
         borderRadius: BorderRadius.circular(12),
         borderSide: BorderSide(color: Colors.grey[300]!),
       ),
       enabledBorder: OutlineInputBorder(
         borderRadius: BorderRadius.circular(12),
         borderSide: BorderSide(color: Colors.grey[300]!),
       ),
       filled: true,
       fillColor: Colors.white,
       contentPadding: const EdgeInsets.symmetric(
         horizontal: 16,
         vertical: 14,
       ),
     ),
     elevatedButtonTheme: ElevatedButtonThemeData(
       style: ElevatedButton.styleFrom(
         padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
         shape: RoundedRectangleBorder(
           borderRadius: BorderRadius.circular(12),
         ),
       ),
     ),
     outlinedButtonTheme: OutlinedButtonThemeData(
       style: OutlinedButton.styleFrom(
         padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
         shape: RoundedRectangleBorder(
           borderRadius: BorderRadius.circular(12),
         ),
       ),
     ),
   );
 
   // Dark Theme
   static final ThemeData darkTheme = ThemeData(
     primarySwatch: Colors.blue,
     brightness: Brightness.dark,
     scaffoldBackgroundColor: const Color(0xFF121212),
     appBarTheme: const AppBarTheme(
       backgroundColor: Color(0xFF1E1E1E),
       elevation: 0,
       centerTitle: true,
       titleTextStyle: TextStyle(
         fontSize: 20,
         fontWeight: FontWeight.bold,
       ),
     ),
     cardTheme: CardThemeData(
       elevation: 0,
       color: const Color(0xFF1E1E1E),
       shape: RoundedRectangleBorder(
         borderRadius: BorderRadius.circular(12),
       ),
     ),
     inputDecorationTheme: InputDecorationTheme(
       border: OutlineInputBorder(
         borderRadius: BorderRadius.circular(12),
         borderSide: const BorderSide(color: Color(0xFF333333)),
       ),
       enabledBorder: OutlineInputBorder(
         borderRadius: BorderRadius.circular(12),
         borderSide: const BorderSide(color: Color(0xFF333333)),
       ),
       filled: true,
       fillColor: const Color(0xFF1E1E1E),
       contentPadding: const EdgeInsets.symmetric(
         horizontal: 16,
         vertical: 14,
       ),
     ),
     elevatedButtonTheme: ElevatedButtonThemeData(
       style: ElevatedButton.styleFrom(
         padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
         shape: RoundedRectangleBorder(
           borderRadius: BorderRadius.circular(12),
         ),
       ),
     ),
     outlinedButtonTheme: OutlinedButtonThemeData(
       style: OutlinedButton.styleFrom(
         padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
         shape: RoundedRectangleBorder(
           borderRadius: BorderRadius.circular(12),
         ),
         side: const BorderSide(color: Colors.blue),
       ),
     ),
   );
 }
