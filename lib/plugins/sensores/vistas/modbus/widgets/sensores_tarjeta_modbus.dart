// lib/plugins/sensores/vistas/modbus/widgets/sensores_tarjeta_modbus.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/temas/tema_personalizado.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class SensoresTarjetaModbus extends StatelessWidget {
  final String nombre;
  final int valor;
  final DateTime fecha;

  const SensoresTarjetaModbus({
    super.key,
    required this.nombre,
    required this.valor,
    required this.fecha,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: ColoresTema.accent1.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              nombre,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Center(
              child: Text(
                valor.toString(),
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: ColoresTema.accent1,
                ),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  MdiIcons.clockOutline,
                  size: 16,
                  color: ColoresTema.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat('HH:mm:ss').format(fecha),
                  style: TextStyle(
                    fontSize: 12,
                    color: ColoresTema.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}