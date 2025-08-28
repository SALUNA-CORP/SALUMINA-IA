//lib/plugins/cultivos/vistas/widgets/cultivos_comparativa_fincas.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get_it/get_it.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../servicios/cultivos_service.dart';
import '../../modelos/cultivos_models.dart';
import '../../../../core/temas/tema_personalizado.dart';

class ComparativaFincas extends StatelessWidget {
  const ComparativaFincas({super.key});

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
        if (siembras.isEmpty) {
          return Center(
            child: Text('No hay datos disponibles',
              style: TextStyle(color: ColoresTema.textSecondary)),
          );
        }

        final datos = _procesarDatos(siembras);

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
                    Text('Rendimiento por Cultivo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ColoresTema.textPrimary,
                      )),
                  ],
                ),
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: _crearSecciones(datos),
                    ),
                  ),
                ),
                _crearLeyenda(datos),
              ],
            ),
          ),
        );
      },
    );
  }

  Map<String, _DatosCultivo> _procesarDatos(List<Siembra> siembras) {
    final datos = <String, _DatosCultivo>{};
    
    for (var siembra in siembras) {
      final tipo = siembra.tipo.nombre;
      datos.putIfAbsent(tipo, () => _DatosCultivo(tipo)).agregar(siembra);
    }
    
    return datos;
  }

  List<PieChartSectionData> _crearSecciones(Map<String, _DatosCultivo> datos) {
    final totalHectareas = datos.values
        .fold<double>(0, (sum, item) => sum + item.hectareas);

    final colores = [
      ColoresTema.accent1,
      ColoresTema.accent2,
      ColoresTema.success,
      ColoresTema.warning,
      ColoresTema.error,
    ];

    return datos.entries.map((entry) {
      final index = datos.keys.toList().indexOf(entry.key);
      final porcentaje = (entry.value.hectareas / totalHectareas) * 100;

      return PieChartSectionData(
        color: colores[index % colores.length],
        value: porcentaje,
        title: '${porcentaje.toStringAsFixed(1)}%',
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _crearLeyenda(Map<String, _DatosCultivo> datos) {
    final colores = [
      ColoresTema.accent1,
      ColoresTema.accent2,
      ColoresTema.success,
      ColoresTema.warning,
      ColoresTema.error,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: datos.entries.map((entry) {
        final index = datos.keys.toList().indexOf(entry.key);
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
              Text('${entry.key}: ${entry.value.hectareas.toStringAsFixed(1)} Ha',
                style: TextStyle(color: ColoresTema.textSecondary)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _DatosCultivo {
  final String tipo;
  double hectareas = 0;

  _DatosCultivo(this.tipo);

  void agregar(Siembra siembra) {
    hectareas += siembra.hectareasSembradas;
  }
}