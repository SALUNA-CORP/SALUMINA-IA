// lib/plugins/cultivos/vistas/widgets/cultivos_menu.dart
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../../core/temas/tema_personalizado.dart';

class CultivosMenu extends StatelessWidget {
  final String rutaActual;
  final Function(String) onRutaSeleccionada;

  const CultivosMenu({
    super.key,
    required this.rutaActual,
    required this.onRutaSeleccionada,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: Icon(MdiIcons.sprout, color: ColoresTema.accent1),
      title: const Text('Cultivos'),
      initiallyExpanded: rutaActual.startsWith('/cultivos/'),
      children: [
        ListTile(
          leading: Icon(MdiIcons.viewDashboard),
          title: const Text('Dashboard'),
          selected: rutaActual == '/cultivos/dashboard',
          onTap: () => onRutaSeleccionada('/cultivos/dashboard'),
          selectedColor: ColoresTema.accent1,
        ),
        ListTile(
          leading: Icon(MdiIcons.chartBox),
          title: const Text('Estadísticas'),
          selected: rutaActual == '/cultivos/estadisticas',
          onTap: () => onRutaSeleccionada('/cultivos/estadisticas'),
          selectedColor: ColoresTema.accent1,
        ),
      ],
    );
  }
}
