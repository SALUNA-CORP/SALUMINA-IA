// lib/core/servicios/gestor_plugins.dart
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../modelos/plugin_base.dart';
import '../../plugins/sensores/sensores_plugin.dart';

class GestorPlugins {
  final Map<String, Plugin> _pluginsActivos = {};
  final Map<String, WidgetBuilder> _rutas = {};

  // Lista de plugins disponibles
  final Map<String, Plugin Function()> _pluginsDisponibles = {

    'sensores': () => PluginSensores(), // Añadimos el nuevo plugin

  };

  // Obtener todas las rutas registradas
  Map<String, WidgetBuilder> get rutas => _rutas;

  // Verificar si un plugin está activo
  bool estaActivo(String nombrePlugin) => _pluginsActivos.containsKey(nombrePlugin);

  // Cargar un plugin
  Future<void> cargarPlugin(String nombrePlugin) async {
    if (estaActivo(nombrePlugin)) {
      debugPrint('Plugin $nombrePlugin ya está activo');
      return;
    }

    if (!_pluginsDisponibles.containsKey(nombrePlugin)) {
      throw Exception('Plugin $nombrePlugin no encontrado');
    }

    try {
      // Crear instancia del plugin
      final plugin = _pluginsDisponibles[nombrePlugin]!();

      // Verificar dependencias
      for (final dependencia in plugin.dependencias) {
        if (!estaActivo(dependencia)) {
          await cargarPlugin(dependencia);
        }
      }

      // Inicializar plugin
      await plugin.inicializar();

      // Registrar rutas del plugin
      _rutas.addAll(plugin.rutas);

      // Marcar como activo
      _pluginsActivos[nombrePlugin] = plugin;

      debugPrint('Plugin $nombrePlugin cargado exitosamente');
    } catch (e) {
      debugPrint('Error al cargar plugin $nombrePlugin: $e');
      rethrow;
    }
  }

  // Desactivar un plugin
  Future<void> desactivarPlugin(String nombrePlugin) async {
    if (!estaActivo(nombrePlugin)) {
      debugPrint('Plugin $nombrePlugin no está activo');
      return;
    }

    try {
      final plugin = _pluginsActivos[nombrePlugin]!;

      // Verificar dependencias inversas
      for (final otroPlugin in _pluginsActivos.values) {
        if (otroPlugin.dependencias.contains(nombrePlugin)) {
          await desactivarPlugin(otroPlugin.nombre);
        }
      }

      // Desactivar plugin
      await plugin.desactivar();

      // Eliminar rutas del plugin
      plugin.rutas.keys.forEach(_rutas.remove);

      // Eliminar de activos
      _pluginsActivos.remove(nombrePlugin);

      debugPrint('Plugin $nombrePlugin desactivado exitosamente');
    } catch (e) {
      debugPrint('Error al desactivar plugin $nombrePlugin: $e');
      rethrow;
    }
  }
}