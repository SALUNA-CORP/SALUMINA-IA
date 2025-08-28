// lib/plugins/futbol/vistas/widgets/futbol_menu.dart
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../../core/temas/tema_personalizado.dart';

class FutbolMenu extends StatelessWidget {
  final String rutaActual;
  final Function(String) onRutaSeleccionada;

  const FutbolMenu({
    super.key,
    required this.rutaActual,
    required this.onRutaSeleccionada,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: Icon(MdiIcons.soccerField, color: ColoresTema.accent1),
      title: const Text('Fútbol'),
      initiallyExpanded: rutaActual.startsWith('/futbol/'),
      children: [
        ListTile(
          leading: Icon(MdiIcons.viewDashboard),
          title: const Text('Dashboard'),
          selected: rutaActual == '/futbol/dashboard',
          onTap: () => onRutaSeleccionada('/futbol/dashboard'),
          selectedColor: ColoresTema.accent1,
        ),
      ],
    );
  }
}
