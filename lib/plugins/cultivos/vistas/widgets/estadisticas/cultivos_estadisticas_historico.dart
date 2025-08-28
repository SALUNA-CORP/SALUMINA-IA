//lib/plugins/cultivos/vistas/widgets/cultivos_estadisticas_historico.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:collection/collection.dart';
import '../../../servicios/cultivos_service.dart';
import '../../../../../core/temas/tema_personalizado.dart';

class RendimientoHistorico extends StatelessWidget {
  const RendimientoHistorico({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, List<dynamic>>>(
      stream: GetIt.I<CultivosService>().streamEstadisticasAgrupadas(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final datos = _procesarDatosHistoricos(snapshot.data!['por_cultivo'] as List);
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(MdiIcons.chartLine, color: ColoresTema.accent1),
                    const SizedBox(width: 8),
                    Text('Rendimiento Histórico',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ColoresTema.textPrimary,
                      )),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 400,
                  child: LineChart(
                    LineChartData(
                      lineBarsData: _crearLineas(datos),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Text('${value.toInt()} Kg/Ha',
                                style: TextStyle(
                                  color: ColoresTema.textSecondary,
                                  fontSize: 10,
                                ));
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= datos.keys.length) return const Text('');
                              final fecha = datos.keys.elementAt(value.toInt());
                              return Text(DateFormat('MMM yy').format(fecha),
                                style: TextStyle(
                                  color: ColoresTema.textSecondary,
                                  fontSize: 10,
                                ));
                            },
                          ),
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawHorizontalLine: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: ColoresTema.border.withOpacity(0.2),
                            strokeWidth: 1,
                            dashArray: [5, 5],
                          );
                        },
                      ),
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildLeyenda(datos),
              ],
            ),
          ),
        );
      },
    );
  }

  Map<DateTime, Map<String, double>> _procesarDatosHistoricos(List<dynamic> datos) {
    final datosAgrupados = <DateTime, Map<String, double>>{};

    for (var grupo in datos) {
      for (var siembra in grupo) {
        final tipoCultivo = siembra['cultivos_tipos']['nombre'];
        final fecha = DateTime.parse(siembra['fecha_inicio']);
        final fechaMes = DateTime(fecha.year, fecha.month);
        final kgPorHa = siembra['hectareas_cosechadas'] > 0 ? 
          siembra['kg_cosechados'] / siembra['hectareas_cosechadas'] : 0.0;

        datosAgrupados[fechaMes] ??= {};
        datosAgrupados[fechaMes]![tipoCultivo] = 
          (datosAgrupados[fechaMes]![tipoCultivo] ?? 0) + kgPorHa;
      }
    }

    return Map.fromEntries(datosAgrupados.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));
  }

  List<LineChartBarData> _crearLineas(Map<DateTime, Map<String, double>> datos) {
    final cultivos = <String>{};
    for (var mes in datos.values) {
      cultivos.addAll(mes.keys);
    }

    final colores = [
      ColoresTema.accent1,
      ColoresTema.accent2,
      ColoresTema.warning,
      ColoresTema.success,
      ColoresTema.error,
    ];

    return cultivos.toList().asMap().entries.map((entry) {
      final cultivo = entry.value;
      final color = colores[entry.key % colores.length];

      return LineChartBarData(
        spots: datos.entries.mapIndexed((index, mes) {
          return FlSpot(index.toDouble(), mes.value[cultivo] ?? 0);
        }).toList(),
        color: color,
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          color: color.withOpacity(0.1),
        ),
      );
    }).toList();
  }

  Widget _buildLeyenda(Map<DateTime, Map<String, double>> datos) {
    final cultivos = <String>{};
    for (var mes in datos.values) {
      cultivos.addAll(mes.keys);
    }

    final colores = [
      ColoresTema.accent1,
      ColoresTema.accent2,
      ColoresTema.warning,
      ColoresTema.success,
      ColoresTema.error,
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: cultivos.toList().asMap().entries.map((entry) {
        final cultivo = entry.value;
        final color = colores[entry.key % colores.length];

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(cultivo),
          ],
        );
      }).toList(),
    );
  }
}