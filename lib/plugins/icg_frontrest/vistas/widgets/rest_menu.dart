// lib/plugins/icg_frontrest/vistas/widgets/icg_menu.dart
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../../../core/temas/tema_personalizado.dart';

class ICGMenu extends StatelessWidget {
  final String rutaActual;
  final Function(String) onRutaSeleccionada;

  const ICGMenu({
    super.key,
    required this.rutaActual,
    required this.onRutaSeleccionada,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: Icon(MdiIcons.cashRegister, color: ColoresTema.accent1),
      title: const Text('ICG'),
      initiallyExpanded: rutaActual.startsWith('/icg/'),
      children: [
        ListTile(
          leading: Icon(MdiIcons.cashCheck),
          title: const Text('Costos'),
          selected: rutaActual == '/icg/costos',
          onTap: () => onRutaSeleccionada('/icg/costos'),
          selectedColor: ColoresTema.accent1,
        ),
      ],
    );
  }
}