// lib/plugins/icg_frontrest/modelos/costo_fijo.dart
import 'package:intl/intl.dart';

class CostoFijo {
  final String descripcion;
  final double monto;
  final DateTime fecha;
  final String categoria;
  final bool recurrente;
  final String? notasAdicionales;
  final int? periodoRecurrencia;  // en días
  final String? centroCosto;

  CostoFijo({
    required this.descripcion,
    required this.monto,
    required this.fecha,
    required this.categoria,
    this.recurrente = false,
    this.notasAdicionales,
    this.periodoRecurrencia,
    this.centroCosto,
  });

  factory CostoFijo.fromJson(Map<String, dynamic> json) {
    return CostoFijo(
      descripcion: json['DESCRIPCION'] ?? '',
      monto: (json['COSTO FIJO'] ?? 0).toDouble(),
      fecha: json['FECHA'] != null ? 
        DateTime.parse(json['FECHA']) : 
        DateTime.now(),
      categoria: json['CATEGORIA'] ?? 'Sin Categoría',
      recurrente: json['RECURRENTE'] ?? false,
      notasAdicionales: json['NOTAS'],
      periodoRecurrencia: json['PERIODO_RECURRENCIA'],
      centroCosto: json['CENTRO_COSTO'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'DESCRIPCION': descripcion,
      'COSTO FIJO': monto,
      'FECHA': fecha.toIso8601String(),
      'CATEGORIA': categoria,
      'RECURRENTE': recurrente,
      'NOTAS': notasAdicionales,
      'PERIODO_RECURRENCIA': periodoRecurrencia,
      'CENTRO_COSTO': centroCosto,
    };
  }

  String get montoFormateado {
    final formatMoneda = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
      locale: 'es_CO',
    );
    return formatMoneda.format(monto);
  }

  String get fechaFormateada {
    return DateFormat('dd/MM/yyyy').format(fecha);
  }

  DateTime? obtenerSiguienteVencimiento() {
    if (!recurrente || periodoRecurrencia == null) return null;
    return fecha.add(Duration(days: periodoRecurrencia!));
  }

  CostoFijo copyWith({
    String? descripcion,
    double? monto,
    DateTime? fecha,
    String? categoria,
    bool? recurrente,
    String? notasAdicionales,
    int? periodoRecurrencia,
    String? centroCosto,
  }) {
    return CostoFijo(
      descripcion: descripcion ?? this.descripcion,
      monto: monto ?? this.monto,
      fecha: fecha ?? this.fecha,
      categoria: categoria ?? this.categoria,
      recurrente: recurrente ?? this.recurrente,
      notasAdicionales: notasAdicionales ?? this.notasAdicionales,
      periodoRecurrencia: periodoRecurrencia ?? this.periodoRecurrencia,
      centroCosto: centroCosto ?? this.centroCosto,
    );
  }

  @override
  String toString() {
    return 'CostoFijo(descripcion: $descripcion, monto: $montoFormateado, fecha: $fechaFormateada)';
  }
}