//lib/plugins/cultivos/vistas/widgets/grafico_meta_rendimiento.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../modelos/cultivos_models.dart';
import '../../../../core/temas/tema_personalizado.dart';

class GraficoMetaRendimiento extends StatelessWidget {
  final Siembra siembra;
  
  const GraficoMetaRendimiento({
    super.key, 
    required this.siembra,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(MdiIcons.targetAccount, color: ColoresTema.accent1),
                const SizedBox(width: 8),
                const Text('Cumplimiento de Metas',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            _buildMetricasPresupuesto(),
            const SizedBox(height: 16),
            _buildMetricasProduccion(),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricasPresupuesto() {
    final formatoMoneda = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);
    final esYuca = siembra.tipo.nombre.toLowerCase().contains('yuca');
    final presupuestoMeta = esYuca ? 15000000.0 : 30000000.0;
    final porcentajePresupuesto = (siembra.costoHectarea / presupuestoMeta * 100).clamp(0, 100);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(MdiIcons.cash, color: ColoresTema.accent1, size: 16),
            const SizedBox(width: 8),
            const Text('Presupuesto por Hectárea'),
            const Spacer(),
            Text('${porcentajePresupuesto.toStringAsFixed(1)}%'),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: siembra.costoHectarea / presupuestoMeta,
          backgroundColor: ColoresTema.accent1.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(ColoresTema.accent1),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Actual: ${formatoMoneda.format(siembra.costoHectarea)}',
              style: TextStyle(color: ColoresTema.textSecondary, fontSize: 12),
            ),
            Text(
              'Meta: ${formatoMoneda.format(presupuestoMeta)}',
              style: TextStyle(color: ColoresTema.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricasProduccion() {
    final formatoNumero = NumberFormat('#,##0');
    const kgMetaPorHa = 20000.0;
    final kgPorHa = siembra.hectareasCosechadas > 0 ? 
      siembra.kgCosechados / siembra.hectareasCosechadas : 0;
    final porcentajeProduccion = (kgPorHa / kgMetaPorHa * 100).clamp(0, 100);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(MdiIcons.weightKilogram, color: ColoresTema.accent2, size: 16),
            const SizedBox(width: 8),
            const Text('Producción por Hectárea'),
            const Spacer(),
            Text('${porcentajeProduccion.toStringAsFixed(1)}%'),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: kgPorHa / kgMetaPorHa,
          backgroundColor: ColoresTema.accent2.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(ColoresTema.accent2),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Actual: ${formatoNumero.format(kgPorHa)} Kg/Ha',
              style: TextStyle(color: ColoresTema.textSecondary, fontSize: 12),
            ),
            Text(
              'Meta: ${formatoNumero.format(kgMetaPorHa)} Kg/Ha',
              style: TextStyle(color: ColoresTema.textSecondary, fontSize: 12),
            ),
          ],
        ),
        if (siembra.hectareasCosechadas > 0) ...[
          const SizedBox(height: 16),
          Text(
            'Hectáreas Cosechadas: ${siembra.hectareasCosechadas.toStringAsFixed(1)} Ha',
            style: TextStyle(color: ColoresTema.textSecondary, fontSize: 12),
          ),
        ],
      ],
    );
  }
}