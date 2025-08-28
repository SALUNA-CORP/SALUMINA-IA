//lib/plugins/sensores/vistas/monitoreo/widgets/sensores_componente_maquina_widget.dart
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../modelos/sensores_elemento_proceso.dart';
import '../../../../../core/temas/tema_personalizado.dart';

class ComponenteMaquinaWidget extends StatelessWidget {
  final ElementoProceso elemento;
  final bool seleccionado;
  final VoidCallback? onTap;
  final Map<String, dynamic> valores;

  const ComponenteMaquinaWidget({
    super.key,
    required this.elemento,
    required this.valores,
    this.seleccionado = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _obtenerColorFondo(),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: seleccionado ? ColoresTema.accent1 : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: ColoresTema.accent1.withOpacity(0.1),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _obtenerIcono(),
              color: _obtenerColorIcono(),
              size: 24,
            ),
            if (valores.containsKey('valor')) ...[
              const SizedBox(height: 4),
              Text(
                _formatearValor(valores['valor']),
                style: TextStyle(
                  color: ColoresTema.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              elemento.nombre,
              style: TextStyle(
                color: ColoresTema.textSecondary,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  IconData _obtenerIcono() {
    switch (elemento.tipo) {
      case TipoElemento.digestor:
        return MdiIcons.tank;
      case TipoElemento.valvula:
        return MdiIcons.valve;
      case TipoElemento.motor:
        return MdiIcons.engine;
      case TipoElemento.bomba:
        return MdiIcons.pump;
      case TipoElemento.sensor:
        return MdiIcons.gauge;
      case TipoElemento.tuberia:
        return MdiIcons.pipe;
      case TipoElemento.compuerta:
        return MdiIcons.gate;
      case TipoElemento.banda:
        return MdiIcons.elevator;
      case TipoElemento.desfibrador:
        return MdiIcons.blenderOutline;
      case TipoElemento.caldera:
        return MdiIcons.waterBoiler;
      case TipoElemento.prensa:
        return MdiIcons.carBrakeHold;
      case TipoElemento.rensa:
        return MdiIcons.robotIndustrialOutline;
    }
  }

  Color _obtenerColorFondo() {
    if (valores['alarma'] == true) {
      return ColoresTema.error.withOpacity(0.2);
    }
    if (valores['estado'] == false) {
      return ColoresTema.warning.withOpacity(0.2);
    }
    return ColoresTema.cardBackground;
  }

  Color _obtenerColorIcono() {
    if (valores['alarma'] == true) {
      return ColoresTema.error;
    }
    if (valores['estado'] == false) {
      return ColoresTema.warning;
    }
    return ColoresTema.accent1;
  }

  String _formatearValor(dynamic valor) {
    if (valor == null) return '';
    
    final nombre = elemento.nombre.toLowerCase();
    if (valor is num) {
      if (nombre.contains('temperatura')) return '${valor.toStringAsFixed(1)}°C';
      if (nombre.contains('presion')) return '${valor.toStringAsFixed(1)} PSI';
      if (nombre.contains('nivel')) return '${valor.toStringAsFixed(1)}%';
      if (nombre.contains('velocidad')) return '${valor.toStringAsFixed(0)} RPM';
      if (nombre.contains('amperaje')) return '${valor.toStringAsFixed(1)} A';
      if (nombre.contains('produccion')) return '${valor.toStringAsFixed(1)} Ton/h';
      return valor.toStringAsFixed(1);
    }
    
    return valor.toString();
  }
}