// lib/core/temas/gestor_temas.dart
import 'package:flutter/material.dart';
import 'tema_personalizado.dart';

class GestorTemas {
  static final instancia = GestorTemas._();
  GestorTemas._();

  ThemeMode _modoActual = ThemeMode.dark;
  
  ThemeMode get modoActual => _modoActual;
  ThemeData get temaActual => _modoActual == ThemeMode.light ? temaClaro : temaOscuro;

  final temaOscuro = temaFuturista;

  final temaClaro = ThemeData.light().copyWith(
    scaffoldBackgroundColor: const Color(0xFFEEF2F7),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: ColoresTema.accent1.withOpacity(0.2),
          width: 1,
        ),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      foregroundColor: Color(0xFF0A1929),
    ),
    colorScheme: ColorScheme.light(
      primary: ColoresTema.accent1,
      secondary: ColoresTema.accent2,
    ),
  );

  void cambiarTema(ThemeMode modo) {
    _modoActual = modo;
  }

  void alternarTema() {
    _modoActual = _modoActual == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }
}