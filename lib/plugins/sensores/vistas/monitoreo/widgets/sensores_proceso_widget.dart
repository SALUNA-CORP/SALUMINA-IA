//lib/plugins/sensores/vistas/monitoreo/widgets/sensores_proceso_widget.dart
import 'package:flutter/material.dart';
import '../../../modelos/sensores_elemento_proceso.dart';
import '../../../modelos/sensores_modbus_data.dart';
import 'sensores_componente_maquina_widget.dart';

class ProcesoIndustrialWidget extends StatelessWidget {
  final ProcesoIndustrial proceso;
  final ModbusData datos;
  final Function(ElementoProceso)? onTapElemento;
  final ElementoProceso? elementoSeleccionado;

  const ProcesoIndustrialWidget({
    super.key,
    required this.proceso,
    required this.datos,
    this.onTapElemento,
    this.elementoSeleccionado,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: proceso.dimension.width,
      height: proceso.dimension.height,
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
      ),
      child: Stack(
        children: proceso.elementos.map((elemento) {
          final valores = _obtenerValoresModbus(elemento, datos);
          return Positioned(
            left: elemento.x,
            top: elemento.y,
            child: ComponenteMaquinaWidget(
              elemento: elemento,
              valores: valores,
              seleccionado: elemento == elementoSeleccionado,
              onTap: () => onTapElemento?.call(elemento),
            ),
          );
        }).toList(),
      ),
    );
  }

  Map<String, dynamic> _obtenerValoresModbus(ElementoProceso elemento, ModbusData datos) {
    final valores = <String, dynamic>{};
    
    elemento.registrosModbus?.forEach((propiedad, registro) {
      valores[propiedad] = datos.registers[registro];
    });

    // Valores por defecto si no hay datos
    if (!valores.containsKey('estado')) valores['estado'] = true;
    if (!valores.containsKey('alarma')) valores['alarma'] = false;

    return valores;
  }
}