import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:intl/intl.dart';
import '../../../servicios/cultivos_service.dart';
import '../../../modelos/cultivos_models.dart';
import '../../../../../core/temas/tema_personalizado.dart';

class CultivosEstadisticasTendenciaRendimiento extends StatelessWidget {
  const CultivosEstadisticasTendenciaRendimiento({super.key});

  @override
  Widget build(BuildContext context) {
    final servicio = GetIt.I<CultivosService>();

    return StreamBuilder<List<Siembra>>(
      stream: servicio.streamSiembrasFiltradas(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Card(
            child: Center(
              child: Text('No hay datos disponibles',
                style: TextStyle(color: ColoresTema.textSecondary)),
            ),
          );
        }

        final datosAgrupados = _agruparPorTipoCultivo(snapshot.data!);
        if (datosAgrupados.isEmpty) return const SizedBox();

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
                    const Text(
                      'Tendencia de Rendimiento',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: LineChart(
                    LineChartData(
                      lineBarsData: _crearLineas(datosAgrupados),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Text(
                                  '${value.toInt()} Kg/Ha',
                                  style: TextStyle(
                                    color: ColoresTema.textSecondary,
                                    fontSize: 10,
                                  ),
                                ),
                              );
                            },
                            reservedSize: 60,
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (datosAgrupados.isEmpty || value.toInt() >= datosAgrupados[0].length) {
                                return const SizedBox();
                              }
                              final mes = datosAgrupados[0][value.toInt()].fecha;
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  DateFormat('MMM', 'es_CO').format(mes),
                                  style: TextStyle(
                                    color: ColoresTema.textSecondary,
                                    fontSize: 10,
                                  ),
                                ),
                              );
                            },
                            reservedSize: 30,
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
                        horizontalInterval: 5000,
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
                _buildLeyenda(datosAgrupados),
              ],
            ),
          ),
        );
      },
    );
  }

  List<List<_DatoRendimiento>> _agruparPorTipoCultivo(List<Siembra> siembras) {
    final datosPorTipo = <String, List<_DatoRendimiento>>{};

    for (var siembra in siembras) {
      if (siembra.kgCosechados > 0) {
        final tipo = siembra.tipo.nombre;
        datosPorTipo.putIfAbsent(tipo, () => []);
        datosPorTipo[tipo]!.add(_DatoRendimiento(
          fecha: siembra.fechaInicio,
          rendimiento: siembra.kgPorHectareaCosechada,
        ));
      }
    }

    return datosPorTipo.values.map((datos) {
      datos.sort((a, b) => a.fecha.compareTo(b.fecha));
      return datos;
    }).toList();
  }

  List<LineChartBarData> _crearLineas(List<List<_DatoRendimiento>> datos) {
    final colores = [
      ColoresTema.accent1,
      ColoresTema.accent2,
      ColoresTema.success,
      ColoresTema.warning,
    ];

    return datos.asMap().entries.map((entry) {
      final color = colores[entry.key % colores.length];
      final puntos = entry.value;

      return LineChartBarData(
        spots: puntos.asMap().entries.map((e) {
          return FlSpot(
            e.key.toDouble(),
            e.value.rendimiento,
          );
        }).toList(),
        isCurved: true,
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

  Widget _buildLeyenda(List<List<_DatoRendimiento>> datos) {
    final colores = [
      ColoresTema.accent1,
      ColoresTema.accent2,
      ColoresTema.success,
      ColoresTema.warning,
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: datos.asMap().entries.map((entry) {
        final color = colores[entry.key % colores.length];
        final puntos = entry.value;
        final promedio = puntos.map((p) => p.rendimiento).reduce((a, b) => a + b) / puntos.length;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
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
              Text(
                '${promedio.toStringAsFixed(1)} Kg/Ha',
                style: TextStyle(color: ColoresTema.textSecondary),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _DatoRendimiento {
  final DateTime fecha;
  final double rendimiento;

  _DatoRendimiento({
    required this.fecha,
    required this.rendimiento,
  });
}