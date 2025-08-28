// lib/plugins/peladoras/modelos/estadisticas.dart
import 'package:flutter/material.dart';
import '../../../core/temas/tema_personalizado.dart';

class EstadisticasPeladora {
  final int id;
  final String nombre;
  final String apellido;
  final bool activo;
  final double totalKg;
  final double totalCosto;
  final int diasTrabajados;
  final int diasMeta;
  final double horasPorDia;
  final double promedioKgHora;
  final double eficiencia;
  final DateTime ultimaToma;
  final List<double> tendenciaProductividad;
  final DateTime mejorDia;
  final double kgMejorDia;
  final MetricasCalidad metricas;

  EstadisticasPeladora({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.activo,
    required this.totalKg,
    required this.totalCosto,
    required this.diasTrabajados,
    required this.diasMeta,
    required this.horasPorDia,
    required this.promedioKgHora,
    required this.eficiencia,
    required this.ultimaToma,
    this.tendenciaProductividad = const [],
    required this.mejorDia,
    required this.kgMejorDia,
    required this.metricas,
  });

  String get nombreCompleto => '$nombre $apellido';
  double get costoPorKg => totalKg > 0 ? totalCosto / totalKg : 0;
  double get rendimientoDiario => diasTrabajados > 0 ? totalKg / diasTrabajados : 0;

  int get estrellas {
    if (rendimientoDiario >= 300) return 5;
    if (rendimientoDiario >= 275) return 4;
    if (rendimientoDiario >= 250) return 3;
    if (rendimientoDiario >= 200) return 2;
    if (rendimientoDiario >= 150) return 1;
    return 0;
  }
}

class MetricasCalidad {
  final double consistencia;
  final double cumplimientoHorario;
  final double tasaDefectos;
  final double indiceCalidad;

  MetricasCalidad({
    required this.consistencia,
    required this.cumplimientoHorario,
    required this.tasaDefectos,
    required this.indiceCalidad,
  });
}


class Alerta {
  final String mensaje;
  final NivelAlerta nivel;
  final DateTime fecha;
  final String? accionRecomendada;

  Alerta({
    required this.mensaje,
    required this.nivel,
    required this.fecha,
    this.accionRecomendada,
  });
}

enum NivelAlerta {
  baja(ColoresTema.warning),
  media(ColoresTema.accent1),
  alta(ColoresTema.error);

  final Color color;
  const NivelAlerta(this.color);
}