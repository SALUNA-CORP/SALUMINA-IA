//lib/plugins/sensores/vistas/mantenimiento/sensores_mantenimiento_vista.dart
import 'package:flutter/material.dart';

class SensoresMantenimientoVista extends StatelessWidget {
  const SensoresMantenimientoVista({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mantenimiento'),
      ),
      body: const Center(
        child: Text('Vista de Mantenimiento'),
      ),
    );
  }
}