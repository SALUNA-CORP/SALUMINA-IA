//lib/plugins/sensores/sensores_plugin.dart
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../core/modelos/plugin_base.dart';
import 'servicios/sensores_api_modbus.dart';
import 'vistas/proceso/sensores_extraccion_vista.dart';
import 'vistas/proceso/sensores_vista_base.dart';
import 'vistas/tendencias/sensores_tendencias_vista.dart';
import 'vistas/mantenimiento/sensores_mantenimiento_vista.dart';
import 'vistas/produccion/sensores_produccion_vista.dart';

class PluginSensores implements Plugin {
  @override
  String get nombre => 'sensores';
  
  @override
  String get version => '1.0.0';
  
  @override
  List<String> get dependencias => [];
  
  @override
  Map<String, WidgetBuilder> get rutas => {
    // Proceso
    '/sensores/proceso/bascula': (context) => const SensoresVistaBase(titulo: 'Báscula'),
    '/sensores/proceso/recepcion': (context) => const SensoresVistaBase(titulo: 'Recepción'),
    '/sensores/proceso/esterilizacion': (context) => const SensoresVistaBase(titulo: 'Esterilización'),
    '/sensores/proceso/extraccion/1': (context) => const SensoresExtraccionVista(digPrensa: 1),
    '/sensores/proceso/extraccion/2': (context) => const SensoresExtraccionVista(digPrensa: 2),
    '/sensores/proceso/extraccion/3': (context) => const SensoresExtraccionVista(digPrensa: 3),
    '/sensores/proceso/extraccion/4': (context) => const SensoresExtraccionVista(digPrensa: 4),
    '/sensores/proceso/extraccion/5': (context) => const SensoresExtraccionVista(digPrensa: 5),
    '/sensores/proceso/desfrutado': (context) => const SensoresVistaBase(titulo: 'Desfrutado'),
    '/sensores/proceso/desfibracion': (context) => const SensoresVistaBase(titulo: 'Desfibración'),
    '/sensores/proceso/clasificacion': (context) => const SensoresVistaBase(titulo: 'Clasificación'),
    '/sensores/proceso/palmisteria': (context) => const SensoresVistaBase(titulo: 'Palmistería'),
    '/sensores/proceso/pko': (context) => const SensoresVistaBase(titulo: 'PKO'),
    '/sensores/proceso/tusas': (context) => const SensoresVistaBase(titulo: 'Tusas'),
    
    // Otras secciones
    '/sensores/tendencias': (context) => const SensoresTendenciasVista(),
    '/sensores/mantenimiento': (context) => const SensoresMantenimientoVista(),
    '/sensores/produccion': (context) => const SensoresProduccionVista(),
  };
  
  @override
  Future<void> inicializar() async {
    try {
      debugPrint('⚡ Inicializando Plugin Sensores...');
      
      if (!GetIt.instance.isRegistered<SensoresApiModbus>()) {
        GetIt.instance.registerSingleton<SensoresApiModbus>(SensoresApiModbus());
        debugPrint('✅ API Modbus registrada correctamente');
      }
      
      debugPrint('✅ Plugin Sensores inicializado correctamente');
    } catch (e, stackTrace) {
      debugPrint('❌ Error inicializando plugin Sensores: $e');
      debugPrint(stackTrace.toString());
      rethrow;
    }
  }
  
  @override
  Future<void> desactivar() async {
    try {
      debugPrint('⚡ Desactivando Plugin Sensores...');
      
      if (GetIt.instance.isRegistered<SensoresApiModbus>()) {
        final api = GetIt.instance<SensoresApiModbus>();
        api.dispose();
        GetIt.instance.unregister<SensoresApiModbus>();
        debugPrint('✅ API Modbus desregistrada correctamente');
      }
      
      debugPrint('✅ Plugin Sensores desactivado correctamente');
    } catch (e) {
      debugPrint('❌ Error desactivando plugin Sensores: $e');
      rethrow;
    }
  }
}