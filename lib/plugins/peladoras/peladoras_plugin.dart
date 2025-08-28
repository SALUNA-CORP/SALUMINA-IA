// lib/plugins/peladoras/plugin.dart
import 'package:flutter/material.dart';
import '../../core/modelos/plugin_base.dart';
import 'vistas/peladoras_dashboard.dart';

class PluginPeladoras implements Plugin {
  @override
  String get nombre => 'peladoras';
  
  @override
  String get version => '1.0.0';
  
  @override
  List<String> get dependencias => [];  // Cambiado de ['core'] a []
  
  @override
  Map<String, WidgetBuilder> get rutas => {
    '/peladoras/dashboard': (context) => DashboardPeladoras(),
  };
  
  @override
  Future<void> inicializar() async {}
  
  @override
  Future<void> desactivar() async {}
}