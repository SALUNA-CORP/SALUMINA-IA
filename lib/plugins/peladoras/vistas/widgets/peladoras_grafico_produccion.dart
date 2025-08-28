// lib/plugins/peladoras/vistas/widgets/grafico_produccion.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../modelos/peladoras_toma.dart';
import '../../../../core/temas/tema_personalizado.dart';
import 'package:intl/intl.dart';

class GraficoProduccion extends StatelessWidget {
  final List<Toma> tomas;
  

  const GraficoProduccion({Key? key, required this.tomas}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final datos = _procesarDatos();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColoresTema.cardBackground,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: ColoresTema.border),
        boxShadow: [
          BoxShadow(
            color: ColoresTema.accent2.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        children: [
          Text(
            'Producción vs Costos',
            style: TextStyle(
              color: ColoresTema.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    tooltipMargin: 8,
                    tooltipPadding: const EdgeInsets.all(8),
                    tooltipRoundedRadius: 8,
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final isKilos = spot.barIndex == 0;
                        return LineTooltipItem(
                          isKilos 
                            ? '${spot.y.toStringAsFixed(1)} Kg'
                            : '\$${spot.y.toStringAsFixed(2)}',
                          TextStyle(
                            color: isKilos ? ColoresTema.accent1 : ColoresTema.accent2,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: ColoresTema.border.withOpacity(0.2),
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  ),
                ),
                titlesData: FlTitlesData(
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= datos.fechas.length) return const Text('');
                        return Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            datos.fechas[value.toInt()],
                            style: TextStyle(
                              color: ColoresTema.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
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
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: datos.kilos,
                    isCurved: true,
                    color: ColoresTema.accent1,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          ColoresTema.accent1.withOpacity(0.2),
                          ColoresTema.accent1.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  LineChartBarData(
                    spots: datos.costos,
                    isCurved: true,
                    color: ColoresTema.accent2,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          ColoresTema.accent2.withOpacity(0.2),
                          ColoresTema.accent2.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _DatosGrafico _procesarDatos() {
    final Map<String, _DatosDiarios> datosPorDia = {};
    
    for (var toma in tomas) {
      final fecha = DateFormat('dd/MM').format(toma.fecha);
      if (!datosPorDia.containsKey(fecha)) {
        datosPorDia[fecha] = _DatosDiarios(kilos: 0, costo: 0);
      }
      datosPorDia[fecha]!.kilos += toma.kilogramos;
      datosPorDia[fecha]!.costo += toma.costoToma;
    }

    final fechasOrdenadas = datosPorDia.keys.toList()..sort();
    final spots1 = <FlSpot>[];
    final spots2 = <FlSpot>[];

    for (var i = 0; i < fechasOrdenadas.length; i++) {
      final datos = datosPorDia[fechasOrdenadas[i]]!;
      spots1.add(FlSpot(i.toDouble(), datos.kilos));
      spots2.add(FlSpot(i.toDouble(), datos.costo));
    }

    return _DatosGrafico(
      kilos: spots1,
      costos: spots2,
      fechas: fechasOrdenadas,
    );
  }
}

class _DatosGrafico {
  final List<FlSpot> kilos;
  final List<FlSpot> costos;
  final List<String> fechas;

  _DatosGrafico({
    required this.kilos,
    required this.costos,
    required this.fechas,
  });
}

class _DatosDiarios {
  double kilos;
  double costo;

  _DatosDiarios({
    required this.kilos,
    required this.costo,
  });
}