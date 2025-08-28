// lib/plugins/cultivos/modelos/cultivos_models.dart
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class Finca {
  final String id;
  final String nombre;
  final List<LatLng> coordenadas;
  final double areaTotal;

  Finca({
    required this.id,
    required this.nombre,
    required this.coordenadas,
    required this.areaTotal,
  });

  factory Finca.fromJson(Map<String, dynamic> json) {
    final coords = (json['coordenadas_geojson']?['coordinates']?[0] as List?) ?? [];
    return Finca(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      coordenadas: coords.map((c) => LatLng(c[1].toDouble(), c[0].toDouble())).toList(),
      areaTotal: json['area_total']?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'coordenadas_geojson': {
      'type': 'Polygon',
      'coordinates': [
        coordenadas.map((c) => [c.longitude, c.latitude]).toList()
      ]
    },
    'area_total': areaTotal,
  };
}

class Lote {
  final String id;
  final String fincaId;
  final String codigo;
  final String nombre;
  final double areaHectareas;
  final List<LatLng> coordenadas;
  final Siembra? siembraActual;

  Lote({
    required this.id,
    required this.fincaId,
    required this.codigo,
    required this.nombre,
    required this.areaHectareas,
    required this.coordenadas,
    this.siembraActual,
  });

  factory Lote.fromJson(Map<String, dynamic> json) {
    final coords = (json['coordenadas_geojson']?['coordinates']?[0] as List?) ?? [];
    final siembras = json['cultivos_siembras'] as List?;

    return Lote(
      id: json['id'] ?? '',
      fincaId: json['finca_id'] ?? '',
      codigo: json['codigo'] ?? '',
      nombre: json['nombre'] ?? '',
      areaHectareas: json['area_hectareas']?.toDouble() ?? 0,
      coordenadas: coords.map((c) => LatLng(c[1].toDouble(), c[0].toDouble())).toList(),
      siembraActual: siembras?.isNotEmpty == true ? 
        Siembra.fromJson(siembras!.first) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'finca_id': fincaId,
    'codigo': codigo,
    'nombre': nombre,
    'area_hectareas': areaHectareas,
    'coordenadas_geojson': {
      'type': 'Polygon',
      'coordinates': [
        coordenadas.map((c) => [c.longitude, c.latitude]).toList()
      ]
    },
  };
}

class Siembra {
  final String id;
  final String loteId;
  final String nombreLote;
  final String codigoLote;
  final TipoCultivo tipo;
  final EstadoCultivo estado;
  final DateTime fechaInicio;
  final DateTime? fechaFinEstimada;
  final DateTime? fechaFinReal;
  final double presupuestoTotal;
  final double inversionActual;
  final double hectareasSembradas;
  final double hectareasCosechadas;
  final double kgCosechados;
  final double kgPrimera;
  final double kgSegunda;

  Siembra({
    required this.id,
    required this.loteId,
    required this.nombreLote,
    required this.codigoLote,
    required this.tipo,
    required this.estado,
    required this.fechaInicio,
    this.fechaFinEstimada,
    this.fechaFinReal,
    required this.presupuestoTotal,
    required this.inversionActual,
    required this.hectareasSembradas,
    required this.hectareasCosechadas,
    required this.kgCosechados,
    required this.kgPrimera,
    required this.kgSegunda,
  });

  factory Siembra.fromJson(Map<String, dynamic> json) {
    final loteData = json['cultivos_lotes'] as Map<String, dynamic>? ?? {};
    return Siembra(
      id: json['id'] ?? '',
      loteId: json['lote_id'] ?? '',
      nombreLote: loteData['nombre'] ?? '',
      codigoLote: loteData['codigo'] ?? '',
      tipo: TipoCultivo.fromJson(json['cultivos_tipos'] ?? {}),
      estado: EstadoCultivo.fromJson(json['cultivos_estados'] ?? {}),
      fechaInicio: DateTime.tryParse(json['fecha_inicio'] ?? '') ?? DateTime.now(),
      fechaFinEstimada: json['fecha_fin_estimada'] != null ? 
        DateTime.tryParse(json['fecha_fin_estimada']) : null,
      fechaFinReal: json['fecha_fin_real'] != null ? 
        DateTime.tryParse(json['fecha_fin_real']) : null,
      presupuestoTotal: (json['presupuesto_total'] ?? 0).toDouble(),
      inversionActual: (json['inversion_actual'] ?? 0).toDouble(),
      hectareasSembradas: (json['hectareas_sembradas'] ?? 0).toDouble(),
      hectareasCosechadas: (json['hectareas_cosechadas'] ?? 0).toDouble(),
      kgCosechados: (json['kg_cosechados'] ?? 0).toDouble(),
      kgPrimera: (json['kg_primera'] ?? 0).toDouble(),
      kgSegunda: (json['kg_segunda'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'lote_id': loteId,
    'fecha_inicio': fechaInicio.toIso8601String(),
    'fecha_fin_estimada': fechaFinEstimada?.toIso8601String(),
    'fecha_fin_real': fechaFinReal?.toIso8601String(),
    'presupuesto_total': presupuestoTotal,
    'inversion_actual': inversionActual,
    'hectareas_sembradas': hectareasSembradas,
    'hectareas_cosechadas': hectareasCosechadas,
    'kg_cosechados': kgCosechados,
    'kg_primera': kgPrimera,
    'kg_segunda': kgSegunda,
  };

  Color get color => estado.color;
  double get porcentajeInversion => presupuestoTotal > 0 ? (inversionActual / presupuestoTotal) * 100 : 0;
  double get kgPorHectareaCosechada => hectareasCosechadas > 0 ? kgCosechados / hectareasCosechadas : 0;
  double get porcentajeAreaCosechada => hectareasSembradas > 0 ? (hectareasCosechadas / hectareasSembradas) * 100 : 0;
  double get costoHectarea => hectareasSembradas > 0 ? inversionActual / hectareasSembradas : 0;
  double get costoKilogramo => kgCosechados > 0 ? inversionActual / kgCosechados : 0;
  double get porcentajePrimera => kgCosechados > 0 ? (kgPrimera / kgCosechados) * 100 : 0;
  double get porcentajeSegunda => kgCosechados > 0 ? (kgSegunda / kgCosechados) * 100 : 0;
  double get costoPrimeraKilogramo => kgPrimera > 0 ? (inversionActual * 0.6) / kgPrimera : 0;
  double get costoSegundaKilogramo => kgSegunda > 0 ? (inversionActual * 0.4) / kgSegunda : 0;
}

class EstadoCultivo {
  final String id;
  final String nombre;
  final Color color;

  EstadoCultivo({
    required this.id,
    required this.nombre,
    required this.color,
  });

  factory EstadoCultivo.fromJson(Map<String, dynamic> json) {
    final colorStr = json['color'] as String? ?? '#FF0000';
    return EstadoCultivo(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      color: Color(int.parse(colorStr.replaceAll('#', '0xFF'))),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'color': '#${color.value.toRadixString(16).substring(2).toUpperCase()}',
  };
}

class TipoCultivo {
  final String id;
  final String nombre;
  final bool clasificaCalidad;

  TipoCultivo({
    required this.id,
    required this.nombre,
    this.clasificaCalidad = false,
  });

  factory TipoCultivo.fromJson(Map<String, dynamic> json) => TipoCultivo(
    id: json['id'] ?? '',
    nombre: json['nombre'] ?? '',
    clasificaCalidad: json['clasifica_calidad'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'clasifica_calidad': clasificaCalidad,
  };
}