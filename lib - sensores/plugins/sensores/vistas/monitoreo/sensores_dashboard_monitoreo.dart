// lib/plugins/sensores/vistas/monitoreo/sensores_dashboard_monitoreo.dart
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:intl/intl.dart';
import '../../servicios/sensores_api_modbus.dart';
import '../../modelos/sensores_modbus_data.dart';
import '../../modelos/sensores_proceso_data.dart';
import 'widgets/sensores_proceso_widget.dart';
import '../../../../core/temas/tema_personalizado.dart';

class SensoresDashboardMonitoreo extends StatefulWidget {
  const SensoresDashboardMonitoreo({super.key});

  @override
  State<SensoresDashboardMonitoreo> createState() => _SensoresDashboardMonitoreoState();
}

class _SensoresDashboardMonitoreoState extends State<SensoresDashboardMonitoreo> {
  final _api = GetIt.instance<SensoresApiModbus>();
  String _procesoSeleccionado = 'extraccion';
  ModbusData? _ultimosDatos;
  bool _automatico = true;

  @override
  void initState() {
    super.initState();
    _iniciarActualizaciones();
  }

  Future<void> _iniciarActualizaciones() async {
    try {
      await _actualizarDatos();

      _api.streamDatosModbus().listen(
        (datos) {
          if (mounted && _automatico && datos.isNotEmpty) {
            setState(() {
              _ultimosDatos = datos.first;
            });
          }
        },
        onError: (e) {
          debugPrint('Error en stream Modbus: $e');
        },
      );
    } catch (e) {
      debugPrint('Error iniciando actualizaciones: $e');
    }
  }

  Future<void> _actualizarDatos() async {
    try {
      final datos = await _api.obtenerUltimosRegistros();
      if (mounted && datos.isNotEmpty) {
        setState(() {
          _ultimosDatos = datos.first;
        });
      }
    } catch (e) {
      debugPrint('Error actualizando datos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      backgroundColor: ColoresTema.background,
      appBar: AppBar(
        backgroundColor: ColoresTema.cardBackground,
        title: Text('Monitoreo', 
          style: TextStyle(color: ColoresTema.textPrimary),
        ),
        actions: [
          IconButton(
            icon: Icon(_automatico ? MdiIcons.syncCircle : MdiIcons.syncOff,
              color: ColoresTema.accent1,
            ),
            onPressed: () => setState(() => _automatico = !_automatico),
          ),
          if (!_automatico)
            IconButton(
              icon: Icon(MdiIcons.refresh, color: ColoresTema.accent2),
              onPressed: _actualizarDatos,
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Selector de proceso
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: ColoresTema.cardBackground,
              child: DropdownButtonFormField<String>(
                value: _procesoSeleccionado,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: ColoresTema.background,
                ),
                dropdownColor: ColoresTema.cardBackground,
                items: procesos.map((proceso) => 
                  DropdownMenuItem(
                    value: proceso.id,
                    child: Text(proceso.nombre,
                      style: TextStyle(color: ColoresTema.textPrimary),
                    ),
                  ),
                ).toList(),
                onChanged: (valor) {
                  if (valor != null) setState(() => _procesoSeleccionado = valor);
                },
              ),
            ),

            // Contenido principal
            Expanded(
              child: _ultimosDatos == null
                ? const Center(child: CircularProgressIndicator())
                : InteractiveViewer(
                    boundaryMargin: const EdgeInsets.all(20.0),
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: SingleChildScrollView(
                      scrollDirection: isPortrait ? Axis.vertical : Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ProcesoIndustrialWidget(
                          proceso: procesos.firstWhere(
                            (p) => p.id == _procesoSeleccionado,
                            orElse: () => procesos.first,
                          ),
                          datos: _ultimosDatos!,
                        ),
                      ),
                    ),
                  ),
            ),

            // Panel de estado
            Container(
              padding: const EdgeInsets.all(12),
              color: ColoresTema.cardBackground,
              child: Row(
                children: [
                  Icon(MdiIcons.information, 
                    color: ColoresTema.accent1,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text('Actualización: ${_ultimaActualizacion}',
                    style: TextStyle(color: ColoresTema.textPrimary),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _automatico ? ColoresTema.success : ColoresTema.warning,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _automatico ? 'Auto' : 'Manual',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _ultimaActualizacion {
    if (_ultimosDatos == null) return 'No disponible';
    final format = DateFormat('HH:mm:ss');
    return format.format(_ultimosDatos!.createdAt);
  }
}