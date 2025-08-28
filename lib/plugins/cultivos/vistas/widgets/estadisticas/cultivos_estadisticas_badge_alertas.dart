// lib/plugins/cultivos/vistas/widgets/estadisticas/badge_alertas.dart

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../modelos/cultivos_models.dart';
import '../../../../../core/temas/tema_personalizado.dart';

enum NivelAlerta { alta(ColoresTema.error), media(ColoresTema.warning);
  final Color color;
  const NivelAlerta(this.color);
}

class BadgeAlertasCultivos extends StatelessWidget {
  final Siembra siembra;
  
  const BadgeAlertasCultivos({
    super.key, 
    required this.siembra,
  });

  @override
  Widget build(BuildContext context) {
    final alertas = _construirResumenAlertas();
    if (alertas.isEmpty) return const SizedBox.shrink();

    final alertasCriticas = alertas.where((alerta) => alerta.$2 == NivelAlerta.alta).length;

    return PopupMenuButton(
      offset: const Offset(0, 30),
      position: PopupMenuPosition.under,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: alertasCriticas > 0 ? ColoresTema.error : ColoresTema.warning,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              alertasCriticas > 0 ? MdiIcons.alertCircle : MdiIcons.informationOutline,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              alertas.length.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      itemBuilder: (_) => [
        PopupMenuItem(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(MdiIcons.bellRingOutline, 
                    color: ColoresTema.accent1,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Alertas Activas',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Divider(),
              ...alertas.map((alerta) => ListTile(
                dense: true,
                leading: Icon(
                  alerta.$2 == NivelAlerta.alta ? Icons.warning : Icons.info_outline,
                  color: alerta.$2.color,
                  size: 20,
                ),
                title: Text(
                  alerta.$1,
                  style: TextStyle(
                    color: alerta.$2.color,
                    fontSize: 14,
                  ),
                ),
              )).toList(),
            ],
          ),
        ),
      ],
    );
  }

  List<(String, NivelAlerta)> _construirResumenAlertas() {
    final alertas = <(String, NivelAlerta)>[];

    // Alertas de rendimiento
    if (siembra.kgPorHectareaCosechada < 15000 && siembra.hectareasCosechadas > 0) {
      alertas.add((
        '📉 Rendimiento bajo: ${siembra.kgPorHectareaCosechada.toStringAsFixed(0)} Kg/Ha',
        NivelAlerta.alta
      ));
    }

    // Alertas de presupuesto
    if (siembra.porcentajeInversion > 90) {
      alertas.add((
        '💰 Presupuesto al límite: ${siembra.porcentajeInversion.toStringAsFixed(1)}%',
        NivelAlerta.alta
      ));
    }

    // Alertas de cosecha
    if (siembra.porcentajeAreaCosechada < 50 && siembra.estado.nombre != 'FINALIZADO') {
      alertas.add((
        '🌱 Bajo avance de cosecha: ${siembra.porcentajeAreaCosechada.toStringAsFixed(1)}%',
        NivelAlerta.media
      ));
    }

    // Alertas de calidad (solo para yuca)
    if (siembra.tipo.nombre.toUpperCase() == 'YUCA') {
      if (siembra.porcentajePrimera < 40) {
        alertas.add((
          '⚖️ Baja calidad primera: ${siembra.porcentajePrimera.toStringAsFixed(1)}%',
          NivelAlerta.media
        ));
      }
    }

    return alertas;
  }
}