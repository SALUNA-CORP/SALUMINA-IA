import 'package:flutter/material.dart';

abstract class Plugin {
  String get nombre;
  String get version;
  List<String> get dependencias;
  Map<String, WidgetBuilder> get rutas;
  
  Future<void> inicializar();
  Future<void> desactivar();
}