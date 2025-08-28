//lib/plugins/futbol/plugin.dart
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/modelos/plugin_base.dart';
import 'servicios/servicio_futbol.dart';
import 'vistas/dashboard_futbol.dart';

class PluginFutbol implements Plugin {
  @override
  String get nombre => 'futbol';
  
  @override
  String get version => '1.0.0';
  
  @override
  List<String> get dependencias => [];
  
  @override
  Map<String, WidgetBuilder> get rutas => {
    '/futbol': (context) => const DashboardFutbol(),
    '/futbol/dashboard': (context) => const DashboardFutbol(),
  };
  
  @override
  Future<void> inicializar() async {
    // Registrar servicio en GetIt
    final supabase = Supabase.instance.client;
    GetIt.I.registerSingleton<ServicioFutbol>(ServicioFutbol(supabase));
  }
  
  @override
  Future<void> desactivar() async {
    // Limpiar recursos
    if (GetIt.I.isRegistered<ServicioFutbol>()) {
      GetIt.I.unregister<ServicioFutbol>();
    }
  }
}