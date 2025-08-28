//lib/plugins/sensores/vistas/tendencias/sensores_tendencias_vista.dart
import 'package:flutter/material.dart';

class SensoresTendenciasVista extends StatelessWidget {
  const SensoresTendenciasVista({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tendencias'),
      ),
      body: const Center(
        child: Text('Vista de Tendencias'),
      ),
    );
  }
}