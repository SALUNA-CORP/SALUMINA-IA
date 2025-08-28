//lib/plugins/sensores/vistas/proceso/sensores_vista_base.dart
import 'package:flutter/material.dart';

class SensoresVistaBase extends StatelessWidget {
  final String titulo;

  const SensoresVistaBase({
    super.key,
    required this.titulo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titulo),
      ),
      body: Center(
        child: Text('Vista de $titulo'),
      ),
    );
  }
}