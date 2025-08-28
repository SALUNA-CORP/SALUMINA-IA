// lib/plugins/peladoras/utils/calculadora_estadisticas.dart
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../modelos/peladoras_toma.dart';
import '../modelos/peladoras_estadisticas.dart';
import '../../../core/temas/tema_personalizado.dart';

class CalculadoraEstadisticas {
  static const double META_DIARIA = 250.0;
  static const double META_EFICIENCIA = 85.0;

  static List<EstadisticasPeladora> procesarEstadisticas(List<Toma> tomas) {
    final datosPorPeladora = groupBy(tomas, (Toma t) => t.peladoraId);
    
    return datosPorPeladora.entries.map((entry) {
      final tomasPeladora = entry.value;
      final datosPorDia = groupBy(tomasPeladora, 
        (t) => t.fecha.toIso8601String().split('T')[0]);
      
      final totalKg = tomasPeladora.fold<double>(0, (sum, t) => sum + t.kilogramos);
      final totalCosto = tomasPeladora.fold<double>(0, (sum, t) => sum + t.costoToma);
      
      final diasMeta = _calcularDiasMeta(datosPorDia);
      final (mejorDia, kgMejorDia) = _obtenerMejorDia(datosPorDia);
      final promedioKgHora = _calcularPromedioKgHora(tomasPeladora);
      final eficiencia = _calcularEficiencia(datosPorDia);
      final metricas = _calcularMetricasCalidad(tomasPeladora);

      return EstadisticasPeladora(
        id: entry.key,
        nombre: tomasPeladora.first.peladora.nombre,
        apellido: tomasPeladora.first.peladora.apellido,
        activo: tomasPeladora.first.peladora.activo,
        totalKg: totalKg,
        totalCosto: totalCosto,
        diasTrabajados: datosPorDia.length,
        diasMeta: diasMeta,
        horasPorDia: _calcularHorasPorDia(datosPorDia),
        promedioKgHora: promedioKgHora,
        eficiencia: eficiencia,
        ultimaToma: tomasPeladora.fold<DateTime>(
          tomasPeladora.first.horaInicio,
          (prev, toma) => toma.horaInicio.isAfter(prev) ? toma.horaInicio : prev
        ),
        mejorDia: mejorDia,
        kgMejorDia: kgMejorDia,
        metricas: metricas,
      );
    }).toList();
  }

  static int _calcularDiasMeta(Map<String, List<Toma>> datosPorDia) {
    return datosPorDia.values.where((tomas) {
      final kgDia = tomas.fold<double>(0, (sum, t) => sum + t.kilogramos);
      return kgDia >= META_DIARIA;
    }).length;
  }

  static double _calcularHorasPorDia(Map<String, List<Toma>> datosPorDia) {
    return datosPorDia.values.map((tomas) {
      final horas = tomas.map((t) => t.horaInicio.hour).toSet();
      return horas.length.toDouble();
    }).average;
  }

  static double _calcularPromedioKgHora(List<Toma> tomas) {
    final horasTrabajadas = tomas.map((t) => t.horaInicio.hour).toSet().length;
    return tomas.fold<double>(0, (sum, t) => sum + t.kilogramos) / horasTrabajadas;
  }

  static double _calcularEficiencia(Map<String, List<Toma>> datosPorDia) {
    final promedioDiario = datosPorDia.values
      .map((tomas) => tomas.fold<double>(0, (sum, t) => sum + t.kilogramos))
      .average;
    
    return (promedioDiario / META_DIARIA) * 100;
  }

  static (DateTime, double) _obtenerMejorDia(Map<String, List<Toma>> datosPorDia) {
    var maxKg = 0.0;
    var mejorFecha = DateTime.now();
    
    datosPorDia.forEach((fecha, tomas) {
      final kgDia = tomas.fold<double>(0, (sum, t) => sum + t.kilogramos);
      if (kgDia > maxKg) {
        maxKg = kgDia;
        mejorFecha = tomas.first.fecha;
      }
    });
    
    return (mejorFecha, maxKg);
  }

  static MetricasCalidad _calcularMetricasCalidad(List<Toma> tomas) {
    if (tomas.isEmpty) {
      return MetricasCalidad(
        consistencia: 0,
        cumplimientoHorario: 0,
        tasaDefectos: 0,
        indiceCalidad: 0,
      );
    }

    final kgs = tomas.map((t) => t.kilogramos).toList();
    final promedio = kgs.average;
    final desviacion = sqrt(kgs.map((k) => pow(k - promedio, 2)).average);
    final consistencia = max(0, 1 - (desviacion / promedio));

    final horasEsperadas = List.generate(8, (i) => i + 9);
    final horasTrabajadas = tomas.map((t) => t.horaInicio.hour).toSet();
    final cumplimientoHorario = horasTrabajadas.length / horasEsperadas.length;

    return MetricasCalidad(
      consistencia: consistencia * 100,
      cumplimientoHorario: cumplimientoHorario * 100,
      tasaDefectos: 0,
      indiceCalidad: (consistencia * 0.6 + cumplimientoHorario * 0.4) * 100,
    );
  }

  static Color getColorEficiencia(double eficiencia) {
    if (eficiencia >= META_EFICIENCIA) return ColoresTema.success;
    if (eficiencia >= META_EFICIENCIA * 0.8) return ColoresTema.warning;
    return ColoresTema.error;
  }
}