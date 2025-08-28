// lib/plugins/peladoras/vistas/widgets/peladoras_menu.dart
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../../core/temas/tema_personalizado.dart';

class PeladorasMenu extends StatelessWidget {
  final String rutaActual;
  final Function(String) onRutaSeleccionada;

  const PeladorasMenu({
    super.key,
    required this.rutaActual,
    required this.onRutaSeleccionada,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: Icon(MdiIcons.accountGroup, color: ColoresTema.accent1),
      title: const Text('Peladoras'),
      initiallyExpanded: rutaActual.startsWith('/peladoras/'),
      children: [
        ListTile(
          leading: Icon(MdiIcons.viewDashboard),
          title: const Text('Dashboard'),
          selected: rutaActual == '/peladoras/dashboard',
          onTap: () => onRutaSeleccionada('/peladoras/dashboard'),
          selectedColor: ColoresTema.accent1,
        ),
      ],
    );
  }
}