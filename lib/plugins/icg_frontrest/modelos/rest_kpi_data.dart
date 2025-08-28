// lib/plugins/icg_frontrest/models/rest_kpi_data.dart

class KPIData {
  final double valor;
  final String etiqueta;
  final double porcentaje;
  final String? tendencia;
  final Map<String, double>? distribucion;
  final Map<String, dynamic>? datos;

  const KPIData({
    required this.valor,
    required this.etiqueta,
    required this.porcentaje,
    this.tendencia,
    this.distribucion,
    this.datos,
  });
}

class KPIProducto {
  final String nombre;
  final double valor;
  final String metrica;
  final String subtitulo;

  const KPIProducto({
    required this.nombre,
    required this.valor,
    required this.metrica,
    required this.subtitulo,
  });
}