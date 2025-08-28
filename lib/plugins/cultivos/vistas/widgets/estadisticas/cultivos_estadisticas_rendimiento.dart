//lib/plugins/cultivos/vistas/widgets/cultivos_estadisticas_rendimiento.dart
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../servicios/cultivos_service.dart';
import '../../../modelos/cultivos_models.dart';
import '../../../../../core/temas/tema_personalizado.dart';

class RendimientoCultivos extends StatelessWidget {
  const RendimientoCultivos({super.key});

  @override
  Widget build(BuildContext context) {
    final servicio = GetIt.I<CultivosService>();

    return StreamBuilder<List<Siembra>>(
      stream: servicio.streamSiembrasFiltradas(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}',
              style: TextStyle(color: ColoresTema.error)),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final siembras = snapshot.data!;
        final datosPorCultivo = _agruparPorCultivo(siembras);

        if (datosPorCultivo.isEmpty) {
          return Center(
            child: Text('No hay datos disponibles',
              style: TextStyle(color: ColoresTema.textSecondary)),
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(MdiIcons.chartPie, color: ColoresTema.accent1),
                    const SizedBox(width: 8),
                    const Text('Rendimiento por Cultivo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      )),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 300,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: datosPorCultivo.entries.map((entry) {
                        final index = datosPorCultivo.keys.toList().indexOf(entry.key);
                        final totalHectareas = datosPorCultivo.values
                          .fold<double>(0, (sum, item) => sum + item.hectareas);
                        final porcentaje = (entry.value.hectareas / totalHectareas) * 100;

                        return PieChartSectionData(
                          color: _obtenerColor(index),
                          value: porcentaje,
                          title: '${porcentaje.toStringAsFixed(1)}%',
                          radius: 100,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _construirLeyenda(datosPorCultivo),
              ],
            ),
          ),
        );
      },
    );
  }

  Map<String, _DatosCultivo> _agruparPorCultivo(List<Siembra> siembras) {
    final datos = <String, _DatosCultivo>{};
    for (var siembra in siembras) {
      final nombreCultivo = siembra.tipo.nombre;
      datos.putIfAbsent(nombreCultivo, () => _DatosCultivo()).agregar(siembra);
    }
    return datos;
  }

  Color _obtenerColor(int index) {
    final colores = [
      ColoresTema.accent1,
      ColoresTema.accent2,
      ColoresTema.success,
      ColoresTema.warning,
      ColoresTema.error,
    ];
    return colores[index % colores.length];
  }

  Widget _construirLeyenda(Map<String, _DatosCultivo> datos) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: datos.entries.map((entry) {
        final index = datos.keys.toList().indexOf(entry.key);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _obtenerColor(index),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text('${entry.key}: ${entry.value.hectareas.toStringAsFixed(1)} Ha'),
          ],
        );
      }).toList(),
    );
  }
}

class _DatosCultivo {
  double hectareas = 0;

  void agregar(Siembra siembra) {
    hectareas += siembra.hectareasSembradas;
  }
}