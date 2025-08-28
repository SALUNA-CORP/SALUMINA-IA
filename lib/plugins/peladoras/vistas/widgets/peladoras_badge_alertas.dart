// lib/plugins/peladoras/vistas/widgets/badge_alertas.dart
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../modelos/peladoras_estadisticas.dart';
import '../../../../core/temas/tema_personalizado.dart';

class BadgeAlertas extends StatefulWidget {
  final EstadisticasPeladora estadisticas;
  
  const BadgeAlertas({super.key, required this.estadisticas});
  
  @override
  State<BadgeAlertas> createState() => _BadgeAlertasState();
}

class _BadgeAlertasState extends State<BadgeAlertas> {
  List<Widget> _construirResumenAlertas() {
    final alertas = [
      if (!widget.estadisticas.activo)
        ('⛔ Peladora Inactiva', NivelAlerta.alta),
      
      if (widget.estadisticas.eficiencia < 70)
        ('📉 Eficiencia Crítica: ${widget.estadisticas.eficiencia.toStringAsFixed(1)}%', NivelAlerta.alta),
      
      if (widget.estadisticas.diasMeta == 0)
        ('🎯 No ha alcanzado ninguna meta diaria', NivelAlerta.alta),
        
      if ((widget.estadisticas.diasMeta / widget.estadisticas.diasTrabajados * 100) < 50)
        ('📊 Bajo cumplimiento de metas', NivelAlerta.media),
        
      if (widget.estadisticas.metricas.consistencia < 70)
        ('⚖️ Baja consistencia en producción', NivelAlerta.media),
        
      if (widget.estadisticas.metricas.cumplimientoHorario < 80)
        ('⏰ Incumplimiento horario', NivelAlerta.media),
        
      if ((widget.estadisticas.totalCosto / widget.estadisticas.totalKg) > 250)
        ('💰 Costo por kg elevado', NivelAlerta.alta),
    ];

    return alertas.map((alerta) => 
      ListTile(
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
      )
    ).toList();
  }

    @override
  Widget build(BuildContext context) {
    final alertas = _construirResumenAlertas();
    if (alertas.isEmpty) return const SizedBox.shrink();

    final alertasCriticas = alertas.where((w) => 
      w is ListTile && w.leading is Icon && 
      (w.leading as Icon).icon == MdiIcons.alertCircle
    ).length;

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
              ...alertas,
            ],
          ),
        ),
      ],
    );
  }
}