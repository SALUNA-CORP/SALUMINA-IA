//lib/plugins/cultivos/vistas/widgets/cultivos_detalles_lote.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../modelos/cultivos_models.dart';
import '../../../../core/temas/tema_personalizado.dart';

class DetallesLote extends StatelessWidget {
  final Lote lote;

  const DetallesLote({super.key, required this.lote});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Lote ${lote.codigo}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('Área: ${lote.areaHectareas} hectáreas'),
                  ],
                ),
                if (lote.siembraActual != null)
                  _buildEstadoBadge(lote.siembraActual!),
              ],
            ),

            if (lote.siembraActual != null) ...[
              const SizedBox(height: 24),
              _buildInformacionCultivo(lote.siembraActual!),
              const SizedBox(height: 16),
              _buildMetricasRendimiento(lote.siembraActual!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEstadoBadge(Siembra siembra) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: siembra.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: siembra.color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(MdiIcons.sprout, size: 16, color: siembra.color),
          const SizedBox(width: 4),
          Text(siembra.tipo.nombre,
            style: TextStyle(color: siembra.color)),
        ],
      ),
    );
  }

  Widget _buildInformacionCultivo(Siembra siembra) {
    final formatoMoneda = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Avance de Inversión',
          style: TextStyle(
            color: ColoresTema.textSecondary,
            fontWeight: FontWeight.bold,
          )),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: siembra.porcentajeInversion / 100,
          backgroundColor: ColoresTema.accent1.withOpacity(0.1),
          valueColor: AlwaysStoppedAnimation<Color>(ColoresTema.accent1),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(formatoMoneda.format(siembra.inversionActual)),
            Text('${siembra.porcentajeInversion.toStringAsFixed(1)}%'),
          ],
        ),

        const SizedBox(height: 16),
        Text('Avance de Cosecha',
          style: TextStyle(
            color: ColoresTema.textSecondary,
            fontWeight: FontWeight.bold,
          )),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: siembra.hectareasCosechadas / siembra.hectareasSembradas,
          backgroundColor: ColoresTema.accent2.withOpacity(0.1),
          valueColor: AlwaysStoppedAnimation<Color>(ColoresTema.accent2),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${siembra.hectareasCosechadas} Ha cosechadas'),
            Text('${(siembra.hectareasCosechadas/siembra.hectareasSembradas*100).toStringAsFixed(1)}%'),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricasRendimiento(Siembra siembra) {
    final formatoMoneda = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Rendimiento',
          style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildMetrica(
                'Kg por Hectárea',
                '${(siembra.kgCosechados/siembra.hectareasCosechadas).toStringAsFixed(1)} Kg/Ha',
                MdiIcons.weightKilogram,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetrica(
                'Costo por Hectárea',
                formatoMoneda.format(siembra.costoHectarea),
                MdiIcons.cashMultiple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildMetrica(
                'Costo por Kilogramo',
                '${formatoMoneda.format(siembra.costoKilogramo)}/Kg',
                MdiIcons.scaleBalance,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetrica(
                'Total Cosechado',
                '${siembra.kgCosechados.toStringAsFixed(0)} Kg',
                MdiIcons.packageVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetrica(String titulo, String valor, IconData icono) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: ColoresTema.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ColoresTema.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, size: 16, color: ColoresTema.accent1),
              const SizedBox(width: 4),
              Expanded(
                child: Text(titulo,
                  style: TextStyle(
                    color: ColoresTema.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(valor,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}