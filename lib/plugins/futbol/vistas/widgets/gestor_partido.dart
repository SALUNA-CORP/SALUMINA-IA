import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../servicios/servicio_futbol.dart';
import '../../modelos/equipo.dart';
import '../../../../core/temas/tema_personalizado.dart';
import 'package:intl/intl.dart';

class GestorPartido extends StatefulWidget {
  const GestorPartido({super.key});

  @override
  State<GestorPartido> createState() => _GestorPartidoState();
}

class _GestorPartidoState extends State<GestorPartido> {
  final _formKey = GlobalKey<FormState>();
  String? _equipoLocalId;
  String? _equipoVisitanteId;
  DateTime _fecha = DateTime.now();
  TimeOfDay _hora = TimeOfDay.now();

  bool _cargando = true;
  bool _guardando = false;
  List<Equipo> _equipos = [];

  @override
  void initState() {
    super.initState();
    _cargarEquipos();
  }

  Future<void> _cargarEquipos() async {
    try {
      final servicio = GetIt.I<ServicioFutbol>();
      final equipos = await servicio.obtenerEquipos();
      setState(() {
        _equipos = equipos;
        _cargando = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar equipos: $e'),
            backgroundColor: ColoresTema.error,
          ),
        );
      }
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_equipoLocalId == _equipoVisitanteId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Los equipos deben ser diferentes'),
          backgroundColor: ColoresTema.error,
        ),
      );
      return;
    }

    setState(() => _guardando = true);

    try {
      final servicio = GetIt.I<ServicioFutbol>();
      final fechaPartido = DateTime(
        _fecha.year,
        _fecha.month,
        _fecha.day,
        _hora.hour,
        _hora.minute,
      );

      await servicio.crearPartido(
        equipoLocalId: _equipoLocalId!,
        equipoVisitanteId: _equipoVisitanteId!,
        fecha: fechaPartido,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Partido creado correctamente'),
            backgroundColor: ColoresTema.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear partido: $e'),
            backgroundColor: ColoresTema.error,
          ),
        );
      }
    } finally {
      setState(() => _guardando = false);
    }
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (fecha != null) {
      setState(() => _fecha = fecha);
    }
  }

  Future<void> _seleccionarHora() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: _hora,
    );

    if (hora != null) {
      setState(() => _hora = hora);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(16),
        child: _cargando
            ? Center(
                child: CircularProgressIndicator(
                color: ColoresTema.accent1,
              ))
            : Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Programar Partido',
                      style: TextStyle(
                        color: ColoresTema.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _equipoLocalId,
                      decoration: const InputDecoration(
                        labelText: 'Equipo Local',
                      ),
                      items: _equipos.map((equipo) {
                        return DropdownMenuItem(
                          value: equipo.id,
                          child: Text(equipo.nombre),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _equipoLocalId = value);
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Seleccione el equipo local';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _equipoVisitanteId,
                      decoration: const InputDecoration(
                        labelText: 'Equipo Visitante',
                      ),
                      items: _equipos.map((equipo) {
                        return DropdownMenuItem(
                          value: equipo.id,
                          child: Text(equipo.nombre),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _equipoVisitanteId = value);
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Seleccione el equipo visitante';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _seleccionarFecha,
                            icon: const Icon(Icons.calendar_today),
                            label: Text(
                              DateFormat('dd/MM/yyyy').format(_fecha),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _seleccionarHora,
                            icon: const Icon(Icons.access_time),
                            label: Text(
                              _hora.format(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: _guardando
                              ? null
                              : () => Navigator.pop(context),
                          child: const Text('Cancelar'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _guardando ? null : _guardar,
                          child: _guardando
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(),
                                )
                              : const Text('Guardar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}