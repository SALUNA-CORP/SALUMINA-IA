// lib/plugins/peladoras/vistas/widgets/tarjetas_resumen.dart
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../modelos/peladoras_toma.dart';
import '../../modelos/peladoras_estadisticas.dart';
import '../../utils/peladoras_calculadora_estadisticas.dart';
import '../../../../core/temas/tema_personalizado.dart';

class TarjetasResumen extends StatelessWidget {
  final List<Toma> tomas;

  const TarjetasResumen({super.key, required this.tomas});

  @override
  Widget build(BuildContext context) {
    final estadisticas = CalculadoraEstadisticas.procesarEstadisticas(tomas);
    final metricasResumen = _calcularResumen(estadisticas);

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _TarjetaMetrica(
          titulo: 'Total Producción',
          valor: '${metricasResumen.totalKg.toStringAsFixed(1)} Kg',
          icono: MdiIcons.weight, // Cambiado
          colorIcono: ColoresTema.accent1,
        ),
        _TarjetaMetrica(
          titulo: 'Promedio Diario',
          valor: '${metricasResumen.promedioDiario.toStringAsFixed(1)} Kg',
          icono: MdiIcons.chartBar, // Cambiado
          colorIcono: ColoresTema.accent2,
        ),
        
        _TarjetaMetrica(
          titulo: 'Eficiencia',
          valor: '${metricasResumen.eficiencia.toStringAsFixed(1)}%',
          icono: MdiIcons.gauge, // Cambiado
          colorIcono: _getEficienciaColor(metricasResumen.eficiencia),
          showProgress: true,
          progress: metricasResumen.eficiencia / 100,
        ),
        _TarjetaMetrica(
          titulo: 'Costo Total',
          valor: '\$${metricasResumen.totalCosto.toStringAsFixed(2)}',
          icono: MdiIcons.cashMultiple, // Cambiado
          colorIcono: ColoresTema.success,
        ),
      ],
    );
  }

  _MetricasResumen _calcularResumen(List<EstadisticasPeladora> estadisticas) {
    if (estadisticas.isEmpty) {
      return _MetricasResumen(
        totalKg: 0,
        totalCosto: 0,
        promedioDiario: 0,
        eficiencia: 0,
      );
    }

    final totalKg = estadisticas.fold<double>(
      0, 
      (sum, EstadisticasPeladora est) => sum + est.totalKg
    );
    
    final totalCosto = estadisticas.fold<double>(
      0, 
      (sum, EstadisticasPeladora est) => sum + est.totalCosto
    );
    
    final diasTrabajados = estadisticas
      .map((EstadisticasPeladora e) => e.diasTrabajados)
      .reduce((a, b) => a > b ? a : b);
    
    final eficienciaPromedio = estadisticas
      .map((EstadisticasPeladora e) => e.eficiencia)
      .reduce((a, b) => a + b) / estadisticas.length;
    
    return _MetricasResumen(
      totalKg: totalKg,
      totalCosto: totalCosto,
      promedioDiario: totalKg / diasTrabajados,
      eficiencia: eficienciaPromedio,
    );
  }

  Color _getEficienciaColor(double eficiencia) {
    if (eficiencia >= 90) return ColoresTema.success;
    if (eficiencia >= 70) return ColoresTema.warning;
    return ColoresTema.error;
  }
}

class _MetricasResumen {
  final double totalKg;
  final double totalCosto;
  final double promedioDiario;
  final double eficiencia;

  _MetricasResumen({
    required this.totalKg,
    required this.totalCosto,
    required this.promedioDiario,
    required this.eficiencia,
  });
}

class _TarjetaMetrica extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icono;
  final Color colorIcono;
  final bool showProgress;
  final double progress;

  const _TarjetaMetrica({
    required this.titulo,
    required this.valor,
    required this.icono,
    required this.colorIcono,
    this.showProgress = false,
    this.progress = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: colorIcono.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ColoresTema.cardBackground,
              ColoresTema.cardBackground.withOpacity(0.8),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icono, size: 32, color: colorIcono),
              const SizedBox(height: 8),
              Text(
                titulo,
                style: TextStyle(
                  fontSize: 14,
                  color: ColoresTema.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                valor,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: ColoresTema.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              if (showProgress) ...[
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: ColoresTema.border,
                  valueColor: AlwaysStoppedAnimation<Color>(colorIcono),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}