// lib/plugins/icg_frontrest/vistas/widgets/grafico_participacion.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../modelos/rest_venta_costo.dart';
import '../../../../core/temas/tema_personalizado.dart';

class GraficoParticipacion extends StatelessWidget {
  final List<VentaCosto> ventasCostos;

  const GraficoParticipacion({
    super.key,
    required this.ventasCostos,
  });

  @override
  Widget build(BuildContext context) {
    final datosPorSeccion = _calcularParticipacion();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColoresTema.cardBackground,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: ColoresTema.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Participación por Sección',
            style: TextStyle(
              color: ColoresTema.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 300,
                  child: PieChart(
                    PieChartData(
                      sections: _crearSecciones(datosPorSeccion),
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _construirLeyenda(datosPorSeccion),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Map<String, _DatosSeccion> _calcularParticipacion() {
    final ventasPorSeccion = <String, double>{};
    final cantidadPorSeccion = <String, int>{};
    
    for (var venta in ventasCostos) {
      ventasPorSeccion[venta.seccion] = 
        (ventasPorSeccion[venta.seccion] ?? 0) + venta.venta;
      cantidadPorSeccion[venta.seccion] = 
        (cantidadPorSeccion[venta.seccion] ?? 0) + venta.cantidad;
    }
    
    final totalVentas = ventasPorSeccion.values.fold<double>(
      0, (sum, value) => sum + value);

    final datos = <String, _DatosSeccion>{};
    for (var seccion in ventasPorSeccion.keys) {
      datos[seccion] = _DatosSeccion(
        ventas: ventasPorSeccion[seccion]!,
        cantidad: cantidadPorSeccion[seccion]!,
        participacion: (ventasPorSeccion[seccion]! / totalVentas) * 100,
      );
    }

    return datos;
  }

  List<PieChartSectionData> _crearSecciones(Map<String, _DatosSeccion> datos) {
    final colores = [
      ColoresTema.accent1,
      ColoresTema.accent2,
      ColoresTema.success,
      ColoresTema.warning,
      ColoresTema.error,
      Colors.purple,
      Colors.orange,
      Colors.teal,
    ];

    return datos.entries.map((entry) {
      final index = datos.keys.toList().indexOf(entry.key);
      return PieChartSectionData(
        value: entry.value.participacion,
        title: '${entry.value.participacion.toStringAsFixed(1)}%',
        color: colores[index % colores.length],
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _construirLeyenda(Map<String, _DatosSeccion> datos) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: datos.entries.map((entry) {
          final index = datos.keys.toList().indexOf(entry.key);
          final colores = [
            ColoresTema.accent1,
            ColoresTema.accent2,
            ColoresTema.success,
            ColoresTema.warning,
            ColoresTema.error,
            Colors.purple,
            Colors.orange,
            Colors.teal,
          ];

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: colores[index % colores.length],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        style: TextStyle(
                          color: ColoresTema.textPrimary,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '\$${_formatNumber(entry.value.ventas)} (${entry.value.cantidad} uds)',
                        style: TextStyle(
                          color: ColoresTema.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  String _formatNumber(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }
}

class _DatosSeccion {
  final double ventas;
  final int cantidad;
  final double participacion;

  _DatosSeccion({
    required this.ventas,
    required this.cantidad,
    required this.participacion,
  });
}