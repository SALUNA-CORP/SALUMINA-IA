//lib/plugins/sensores/vistas/monitoreo/sensores_vista_maquina.dart
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:intl/intl.dart';
import '../../servicios/sensores_api_modbus.dart';
import '../../modelos/sensores_modbus_data.dart';
import '../../modelos/sensores_elemento_proceso.dart';
import '../../modelos/sensores_proceso_data.dart'; // Añadido
import 'widgets/sensores_proceso_widget.dart';
import '../../../../core/temas/tema_personalizado.dart';

class VistaMaquina extends StatefulWidget {
  const VistaMaquina({super.key});

  @override
  State<VistaMaquina> createState() => _VistaMaquinaState();
}

class _VistaMaquinaState extends State<VistaMaquina> {
  final _api = GetIt.instance<SensoresApiModbus>();
  final _transformationController = TransformationController();
  ElementoProceso? _elementoSeleccionado;
  ModbusData? _datosModbus;
  bool _cargando = true;
  bool _actualizacionAutomatica = true;
  DateTime? _ultimaActualizacion;
  late final ProcesoIndustrial _procesoActual;
  
  @override
  void initState() {
    super.initState();
    _procesoActual = procesos.first; // Usando la lista de procesos importada
    _iniciarActualizaciones();
  }

  Future<void> _iniciarActualizaciones() async {
    await _actualizarDatos();
    _api.streamDatosModbus().listen((datos) {
      if (mounted && _actualizacionAutomatica && datos.isNotEmpty) {
        setState(() {
          _datosModbus = datos.first;
          _ultimaActualizacion = DateTime.now();
        });
      }
    });
  }

  Future<void> _actualizarDatos() async {
    try {
      final datos = await _api.obtenerUltimosRegistros();
      if (mounted && datos.isNotEmpty) {
        setState(() {
          _datosModbus = datos.first;
          _ultimaActualizacion = DateTime.now();
          _cargando = false;
        });
      }
    } catch (e) {
      print('Error actualizando datos: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar datos: $e'),
            backgroundColor: ColoresTema.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return Center(
        child: CircularProgressIndicator(color: ColoresTema.accent1),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_procesoActual.nombre),
        actions: [
          IconButton(
            icon: Icon(
              _actualizacionAutomatica ? MdiIcons.syncCircle : MdiIcons.syncOff,
              color: ColoresTema.accent1,
            ),
            onPressed: () => setState(() => 
              _actualizacionAutomatica = !_actualizacionAutomatica
            ),
            tooltip: 'Alternar actualización automática',
          ),
          if (!_actualizacionAutomatica)
            IconButton(
              icon: Icon(MdiIcons.refresh),
              onPressed: _actualizarDatos,
              tooltip: 'Actualizar datos',
            ),
          if (_ultimaActualizacion != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Última actualización: ${DateFormat('HH:mm:ss').format(_ultimaActualizacion!)}',
                  style: TextStyle(color: ColoresTema.textSecondary),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          InteractiveViewer(
            transformationController: _transformationController,
            boundaryMargin: const EdgeInsets.all(20),
            minScale: 0.5,
            maxScale: 4.0,
            child: ProcesoIndustrialWidget(
              proceso: _procesoActual,
              datos: _datosModbus!,
              elementoSeleccionado: _elementoSeleccionado,
              onTapElemento: (elemento) => setState(() => 
                _elementoSeleccionado = elemento
              ),
            ),
          ),
          
          // Controles de zoom
          Positioned(
            right: 16,
            top: 16,
            child: Column(
              children: [
                FloatingActionButton.small(
                  onPressed: () => _ajustarZoom(1.2),
                  child: Icon(MdiIcons.plus),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  onPressed: () => _ajustarZoom(0.8),
                  child: Icon(MdiIcons.minus),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  onPressed: _resetearVista,
                  child: Icon(MdiIcons.refresh),
                ),
              ],
            ),
          ),
          
          // Panel de detalles del elemento seleccionado
          if (_elementoSeleccionado != null)
            Positioned(
              right: 16,
              bottom: 16,
              child: Card(
                child: Container(
                  width: 300,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _elementoSeleccionado!.nombre,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: Icon(MdiIcons.close),
                            onPressed: () => setState(() => 
                              _elementoSeleccionado = null
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      ..._elementoSeleccionado!.propiedades.entries.map((prop) =>
                        ListTile(
                          dense: true,
                          title: Text(prop.key),
                          trailing: Text(_formatearValor(prop.value, prop.key)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _ajustarZoom(double factor) {
    final newZoom = _transformationController.value.scaled(factor);
    _transformationController.value = newZoom;
  }

  void _resetearVista() {
    _transformationController.value = Matrix4.identity();
  }

  String _formatearValor(dynamic valor, String propiedad) {
    if (valor is bool) return valor ? 'Activo' : 'Inactivo';
    if (valor is num) {
      if (propiedad.contains('temperatura')) return '${valor.toStringAsFixed(1)}°C';
      if (propiedad.contains('presion')) return '${valor.toStringAsFixed(1)} PSI';
      if (propiedad.contains('nivel')) return '${valor.toStringAsFixed(1)}%';
      if (propiedad.contains('velocidad')) return '${valor.toStringAsFixed(0)} RPM';
      if (propiedad.contains('amperaje')) return '${valor.toStringAsFixed(1)} A';
      if (propiedad.contains('produccion')) return '${valor.toStringAsFixed(1)} Ton/h';
      return valor.toStringAsFixed(1);
    }
    return valor.toString();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }
}