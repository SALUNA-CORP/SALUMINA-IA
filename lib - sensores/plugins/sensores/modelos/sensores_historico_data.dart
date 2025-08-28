// lib/plugins/sensores/modelos/sensores_historico_data.dart
import 'package:flutter/material.dart';

class HistoricoSensor {
  final DateTime fecha;
  final String tipo;
  final double valor;
  final String unidad;

  HistoricoSensor({
    required this.fecha,
    required this.tipo,
    required this.valor,
    required this.unidad,
  });
}

final historicoSensores = [
  // Temperaturas Digestor
  ...List.generate(30, (i) => HistoricoSensor(
    fecha: DateTime.now().subtract(Duration(days: i)),
    tipo: 'temperatura_digestor',
    valor: 90.5 + (i % 5 - 2).toDouble(),
    unidad: '°C',
  )),
  
  // Presiones
  ...List.generate(30, (i) => HistoricoSensor(
    fecha: DateTime.now().subtract(Duration(days: i)),
    tipo: 'presion_vapor',
    valor: 55.0 + (i % 4 - 1.5).toDouble(),
    unidad: 'PSI',
  )),

  // Producción
  ...List.generate(30, (i) => HistoricoSensor(
    fecha: DateTime.now().subtract(Duration(days: i)),
    tipo: 'produccion',
    valor: 22.5 + (i % 3 - 1).toDouble(),
    unidad: 'Ton/h',
  )),

  // Niveles
  ...List.generate(30, (i) => HistoricoSensor(
    fecha: DateTime.now().subtract(Duration(days: i)),
    tipo: 'nivel_tanque',
    valor: 75.0 + (i % 6 - 3).toDouble(),
    unidad: '%',
  )),
];

class Alerta {
  final String titulo;
  final String mensaje;
  final NivelAlerta nivel;
  final DateTime fecha;
  final String? accion;

  Alerta({
    required this.titulo,
    required this.mensaje,
    required this.nivel,
    required this.fecha,
    this.accion,
  });
}

enum NivelAlerta {
  baja(Colors.orange),
  media(Colors.green),
  alta(Colors.red);

  final Color color;
  const NivelAlerta(this.color);
}

List<Alerta> generarAlertas() {
  final alertas = <Alerta>[];
  final ultimosDatos = historicoSensores.where(
    (h) => h.fecha.isAfter(DateTime.now().subtract(const Duration(days: 1)))
  );

  // Alertas de Temperatura
  final tempDigestor = ultimosDatos.where((h) => h.tipo == 'temperatura_digestor').firstOrNull;
  if (tempDigestor != null) {
    if (tempDigestor.valor > 95.0) {
      alertas.add(Alerta(
        titulo: 'Temperatura Alta',
        mensaje: 'Digestor: ${tempDigestor.valor.toStringAsFixed(1)}°C',
        nivel: NivelAlerta.alta,
        fecha: tempDigestor.fecha,
        accion: 'Revisar sistema de refrigeración',
      ));
    }
  }

  // Alertas de Presión
  final presion = ultimosDatos.where((h) => h.tipo == 'presion_vapor').firstOrNull;
  if (presion != null) {
    if (presion.valor < 45.0) {
      alertas.add(Alerta(
        titulo: 'Presión Baja',
        mensaje: 'Vapor: ${presion.valor.toStringAsFixed(1)} PSI',
        nivel: NivelAlerta.media,
        fecha: presion.fecha,
        accion: 'Verificar alimentación de calderas',
      ));
    }
  }

  // Alertas de Producción
  final produccion = ultimosDatos.where((h) => h.tipo == 'produccion').firstOrNull;
  if (produccion != null) {
    if (produccion.valor < 20.0) {
      alertas.add(Alerta(
        titulo: 'Producción Baja',
        mensaje: 'Actual: ${produccion.valor.toStringAsFixed(1)} Ton/h',
        nivel: NivelAlerta.alta,
        fecha: produccion.fecha,
        accion: 'Revisar alimentación de digestores',
      ));
    }
  }

  return alertas;
}