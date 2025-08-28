// lib/plugins/cultivos/vistas/widgets/estadisticas/cultivos_estadisticas_calidad_yuca.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../servicios/cultivos_service.dart';
import '../../../modelos/cultivos_models.dart';
import '../../../../../core/temas/tema_personalizado.dart';

class CultivosEstadisticasCalidadYuca extends StatelessWidget {
  const CultivosEstadisticasCalidadYuca({super.key});

  @override
  Widget build(BuildContext context) {
    final servicio = GetIt.I<CultivosService>();
    final formatoNumero = NumberFormat('#,##0', 'es_CO');

    return StreamBuilder<List<Siembra>>(
      stream: servicio.streamSiembrasFiltradas(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final siembras = snapshot.data!.where((s) => 
          s.tipo.nombre.toUpperCase() == 'YUCA' && 
          s.kgCosechados > 0
        ).toList();

        if (siembras.isEmpty) {
          return Card(
            child: Center(
              child: Text('No hay datos disponibles',
                style: TextStyle(color: ColoresTema.textSecondary)),
            ),
          );
        }

        final datos = _calcularEstadisticas(siembras);

        return Card(
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(MdiIcons.chartPie, color: ColoresTema.accent1),
                    const SizedBox(width: 8),
                    const Text('Análisis de Calidad - Yuca',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      )),
                  ],
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 300,
                        child: PieChart(
                          PieChartData(
                            sections: [
                              PieChartSectionData(
                                value: datos.porcentajePrimera,
                                title: '${datos.porcentajePrimera.toStringAsFixed(1)}%',
                                color: ColoresTema.accent1,
                                radius: 110,
                                titleStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              PieChartSectionData(
                                value: datos.porcentajeSegunda,
                                title: '${datos.porcentajeSegunda.toStringAsFixed(1)}%',
                                color: ColoresTema.warning,
                                radius: 110,
                                titleStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                            sectionsSpace: 2,
                            centerSpaceRadius: 50,
                          ),
                        ),
                      ),
                      const SizedBox(width: 40),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildMetricaRow(
                              'Total Cosechado',
                              '${formatoNumero.format(datos.totalKilos)} Kg',
                              MdiIcons.weight,
                            ),
                            const SizedBox(height: 24),
                            _buildMetricaRow(
                              'Yuca Primera',
                              '${formatoNumero.format(datos.kilosPrimera)} Kg (${datos.porcentajePrimera.toStringAsFixed(1)}%)',
                              MdiIcons.podiumGold,
                              color: ColoresTema.accent1,
                            ),
                            const SizedBox(height: 24),
                            _buildMetricaRow(
                              'Yuca Segunda',
                              '${formatoNumero.format(datos.kilosSegunda)} Kg (${datos.porcentajeSegunda.toStringAsFixed(1)}%)',
                              MdiIcons.podiumSilver,
                              color: ColoresTema.warning,
                            ),
                            const SizedBox(height: 32),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: ColoresTema.cardBackground,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: ColoresTema.border),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Estadísticas Generales',
                                    style: TextStyle(
                                      color: ColoresTema.textPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildEstadistica(
                                    'Promedio Calidad Primera:',
                                    '${datos.promedioCalidadPrimera.toStringAsFixed(1)}%'
                                  ),
                                  const SizedBox(height: 4),
                                  _buildEstadistica(
                                    'Mejor Lote:',
                                    '${datos.mejorLote} (${datos.porcentajeMejorLote.toStringAsFixed(1)}%)'
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _DatosCalidad _calcularEstadisticas(List<Siembra> siembras) {
    double totalKilos = 0;
    double kilosPrimera = 0;
    double kilosSegunda = 0;
    double sumaPorcentajesPrimera = 0;
    String mejorLote = '';
    double mejorPorcentaje = 0;

    for (var siembra in siembras) {
      totalKilos += siembra.kgCosechados;
      kilosPrimera += siembra.kgPrimera;
      kilosSegunda += siembra.kgSegunda;
      
      final porcentajePrimera = siembra.porcentajePrimera;
      sumaPorcentajesPrimera += porcentajePrimera;
      
      if (porcentajePrimera > mejorPorcentaje) {
        mejorPorcentaje = porcentajePrimera;
        mejorLote = siembra.codigoLote;
      }
    }

    final porcentajePrimera = (kilosPrimera / totalKilos) * 100;
    final porcentajeSegunda = (kilosSegunda / totalKilos) * 100;
    final promedioCalidadPrimera = sumaPorcentajesPrimera / siembras.length;

    return _DatosCalidad(
      totalKilos: totalKilos,
      kilosPrimera: kilosPrimera,
      kilosSegunda: kilosSegunda,
      porcentajePrimera: porcentajePrimera,
      porcentajeSegunda: porcentajeSegunda,
      promedioCalidadPrimera: promedioCalidadPrimera,
      mejorLote: mejorLote,
      porcentajeMejorLote: mejorPorcentaje,
    );
  }

  Widget _buildMetricaRow(String titulo, String valor, IconData icono, {Color? color}) {
    return Row(
      children: [
        Icon(icono, size: 24, color: color ?? ColoresTema.accent1),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo,
              style: TextStyle(
                color: ColoresTema.textSecondary,
                fontSize: 14,
              ),
            ),
            Text(valor,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEstadistica(String label, String valor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
          style: TextStyle(color: ColoresTema.textSecondary)),
        Text(valor,
          style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _DatosCalidad {
  final double totalKilos;
  final double kilosPrimera;
  final double kilosSegunda;
  final double porcentajePrimera;
  final double porcentajeSegunda;
  final double promedioCalidadPrimera;
  final String mejorLote;
  final double porcentajeMejorLote;

  _DatosCalidad({
    required this.totalKilos,
    required this.kilosPrimera,
    required this.kilosSegunda,
    required this.porcentajePrimera,
    required this.porcentajeSegunda,
    required this.promedioCalidadPrimera,
    required this.mejorLote,
    required this.porcentajeMejorLote,
  });
}