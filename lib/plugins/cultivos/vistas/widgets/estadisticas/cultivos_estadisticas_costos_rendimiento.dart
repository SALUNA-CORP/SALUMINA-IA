//lib/plugins/cultivos/vistas/widgets/estadisticas/cultivos_estadisticas_costos_rendimiento.dart

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:intl/intl.dart';
import '../../../servicios/cultivos_service.dart';
import '../../../modelos/cultivos_models.dart';
import '../../../../../core/temas/tema_personalizado.dart';

class CultivosEstadisticasCostosRendimiento extends StatefulWidget {
  const CultivosEstadisticasCostosRendimiento({super.key});

  @override
  State<CultivosEstadisticasCostosRendimiento> createState() => _CultivosEstadisticasCostosRendimientoState();
}

class _CultivosEstadisticasCostosRendimientoState extends State<CultivosEstadisticasCostosRendimiento> {
  bool _mostrarRendimientoVsCosto = true;
  bool _mostrarCostoHectarea = true;
  final formatoMoneda = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);
  final formatoNumero = NumberFormat('#,##0', 'es_CO');

  String formatearNumero(double valor) {
    return valor.toStringAsFixed(0)
      .replaceAll(RegExp(r'\.'), ',')
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }

  String formatearMoneda(double valor) {
    return '\$${formatearNumero(valor)}';
  }

  @override
  Widget build(BuildContext context) {
    final servicio = GetIt.I<CultivosService>();

    return Card(
      child: Container(
        height: 500,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(MdiIcons.chartBubble, color: ColoresTema.accent1),
                    const SizedBox(width: 8),
                    Text(
                      _mostrarRendimientoVsCosto
                        ? 'Rendimiento vs Costos'
                        : 'Costo/Kg vs Hectáreas',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(_mostrarRendimientoVsCosto ? 'Rendimiento' : 'Costo/Kg'),
                    Switch(
                      value: _mostrarRendimientoVsCosto,
                      onChanged: (value) => setState(() {
                        _mostrarRendimientoVsCosto = value;
                        if (!value) _mostrarCostoHectarea = true;
                      }),
                    ),
                    if (_mostrarRendimientoVsCosto) ...[
                      const SizedBox(width: 16),
                      Text(_mostrarCostoHectarea ? 'Costo/Ha' : 'Costo/Kg'),
                      Switch(
                        value: _mostrarCostoHectarea,
                        onChanged: (value) => setState(() => _mostrarCostoHectarea = value),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<List<Siembra>>(
                stream: servicio.streamSiembrasFiltradas(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final siembras = snapshot.data!
                    .where((s) => s.hectareasCosechadas > 0)
                    .toList();

                  if (siembras.isEmpty) {
                    return Center(
                      child: Text(
                        'No hay datos disponibles',
                        style: TextStyle(color: ColoresTema.textSecondary),
                      ),
                    );
                  }

                  return Column(
                    children: [
                      Expanded(
                        child: ScatterChart(
                          ScatterChartData(
                            scatterSpots: _crearPuntos(siembras),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 80,
                                  interval: 5000,
                                  getTitlesWidget: (value, meta) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: Text(
                                        _mostrarRendimientoVsCosto
                                          ? formatearNumero(value)
                                          : formatearMoneda(value),
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
                                  reservedSize: 60,
                                  interval: _mostrarRendimientoVsCosto ? 1000000 : 1,
                                  getTitlesWidget: (value, meta) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        _mostrarRendimientoVsCosto
                                          ? formatearMoneda(value)
                                          : formatearNumero(value),
                                        style: TextStyle(
                                          color: ColoresTema.textSecondary,
                                          fontSize: 10,
                                        ),
                                      ),
                                    );
                                  },
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
                              drawHorizontalLine: true,
                              drawVerticalLine: true,
                              horizontalInterval: _mostrarRendimientoVsCosto ? 5000 : 200,
                              verticalInterval: _mostrarRendimientoVsCosto ? 1000000 : 1,
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
                            borderData: FlBorderData(show: false),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildLeyenda(siembras),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<ScatterSpot> _crearPuntos(List<Siembra> siembras) {
    final maxArea = siembras.map((s) => s.hectareasSembradas).reduce((a, b) => a > b ? a : b);
    
    return siembras.map((siembra) {
      final tamanoRelativo = ((siembra.hectareasSembradas / maxArea) * 18 + 6).clamp(8.0, 24.0);
      final color = _obtenerColorTipo(siembra.tipo.nombre);
      
      if (_mostrarRendimientoVsCosto) {
        double x = _mostrarCostoHectarea 
          ? siembra.costoHectarea 
          : siembra.costoKilogramo;
        return ScatterSpot(
          x,
          siembra.kgPorHectareaCosechada,
          dotPainter: FlDotCirclePainter(
            color: color.withOpacity(0.5),
            strokeWidth: 1,
            strokeColor: color,
            radius: tamanoRelativo,
          ),
        );
      } else {
        return ScatterSpot(
          siembra.hectareasCosechadas,
          siembra.costoKilogramo,
          dotPainter: FlDotCirclePainter(
            color: color.withOpacity(0.5),
            strokeWidth: 1,
            strokeColor: color,
            radius: tamanoRelativo,
          ),
        );
      }
    }).toList();
  }

  Color _obtenerColorTipo(String tipo) {
    switch (tipo.toUpperCase()) {
      case 'YUCA':
        return ColoresTema.accent1;
      case 'PLATANO':
        return ColoresTema.accent2;
      default:
        return ColoresTema.warning;
    }
  }

  Widget _buildLeyenda(List<Siembra> siembras) {
    final tiposUnicos = siembras.map((s) => s.tipo.nombre).toSet().toList();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: tiposUnicos.asMap().entries.map((entry) {
        final tipo = entry.value;
        final color = _obtenerColorTipo(tipo);
        final siembrasTipo = siembras.where((s) => s.tipo.nombre == tipo);
        final promedioRendimiento = siembrasTipo
          .map((s) => s.kgPorHectareaCosechada)
          .reduce((a, b) => a + b) / siembrasTipo.length;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: _buildLeyendaItem(tipo, color, promedioRendimiento),
        );
      }).toList(),
    );
  }

  Widget _buildLeyendaItem(String texto, Color color, double rendimiento) {
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
        Text(
          '$texto (${formatearNumero(rendimiento)} Kg/Ha)',
          style: TextStyle(color: ColoresTema.textSecondary),
        ),
      ],
    );
  }
}