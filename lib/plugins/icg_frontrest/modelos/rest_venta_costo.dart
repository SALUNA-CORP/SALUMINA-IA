// lib/plugins/icg_frontrest/modelos/venta_costo.dart
class VentaCosto {
  final String referencia;
  final String descripcion;
  final String seccion;
  final int cantidad;
  final double venta;
  final double costo;
  final double ganancia;

  VentaCosto({
    required this.referencia,
    required this.descripcion,
    required this.seccion,
    required this.cantidad,
    required this.venta,
    required this.costo,
    required this.ganancia,
  });

  factory VentaCosto.fromJson(Map<String, dynamic> json) {
    return VentaCosto(
      referencia: json['REFERENCIA'] ?? '',
      descripcion: json['DESCRIPCION'] ?? '',
      seccion: json['SECCION'] ?? '',
      cantidad: json['CANTIDAD'] ?? 0,
      venta: (json['VENTA'] ?? 0).toDouble(),
      costo: (json['COSTO'] ?? 0).toDouble(),
      ganancia: (json['GANANCIA'] ?? 0).toDouble(),
    );
  }

  double get margenBruto => venta - costo;
  double get margenPorcentaje => venta > 0 ? (ganancia / venta) * 100 : 0;
  double get costoPorUnidad => cantidad > 0 ? costo / cantidad : 0;
  double get ventaPorUnidad => cantidad > 0 ? venta / cantidad : 0;

  Map<String, dynamic> toJson() {
    return {
      'REFERENCIA': referencia,
      'DESCRIPCION': descripcion,
      'SECCION': seccion,
      'CANTIDAD': cantidad,
      'VENTA': venta,
      'COSTO': costo,
      'GANANCIA': ganancia,
    };
  }
}