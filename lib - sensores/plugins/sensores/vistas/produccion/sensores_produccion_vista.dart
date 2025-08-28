//lib/plugins/sensores/vistas/produccion/sensores_produccion_vista.dart
import 'package:flutter/material.dart';

class SensoresProduccionVista extends StatelessWidget {
  const SensoresProduccionVista({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Producción'),
      ),
      body: const Center(
        child: Text('Vista de Producción'),
      ),
    );
  }
}