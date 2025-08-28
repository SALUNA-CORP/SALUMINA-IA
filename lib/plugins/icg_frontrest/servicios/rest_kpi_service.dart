// lib/plugins/icg_frontrest/services/rest_kpi_service.dart

import '../modelos/rest_kpi_data.dart';
import '../modelos/rest_venta_costo.dart';
import '../modelos/rest_costo_fijo.dart';

class KPIService {
  static Map<String, KPIData> calcularKPIs(
    List<VentaCosto> ventasCostos,
    List<CostoFijo> costosFijos,
  ) {
    final ventasTotales = _calcularVentasTotales(ventasCostos);
    final costos = _calcularCostos(ventasCostos, costosFijos);
    final utilidad = _calcularUtilidad(ventasTotales.valor, costos.valor);
    final productos = _analizarProductos(ventasCostos);

    return {
      'ventas': ventasTotales,
      'costos': costos,
      'utilidad': utilidad,
      'productos': productos,
    };
  }

  static KPIData _calcularVentasTotales(List<VentaCosto> ventas) {
    final total = ventas.fold<double>(0, (sum, v) => sum + v.venta);
    final costoVar = ventas.fold<double>(0, (sum, v) => sum + v.costo);
    final margen = total - costoVar;
    
    return KPIData(
      valor: total,
      etiqueta: 'Ventas Totales',
      porcentaje: (margen / total) * 100,
      datos: {'margenBruto': margen}
    );
  }

  static KPIData _calcularCostos(
    List<VentaCosto> ventas,
    List<CostoFijo> costosFijos,
  ) {
    final costosVar = ventas.fold<double>(0, (sum, v) => sum + v.costo);
    final costosFij = costosFijos.fold<double>(0, (sum, c) => sum + c.monto);
    final total = costosVar + costosFij;

    return KPIData(
      valor: total,
      etiqueta: 'Costos Totales',
      porcentaje: 0,
      distribucion: {
        'fijos': (costosFij / total) * 100,
        'variables': (costosVar / total) * 100,
      }
    );
  }

  static KPIData _calcularUtilidad(double ventas, double costos) {
    final utilidad = ventas - costos;
    final margen = (utilidad / ventas) * 100;
    
    return KPIData(
      valor: utilidad,
      etiqueta: 'Utilidad Total',
      porcentaje: margen,
      tendencia: utilidad > 0 ? '↗️' : '↘️'
    );
  }

  static KPIData _analizarProductos(List<VentaCosto> ventas) {
    final masRentable = ventas.reduce(
      (a, b) => a.margenPorcentaje > b.margenPorcentaje ? a : b);
    
    final masVendido = ventas.reduce(
      (a, b) => a.cantidad > b.cantidad ? a : b);

    return KPIData(
      valor: 0,
      etiqueta: 'Productos Destacados',
      porcentaje: 0,
      datos: {
        'rentable': KPIProducto(
          nombre: masRentable.descripcion,
          valor: masRentable.margenPorcentaje,
          metrica: '${masRentable.margenPorcentaje.toStringAsFixed(1)}%',
          subtitulo: 'Ventas: \$${masRentable.venta}'
        ),
        'vendido': KPIProducto(
          nombre: masVendido.descripcion,
          valor: masVendido.cantidad.toDouble(),
          metrica: '${masVendido.cantidad} uds',
          subtitulo: 'Ventas: \$${masVendido.venta}'
        )
      }
    );
  }
}