//lib/plugins/cultivos/vistas/widgets/estadisticas/cultivos_estadisticas_kpis.dart

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../servicios/cultivos_service.dart';
import '../../../modelos/cultivos_models.dart';
import '../../../../../core/temas/tema_personalizado.dart';

class CultivosEstadisticasKPIs extends StatefulWidget {
  const CultivosEstadisticasKPIs({super.key});

  @override
  State<CultivosEstadisticasKPIs> createState() => _CultivosEstadisticasKPIsState();
}

class _CultivosEstadisticasKPIsState extends State<CultivosEstadisticasKPIs> {
  final _servicio = GetIt.I<CultivosService>();
  late final formatoMoneda = NumberFormat.currency(
    locale: 'es_CO',
    symbol: '\$',
    decimalDigits: 0,
    customPattern: '#,##0'
  );

  late final formatoNumero = NumberFormat.decimalPattern('es_CO');

  String formatearNumero(double valor, {int decimales = 2}) {
    return valor.toStringAsFixed(decimales)
      .replaceAll(RegExp(r'\.'), ',')
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }

  String formatearMoneda(double valor) {
    return '\$${formatearNumero(valor, decimales: 0)}';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return StreamBuilder<List<Siembra>>(
      stream: _servicio.streamSiembrasFiltradas(),
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

        final kpis = _calcularKPIs(siembras);

        if (isMobile) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _buildKPICards(kpis),
              ),
            ),
          );
        }

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _buildKPICards(kpis)
                .map((widget) => Expanded(child: widget))
                .toList(),
          ),
        );
      },
    );
  }

  Map<String, dynamic> _calcularKPIs(List<Siembra> siembras) {
    double totalHectareas = 0;
    double totalInversion = 0;
    double totalKilos = 0;
    double totalRendimiento = 0;
    int totalSiembras = siembras.length;
    int siembrasActivas = 0;

    for (var siembra in siembras) {
      totalHectareas += siembra.hectareasSembradas;
      totalInversion += siembra.inversionActual;
      totalKilos += siembra.kgCosechados;
      
      if (siembra.hectareasCosechadas > 0) {
        totalRendimiento += siembra.kgPorHectareaCosechada;
      }
      
      if (!siembra.estado.nombre.toUpperCase().contains('FINALIZADO')) {
        siembrasActivas++;
      }
    }

    final promedioRendimiento = siembras.where((s) => s.hectareasCosechadas > 0).length > 0
      ? totalRendimiento / siembras.where((s) => s.hectareasCosechadas > 0).length
      : 0;

    return {
      'totalHectareas': totalHectareas,
      'totalInversion': totalInversion,
      'totalKilos': totalKilos,
      'promedioRendimiento': promedioRendimiento,
      'totalSiembras': totalSiembras,
      'siembrasActivas': siembrasActivas,
    };
  }

  List<Widget> _buildKPICards(Map<String, dynamic> kpis) {
    return [
      _buildKPICard(
        'Hectáreas Sembradas',
        formatearNumero(kpis['totalHectareas']),
        'Ha',
        MdiIcons.cropSquare,
        ColoresTema.accent1,
        subtexto: '${kpis['siembrasActivas']} cultivos activos',
      ),
      _buildKPICard(
        'Inversión Total',
        formatearMoneda(kpis['totalInversion']),
        '',
        MdiIcons.cashMultiple,
        ColoresTema.accent2,
        subtexto: '${formatearMoneda(kpis['totalInversion'] / kpis['totalHectareas'])} / Ha',
      ),
      _buildKPICard(
        'Producción',
        formatearNumero(kpis['totalKilos']),
        'Kg',
        MdiIcons.weight,
        ColoresTema.success,
        subtexto: '${formatearNumero(kpis['promedioRendimiento'])} Kg/Ha promedio',
      ),
      _buildKPICard(
        'Cultivos',
        kpis['totalSiembras'].toString(),
        '',
        MdiIcons.sprout,
        ColoresTema.warning,
        subtexto: '${kpis['siembrasActivas']} activos',
      ),
    ];
  }

  Widget _buildKPICard(
      String titulo, String valor, String unidad, IconData icono, Color color,
      {String? subtexto}) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 200),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icono,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: TextStyle(
                        color: ColoresTema.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$valor ${unidad.isNotEmpty ? unidad : ''}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (subtexto != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtexto,
                        style: TextStyle(
                          color: ColoresTema.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}