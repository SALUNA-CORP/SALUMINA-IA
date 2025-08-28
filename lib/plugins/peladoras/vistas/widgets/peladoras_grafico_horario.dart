// lib/plugins/peladoras/vistas/widgets/grafico_horario.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../modelos/peladoras_toma.dart';
import '../../../../core/temas/tema_personalizado.dart';

class GraficoHorario extends StatelessWidget {
  final List<Toma> tomas;

  const GraficoHorario({super.key, required this.tomas});

  Map<int, Map<String, double>> calcularDatosHorarios() {
    final datosHorarios = <int, Map<String, double>>{};
    
    for (var toma in tomas) {
      final hora = toma.horaInicio.toLocal().hour;
      
      if (!datosHorarios.containsKey(hora)) {
        datosHorarios[hora] = {
          'total': 0,
          'count': 0,
          'promedio': 0,
        };
      }
      
      datosHorarios[hora]!['total'] = datosHorarios[hora]!['total']! + toma.kilogramos;
      datosHorarios[hora]!['count'] = datosHorarios[hora]!['count']! + 1;
      datosHorarios[hora]!['promedio'] = 
        datosHorarios[hora]!['total']! / datosHorarios[hora]!['count']!;
    }

    return Map.fromEntries(
      datosHorarios.entries.toList()..sort((a, b) => a.key.compareTo(b.key))
    );
  }

  @override
  Widget build(BuildContext context) {
    final datosHorarios = calcularDatosHorarios();
    final maxY = datosHorarios.isEmpty ? 10.0 : 
      (datosHorarios.values.map((v) => v['promedio'] ?? 0.0).reduce((a, b) => a > b ? a : b) * 1.2);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColoresTema.cardBackground,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: ColoresTema.border),
        boxShadow: [
          BoxShadow(
            color: ColoresTema.accent1.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(MdiIcons.chartBar, 
                    color: ColoresTema.accent1,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Kilogramos por Hora',
                    style: TextStyle(
                      color: ColoresTema.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: ColoresTema.accent1.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(MdiIcons.clockOutline,
                          color: ColoresTema.accent1,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${datosHorarios.length} Horas',
                          style: TextStyle(
                            color: ColoresTema.accent1,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(MdiIcons.informationOutline,
                      color: ColoresTema.accent2),
                    onPressed: () {
                      // Mostrar información del gráfico
                    },
                    tooltip: 'Información del gráfico',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 300,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                minY: 0,
                barTouchData: BarTouchData(
                  enabled: true,
                  handleBuiltInTouches: true,
                  touchTooltipData: BarTouchTooltipData(
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final hora = group.x.toString().padLeft(2, '0');
                      return BarTooltipItem(
                        '${rod.toY.toStringAsFixed(1)} Kg\n$hora:00',
                        TextStyle(
                          color: ColoresTema.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                barGroups: datosHorarios.entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value['promedio'] ?? 0,
                        gradient: LinearGradient(
                          colors: [ColoresTema.accent1, ColoresTema.accent2],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        width: 12,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6)
                        ),
                      )
                    ],
                  );
                }).toList(),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 5,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: ColoresTema.border.withOpacity(0.2),
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false)
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false)
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            '${value.toInt().toString().padLeft(2, '0')}:00',
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
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()} Kg',
                          style: TextStyle(
                            color: ColoresTema.textSecondary,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}