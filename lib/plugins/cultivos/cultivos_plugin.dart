//lib/plugins/cultivos/cultivos_plugin.dart
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/modelos/plugin_base.dart';
import 'servicios/cultivos_service.dart';
import 'vistas/cultivos_dashboard.dart';
import 'vistas/cultivos_estadisticas.dart';

class PluginCultivos implements Plugin {
  @override
  String get nombre => 'cultivos';
  
  @override
  String get version => '1.0.0';
  
  @override
  List<String> get dependencias => [];
  
  @override
  Map<String, WidgetBuilder> get rutas => {
    '/cultivos/dashboard': (context) => const DashboardCultivos(),
    '/cultivos/estadisticas': (context) => const EstadisticasCultivos(),
  };
  
  @override
  Future<void> inicializar() async {
    try {
      final supabase = Supabase.instance.client;
      if (!GetIt.I.isRegistered<CultivosService>()) {
        GetIt.I.registerSingleton<CultivosService>(CultivosService(supabase));
      }
      debugPrint('Plugin cultivos inicializado correctamente');
    } catch (e) {
      debugPrint('Error inicializando plugin cultivos: $e');
      rethrow;
    }
  }

  @override
  Future<void> desactivar() async {
    try {
      if (GetIt.I.isRegistered<CultivosService>()) {
        final service = GetIt.I<CultivosService>();
        service.dispose();
        GetIt.I.unregister<CultivosService>();
      }
      debugPrint('Plugin cultivos desactivado correctamente');
    } catch (e) {
      debugPrint('Error desactivando plugin cultivos: $e');
      rethrow;
    }
  }
}