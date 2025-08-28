// lib/plugins/icg_frontrest/vistas/widgets/grafico_costos.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../modelos/rest_venta_costo.dart';
import '../../modelos/rest_costo_fijo.dart';
import '../../../../core/temas/tema_personalizado.dart';

class GraficoCostos extends StatelessWidget {
  final List<VentaCosto> ventasCostos;
  final List<CostoFijo> costosFijos;
  final int topN;

  const GraficoCostos({
    super.key,
    required this.ventasCostos,
    required this.costosFijos,
    this.topN = 10,
  });

  @override
  Widget build(BuildContext context) {
    final datosAgrupados = _agruparDatos();
    final topProductos = datosAgrupados.entries.take(topN).toList();

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
            'Top $topN Productos - Análisis de Costos',
            style: TextStyle(
              color: ColoresTema.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 300,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: topProductos.map((e) => e.value.venta).reduce((a, b) => a > b ? a : b) * 1.1,
                barGroups: topProductos.asMap().entries.map((entry) {
                  final index = entry.key;
                  final datos = entry.value.value;
                  
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: datos.venta,
                        width: 16,
                        rodStackItems: [
                          BarChartRodStackItem(
                            0,
                            datos.costo,
                            ColoresTema.error.withOpacity(0.7),
                          ),
                          BarChartRodStackItem(
                            datos.costo,
                            datos.venta,
                            ColoresTema.success.withOpacity(0.7),
                          ),
                        ],
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                    ],
                  );
                }).toList(),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '\$${(value/1000).toStringAsFixed(0)}K',
                            style: TextStyle(
                              color: ColoresTema.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= topProductos.length) return const Text('');
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: RotatedBox(
                            quarterTurns: 3,
                            child: Text(
                              topProductos[index].key,
                              style: TextStyle(
                                color: ColoresTema.textSecondary,
                                fontSize: 10,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        );
                      },
                      reservedSize: 80,
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1000000,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: ColoresTema.border.withOpacity(0.2),
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  ),
                ),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LeyendaItem(
                color: ColoresTema.error,
                label: 'Costo',
              ),
              const SizedBox(width: 20),
              _LeyendaItem(
                color: ColoresTema.success,
                label: 'Margen',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Map<String, _DatosCosto> _agruparDatos() {
    final datos = <String, _DatosCosto>{};
    
    for (var venta in ventasCostos) {
      datos[venta.descripcion] = _DatosCosto(
        venta: venta.venta,
        costo: venta.costo,
      );
    }

    return Map.fromEntries(
      datos.entries.toList()
        ..sort((a, b) => b.value.venta.compareTo(a.value.venta))
    );
  }
}

class _DatosCosto {
  final double venta;
  final double costo;

  _DatosCosto({
    required this.venta,
    required this.costo,
  });

  double get margen => venta - costo;
  double get margenPorcentaje => venta > 0 ? (margen / venta) * 100 : 0;
}

class _LeyendaItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LeyendaItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color.withOpacity(0.7),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: ColoresTema.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}