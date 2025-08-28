// lib/plugins/icg_frontrest/vistas/widgets/grafico_dispersion.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../modelos/rest_venta_costo.dart';
import '../../../../core/temas/tema_personalizado.dart';

class GraficoDispersion extends StatelessWidget {
  final List<VentaCosto> ventasCostos;

  const GraficoDispersion({
    super.key,
    required this.ventasCostos,
  });

  @override
  Widget build(BuildContext context) {
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
            'Margen vs Volumen',
            style: TextStyle(
              color: ColoresTema.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 300,
            child: ScatterChart(
              ScatterChartData(
                scatterSpots: ventasCostos.map((venta) {
                  return ScatterSpot(
                    venta.cantidad.toDouble(),
                    venta.margenPorcentaje,
                    dotPainter: FlDotCirclePainter(
                      color: _getColorMargen(venta.margenPorcentaje),
                      strokeWidth: 1,
                      strokeColor: Colors.white,
                    ),
                  );
                }).toList(),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    axisNameWidget: Text('Cantidad Vendida', 
                      style: TextStyle(color: ColoresTema.textSecondary)),
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: _calcularIntervalo(ventasCostos),
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: ColoresTema.textSecondary,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    axisNameWidget: Text('Margen %', 
                      style: TextStyle(color: ColoresTema.textSecondary)),
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 10,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}%',
                          style: TextStyle(
                            color: ColoresTema.textSecondary,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  drawVerticalLine: true,
                  horizontalInterval: 10,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: ColoresTema.border.withOpacity(0.2),
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  ),
                  getDrawingVerticalLine: (value) => FlLine(
                    color: ColoresTema.border.withOpacity(0.2),
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LeyendaItem(
                color: ColoresTema.success,
                label: 'Alto Margen (>30%)',
              ),
              const SizedBox(width: 16),
              _LeyendaItem(
                color: ColoresTema.warning,
                label: 'Medio Margen (15-30%)',
              ),
              const SizedBox(width: 16),
              _LeyendaItem(
                color: ColoresTema.error,
                label: 'Bajo Margen (<15%)',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getColorMargen(double margen) {
    if (margen >= 30) return ColoresTema.success;
    if (margen >= 15) return ColoresTema.warning;
    return ColoresTema.error;
  }

  double _calcularIntervalo(List<VentaCosto> datos) {
    if (datos.isEmpty) return 1;
    final maxCantidad = datos.map((d) => d.cantidad).reduce((a, b) => a > b ? a : b);
    if (maxCantidad <= 10) return 1;
    if (maxCantidad <= 50) return 5;
    if (maxCantidad <= 100) return 10;
    if (maxCantidad <= 500) return 50;
    return 100;
  }
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
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
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