//lib/plugins/sensores/vistas/widgets/sensores_menu.dart
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/temas/tema_personalizado.dart';

class SensoresMenu extends StatelessWidget {
  final Function(String) onRutaSeleccionada;
  final String rutaActual;

  const SensoresMenu({
    super.key,
    required this.onRutaSeleccionada,
    required this.rutaActual,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: Icon(MdiIcons.gauge, color: ColoresTema.accent1),
      title: const Text('Sensores'),
      initiallyExpanded: rutaActual.contains('/sensores/'),
      children: [
        ExpansionTile(
          leading: Icon(MdiIcons.factoryIcon),
          title: const Text('Proceso'),
          children: [
            ListTile(
              leading: Icon(MdiIcons.scaleBalance),
              title: const Text('Báscula'),
              selected: rutaActual == '/sensores/proceso/bascula',
              onTap: () => onRutaSeleccionada('/sensores/proceso/bascula'),
            ),
            ListTile(
              leading: Icon(MdiIcons.truckDelivery),
              title: const Text('Recepción'),
              selected: rutaActual == '/sensores/proceso/recepcion',
              onTap: () => onRutaSeleccionada('/sensores/proceso/recepcion'),
            ),
            ListTile(
              leading: Icon(MdiIcons.waterBoiler),
              title: const Text('Esterilización'),
              selected: rutaActual == '/sensores/proceso/esterilizacion',
              onTap: () => onRutaSeleccionada('/sensores/proceso/esterilizacion'),
            ),
            ExpansionTile(
              leading: Icon(MdiIcons.engine),
              title: const Text('Extracción'),
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.only(left: 72),
                  title: const Text('Digestor - Prensa 1'),
                  selected: rutaActual == '/sensores/proceso/extraccion/1',
                  onTap: () => onRutaSeleccionada('/sensores/proceso/extraccion/1'),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.only(left: 72),
                  title: const Text('Digestor - Prensa 2'),
                  selected: rutaActual == '/sensores/proceso/extraccion/2',
                  onTap: () => onRutaSeleccionada('/sensores/proceso/extraccion/2'),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.only(left: 72),
                  title: const Text('Digestor - Prensa 3'),
                  selected: rutaActual == '/sensores/proceso/extraccion/3',
                  onTap: () => onRutaSeleccionada('/sensores/proceso/extraccion/3'),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.only(left: 72),
                  title: const Text('Digestor - Prensa 4'),
                  selected: rutaActual == '/sensores/proceso/extraccion/4',
                  onTap: () => onRutaSeleccionada('/sensores/proceso/extraccion/4'),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.only(left: 72),
                  title: const Text('Digestor - Prensa 5'),
                  selected: rutaActual == '/sensores/proceso/extraccion/5',
                  onTap: () => onRutaSeleccionada('/sensores/proceso/extraccion/5'),
                ),
              ],
            ),
            ListTile(
              leading: Icon(MdiIcons.fruitCherries),
              title: const Text('Desfrutado'),
              selected: rutaActual == '/sensores/proceso/desfrutado',
              onTap: () => onRutaSeleccionada('/sensores/proceso/desfrutado'),
            ),
            ListTile(
              leading: Icon(MdiIcons.blenderOutline),
              title: const Text('Desfibración'),
              selected: rutaActual == '/sensores/proceso/desfibracion',
              onTap: () => onRutaSeleccionada('/sensores/proceso/desfibracion'),
            ),
            ListTile(
              leading: Icon(MdiIcons.filterOutline),
              title: const Text('Clasificación'),
              selected: rutaActual == '/sensores/proceso/clasificacion',
              onTap: () => onRutaSeleccionada('/sensores/proceso/clasificacion'),
            ),
            ListTile(
              leading: Icon(MdiIcons.seedOutline),
              title: const Text('Palmistería'),
              selected: rutaActual == '/sensores/proceso/palmisteria',
              onTap: () => onRutaSeleccionada('/sensores/proceso/palmisteria'),
            ),
            ListTile(
              leading: Icon(MdiIcons.oilLamp),
              title: const Text('PKO'),
              selected: rutaActual == '/sensores/proceso/pko',
              onTap: () => onRutaSeleccionada('/sensores/proceso/pko'),
            ),
            ListTile(
              leading: Icon(MdiIcons.grass),
              title: const Text('Tusas'),
              selected: rutaActual == '/sensores/proceso/tusas',
              onTap: () => onRutaSeleccionada('/sensores/proceso/tusas'),
            ),
          ],
        ),
        ListTile(
          leading: Icon(MdiIcons.chartLine),
          title: const Text('Tendencias'),
          selected: rutaActual == '/sensores/tendencias',
          onTap: () => onRutaSeleccionada('/sensores/tendencias'),
        ),
        ListTile(
          leading: Icon(MdiIcons.wrench),
          title: const Text('Mantenimiento'),
          selected: rutaActual == '/sensores/mantenimiento',
          onTap: () => onRutaSeleccionada('/sensores/mantenimiento'),
        ),
        ListTile(
          leading: Icon(MdiIcons.package),
          title: const Text('Producción'),
          selected: rutaActual == '/sensores/produccion',
          onTap: () => onRutaSeleccionada('/sensores/produccion'),
        ),
      ],
    );
  }
}