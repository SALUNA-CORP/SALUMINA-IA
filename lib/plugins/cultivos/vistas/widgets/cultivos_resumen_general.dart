//lib/plugins/cultivos/vistas/widgets/cultivos_resumen_general.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../modelos/cultivos_models.dart';
import '../../../../core/temas/tema_personalizado.dart';

class ResumenGeneral extends StatelessWidget {
  final List<Siembra> siembras;

  const ResumenGeneral({super.key, required this.siembras});

  @override
  Widget build(BuildContext context) {
    final resumen = _calcularResumen();
    final formatoMoneda = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _buildMetrica(
                'Hectáreas Sembradas',
                resumen.hectareasSembradas.toStringAsFixed(1),
                'Ha',
                MdiIcons.cropSquare,
                ColoresTema.accent1,
              ),
            ),
            const VerticalDivider(),
            Expanded(
              child: _buildMetrica(
                'Inversión Total',
                formatoMoneda.format(resumen.inversionTotal),
                '',
                MdiIcons.cashMultiple,
                ColoresTema.accent2,
              ),
            ),
            const VerticalDivider(),
            Expanded(
              child: _buildMetrica(
                'Producción',
                NumberFormat('#,###').format(resumen.kgCosechados),
                'Kg',
                MdiIcons.weightKilogram,
                ColoresTema.success,
              ),
            ),
            const VerticalDivider(),
            Expanded(
              child: _buildMetrica(
                'Siembras Activas',
                siembras.length.toString(),
                '',
                MdiIcons.sprout,
                ColoresTema.warning,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetrica(String titulo, String valor, String unidad, IconData icono, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icono, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          titulo,
          style: TextStyle(color: ColoresTema.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          '$valor ${unidad.isNotEmpty ? unidad : ''}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  _ResumenData _calcularResumen() {
    double hectareasSembradas = 0;
    double inversionTotal = 0;
    double kgCosechados = 0;

    for (var siembra in siembras) {
      hectareasSembradas += siembra.hectareasSembradas;
      inversionTotal += siembra.inversionActual;
      kgCosechados += siembra.kgCosechados;
    }

    return _ResumenData(
      hectareasSembradas: hectareasSembradas,
      inversionTotal: inversionTotal,
      kgCosechados: kgCosechados,
    );
  }
}

class _ResumenData {
  final double hectareasSembradas;
  final double inversionTotal;
  final double kgCosechados;

  _ResumenData({
    required this.hectareasSembradas,
    required this.inversionTotal,
    required this.kgCosechados,
  });
}