// lib/plugins/sensores/vistas/monitoreo/widgets/badge_alertas.dart
import 'package:flutter/material.dart';
import '../../../modelos/sensores_historico_data.dart';
import '../../../../../core/temas/tema_personalizado.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:intl/intl.dart';

class BadgeAlertas extends StatelessWidget {
  final List<Alerta> alertas;

  const BadgeAlertas({super.key, required this.alertas});

  @override
  Widget build(BuildContext context) {
    if (alertas.isEmpty) return const SizedBox.shrink();

    final alertasCriticas = alertas.where((a) => a.nivel == NivelAlerta.alta).length;
    final color = alertasCriticas > 0 ? NivelAlerta.alta.color : NivelAlerta.media.color;

    return PopupMenuButton(
      offset: const Offset(0, 30),
      position: PopupMenuPosition.under,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color,
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
                  Icon(MdiIcons.bellRingOutline, color: ColoresTema.accent1),
                  const SizedBox(width: 8),
                  const Text(
                    'Alertas Activas',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Divider(),
              ...alertas.map((alerta) {
                final formatoFecha = DateFormat('HH:mm');
                return ListTile(
                  leading: Icon(
                    alerta.nivel == NivelAlerta.alta 
                      ? MdiIcons.alertCircle 
                      : MdiIcons.informationOutline,
                    color: alerta.nivel.color,
                  ),
                  title: Text(alerta.titulo),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(alerta.mensaje),
                      if (alerta.accion != null)
                        Text(
                          'Acción: ${alerta.accion!}',
                          style: TextStyle(color: ColoresTema.accent1),
                        ),
                      Text(
                        formatoFecha.format(alerta.fecha),
                        style: TextStyle(color: ColoresTema.textSecondary),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }
}