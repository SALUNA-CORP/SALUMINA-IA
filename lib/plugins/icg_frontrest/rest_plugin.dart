// lib/plugins/icg_frontrest/plugin.dart
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../core/modelos/plugin_base.dart';
import 'vistas/rest_dashboard_costos.dart';
import 'servicios/rest_api_icg.dart';

class PluginICGFrontRest implements Plugin {
  @override
  String get nombre => 'icg_frontrest';
  
  @override
  String get version => '1.0.0';
  
  @override
  List<String> get dependencias => [];  
  
  @override
  Map<String, WidgetBuilder> get rutas => {
    '/icg/costos': (context) => const DashboardCostos(),
  };
  
  @override
  Future<void> inicializar() async {
    try {
      // Registrar API como singleton
      if (!GetIt.I.isRegistered<ApiICG>()) {
        GetIt.I.registerSingleton<ApiICG>(ApiICG());
      }
      
      debugPrint('Plugin ICG FrontRest inicializado correctamente');
    } catch (e) {
      debugPrint('Error inicializando plugin ICG FrontRest: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> desactivar() async {
    try {
      if (GetIt.I.isRegistered<ApiICG>()) {
        GetIt.I.unregister<ApiICG>();
      }
      
      debugPrint('Plugin ICG FrontRest desactivado correctamente');
    } catch (e) {
      debugPrint('Error desactivando plugin ICG FrontRest: $e');
      rethrow;
    }
  }
}