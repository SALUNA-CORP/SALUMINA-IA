// lib/plugins/sensores/vistas/modbus/sensores_dashboard_modbus.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:intl/intl.dart';
import '../../servicios/sensores_api_modbus.dart';
import '../../modelos/sensores_modbus_data.dart';
import '../../../../core/temas/tema_personalizado.dart';
import 'widgets/sensores_tarjeta_modbus.dart';

class SensoresDashboardModbus extends StatefulWidget {
  const SensoresDashboardModbus({Key? key}) : super(key: key);

  @override
  State<SensoresDashboardModbus> createState() => _SensoresDashboardModbusState();
}

class _SensoresDashboardModbusState extends State<SensoresDashboardModbus> {
  final _api = GetIt.instance<SensoresApiModbus>();
  Timer? _timer;
  List<ModbusData> _datos = [];
  DateTime? _ultimaActualizacion;
  
  @override
  void initState() {
    super.initState();
    _cargarDatos();
    // Actualizar cada 5 segundos
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _cargarDatos());
  }

  Future<void> _cargarDatos() async {
    try {
      final datos = await _api.obtenerUltimosRegistros();
      if (mounted) {
        setState(() {
          _datos = datos;
          _ultimaActualizacion = DateTime.now();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: ColoresTema.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoreo Modbus'),
        backgroundColor: ColoresTema.cardBackground,
        actions: [
          if (_ultimaActualizacion != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Icon(
                      MdiIcons.update,
                      size: 16,
                      color: ColoresTema.accent1,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Última actualización: ${DateFormat('HH:mm:ss').format(_ultimaActualizacion!)}',
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          IconButton(
            icon: Icon(MdiIcons.refresh),
            onPressed: _cargarDatos,
            tooltip: 'Actualizar datos',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _cargarDatos,
        child: _datos.isEmpty
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _datos.first.registers.entries.where((entry) => entry.value != null).length,
                itemBuilder: (context, index) {
                  final registrosValidos = _datos.first.registers.entries.where((entry) => entry.value != null).toList();
                  final registro = registrosValidos[index];
                  return SensoresTarjetaModbus(
                    nombre: registro.key,
                    valor: registro.value!,
                    fecha: _datos.first.createdAt,
                  );
                },
              ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}