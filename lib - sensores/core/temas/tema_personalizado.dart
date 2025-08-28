// lib/core/temas/tema_personalizado.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ColoresTema {
  // Colores base
  static const background = Color(0xFF0A1929);
  static const cardBackground = Color(0xFF0F2744);
  static const accent1 = Color(0xFF00A3FF);
  static const accent2 = Color(0xFF00FFD1);
  static const textPrimary = Color(0xFFE6F1FF);
  static const textSecondary = Color(0xFF8892B0);
  static const border = Color(0xFF1E3A5F);
  
  // Colores de estado
  static const success = Color(0xFF00FFB2);
  static const warning = Color(0xFFFFB86C);
  static const error = Color(0xFFFF5555);
  
  // Colores de gráficos
  static const chart1 = Color(0xFF00B4D8);
  static const chart2 = Color(0xFF90E0EF);
  static const chartGrid = Color(0xFF1E3A5F);
}

final temaFuturista = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.dark(
    background: ColoresTema.background,
    primary: ColoresTema.accent1,
    secondary: ColoresTema.accent2,
    surface: ColoresTema.cardBackground,
    error: ColoresTema.error,
  ),
  
  // Tema de texto
  textTheme: GoogleFonts.robotoTextTheme().copyWith(
    displayLarge: TextStyle(color: ColoresTema.textPrimary),
    displayMedium: TextStyle(color: ColoresTema.textPrimary),
    displaySmall: TextStyle(color: ColoresTema.textPrimary),
    headlineLarge: TextStyle(color: ColoresTema.textPrimary),
    headlineMedium: TextStyle(color: ColoresTema.textPrimary),
    headlineSmall: TextStyle(color: ColoresTema.textPrimary),
    titleLarge: TextStyle(color: ColoresTema.textPrimary),
    titleMedium: TextStyle(color: ColoresTema.textPrimary),
    titleSmall: TextStyle(color: ColoresTema.textPrimary),
    bodyLarge: TextStyle(color: ColoresTema.textPrimary),
    bodyMedium: TextStyle(color: ColoresTema.textPrimary),
    bodySmall: TextStyle(color: ColoresTema.textSecondary),
  ),
  
  // Tema de tarjetas
  cardTheme: CardTheme(
    color: ColoresTema.cardBackground,
    elevation: 8,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
      side: BorderSide(
        color: ColoresTema.border,
        width: 1,
      ),
    ),
  ),
  
  // Tema de botones
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: ColoresTema.accent1,
      foregroundColor: ColoresTema.textPrimary,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    ),
  ),
  
  // Tema de inputs
  inputDecorationTheme: InputDecorationTheme(
    fillColor: ColoresTema.background,
    filled: true,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: ColoresTema.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: ColoresTema.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: ColoresTema.accent1, width: 2),
    ),
    labelStyle: TextStyle(color: ColoresTema.textSecondary),
  ),
  
  // Tema de diálogos
  dialogTheme: DialogTheme(
    backgroundColor: ColoresTema.cardBackground,
    elevation: 16,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
  ),
  
  // Tema de íconos
  iconTheme: IconThemeData(
    color: ColoresTema.accent1,
  ),
  
  // Tema de Divider
  dividerTheme: DividerThemeData(
    color: ColoresTema.border,
    thickness: 1,
  ),

  // Tema de Scaffold
  scaffoldBackgroundColor: ColoresTema.background,
);