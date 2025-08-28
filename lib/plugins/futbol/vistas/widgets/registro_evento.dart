import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../modelos/partido.dart';
import '../../modelos/evento_partido.dart';
import '../../servicios/servicio_futbol.dart';
import '../../../../core/temas/tema_personalizado.dart';

class RegistroEvento extends StatefulWidget {
  final Partido partido;

  const RegistroEvento({
    super.key, 
    required this.partido,
  });

  @override
  State<RegistroEvento> createState() => _RegistroEventoState();
}

class _RegistroEventoState extends State<RegistroEvento> {
  final _formKey = GlobalKey<FormState>();
  final _jugadorController = TextEditingController();
  int _minuto = 1;
  String? _equipoId;
  TipoEvento _tipoEvento = TipoEvento.gol;
  bool _guardando = false;

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    try {
      final servicio = GetIt.I<ServicioFutbol>();
      
      // Registrar el evento
      await servicio.registrarEvento(
        partidoId: widget.partido.id,
        equipoId: _equipoId!,
        jugador: _jugadorController.text,
        tipoEvento: _tipoEvento,
        minuto: _minuto,
      );

      // Si es un gol, actualizar el marcador
      if (_tipoEvento == TipoEvento.gol) {
        final golesLocal = widget.partido.golesLocal + 
          (_equipoId == widget.partido.equipoLocalId ? 1 : 0);
        final golesVisitante = widget.partido.golesVisitante + 
          (_equipoId == widget.partido.equipoVisitanteId ? 1 : 0);

        await servicio.actualizarPartido(
          partidoId: widget.partido.id,
          golesLocal: golesLocal,
          golesVisitante: golesVisitante,
          estado: widget.partido.estado,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Evento registrado correctamente'),
            backgroundColor: ColoresTema.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al registrar evento: $e'),
            backgroundColor: ColoresTema.error,
          ),
        );
      }
    } finally {
      setState(() => _guardando = false);
    }
  }

  @override
  void dispose() {
    _jugadorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Registrar Evento',
                style: TextStyle(
                  color: ColoresTema.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _equipoId,
                decoration: const InputDecoration(
                  labelText: 'Equipo',
                ),
                items: [
                  DropdownMenuItem(
                    value: widget.partido.equipoLocalId,
                    child: Text(widget.partido.equipoLocal?.nombre ?? ''),
                  ),
                  DropdownMenuItem(
                    value: widget.partido.equipoVisitanteId,
                    child: Text(widget.partido.equipoVisitante?.nombre ?? ''),
                  ),
                ],
                onChanged: (value) {
                  setState(() => _equipoId = value);
                },
                validator: (value) {
                  if (value == null) {
                    return 'Por favor seleccione el equipo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TipoEvento>(
                value: _tipoEvento,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Evento',
                ),
                items: TipoEvento.values.map((tipo) {
                  String label;
                  switch (tipo) {
                    case TipoEvento.gol:
                      label = '⚽ Gol';
                      break;
                    case TipoEvento.tarjeta_amarilla:
                      label = '🟨 Tarjeta Amarilla';
                      break;
                    case TipoEvento.tarjeta_roja:
                      label = '🟥 Tarjeta Roja';
                      break;
                  }
                  return DropdownMenuItem(
                    value: tipo,
                    child: Text(label),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _tipoEvento = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _jugadorController,
                decoration: const InputDecoration(
                  labelText: 'Jugador',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el nombre del jugador';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Minuto: '),
                  Expanded(
                    child: Slider(
                      value: _minuto.toDouble(),
                      min: 1,
                      max: 90,
                      divisions: 89,
                      label: _minuto.toString(),
                      onChanged: (value) {
                        setState(() => _minuto = value.round());
                      },
                    ),
                  ),
                  Text('$_minuto\''),
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