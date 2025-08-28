// lib/plugins/sensores/vistas/monitoreo/widgets/sensores_elemento_widget.dart
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../modelos/sensores_elemento_proceso.dart';
import '../../../../../core/temas/tema_personalizado.dart';

class ElementoProcesoWidget extends StatelessWidget {
  final ElementoProceso elemento;
  final Map<String, dynamic> valores;
  final VoidCallback? onTap;

  const ElementoProcesoWidget({
    super.key,
    required this.elemento,
    required this.valores,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: _getColorEstado(),
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(_getIcono(), color: ColoresTema.accent1),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      elemento.nombre,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  _buildEstadoIndicador(),
                ],
              ),
              const Divider(),
              _buildDetalles(),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIcono() {
    switch (elemento.tipo) {
      case TipoElemento.digestor:
        return MdiIcons.tank;
      case TipoElemento.valvula:
        return MdiIcons.valve;
      case TipoElemento.motor:
        return MdiIcons.engine;
      case TipoElemento.bomba:
        return MdiIcons.pump;
      case TipoElemento.caldera:
        return MdiIcons.waterBoiler;
      case TipoElemento.banda:
        return MdiIcons.factoryIcon; // Cambiado de conveyorBelt a factory
      case TipoElemento.desfibrador:
        return MdiIcons.blenderOutline;
      case TipoElemento.prensa:
        return MdiIcons.carBrakeHold;
      case TipoElemento.rensa:
        return MdiIcons.robotIndustrialOutline;
      case TipoElemento.sensor:
        return MdiIcons.gauge;
      case TipoElemento.tuberia:
        return MdiIcons.pipe;
      case TipoElemento.compuerta:
        return MdiIcons.gate;
    }
  }

  Color _getColorEstado() {
    if (valores['alarma'] == true) return ColoresTema.error;
    if (valores['estado'] == false) return ColoresTema.warning;
    return ColoresTema.success;
  }

  Widget _buildEstadoIndicador() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Color.fromRGBO(
          _getColorEstado().red,
          _getColorEstado().green,
          _getColorEstado().blue,
          0.2
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            valores['alarma'] == true ? MdiIcons.alertCircle :
            valores['estado'] == false ? MdiIcons.powerOff : MdiIcons.check,
            color: _getColorEstado(),
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            valores['alarma'] == true ? 'Alarma' :
            valores['estado'] == false ? 'Detenido' : 'Activo',
            style: TextStyle(
              color: _getColorEstado(),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetalles() {
    final detalles = <Widget>[];

    valores.forEach((key, value) {
      if (key != 'estado' && key != 'alarma') {
        detalles.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(key),
              Text(
                _formatValue(value, key),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      }
    });

    return Column(
      children: detalles,
    );
  }

  String _formatValue(dynamic value, String key) {
    if (value is double) {
      if (key.contains('temperatura')) return '${value.toStringAsFixed(1)}°C';
      if (key.contains('presion')) return '${value.toStringAsFixed(1)} PSI';
      if (key.contains('nivel')) return '${value.toStringAsFixed(1)}%';
      if (key.contains('velocidad')) return '${value.toStringAsFixed(1)} RPM';
      if (key.contains('corriente')) return '${value.toStringAsFixed(1)} A';
      if (key.contains('toneladas')) return '${value.toStringAsFixed(1)} Ton/h';
    }
    return value.toString();
  }
}