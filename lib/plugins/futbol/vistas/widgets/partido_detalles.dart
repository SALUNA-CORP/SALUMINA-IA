import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../modelos/partido.dart';
import '../../modelos/evento_partido.dart';
import '../../servicios/servicio_futbol.dart';
import '../../../../core/temas/tema_personalizado.dart';
import 'registro_evento.dart';

class PartidoDetalles extends StatelessWidget {
  final Partido partido;

  const PartidoDetalles({
    super.key,
    required this.partido,
  });

  @override
  Widget build(BuildContext context) {
    final servicio = GetIt.I<ServicioFutbol>();

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 600,
        decoration: BoxDecoration(
          color: ColoresTema.cardBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ColoresTema.accent1.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'Detalles del Partido',
                    style: TextStyle(
                      color: ColoresTema.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (partido.estado == EstadoPartido.en_curso)
                    TextButton.icon(
                      onPressed: () => _mostrarRegistroEvento(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Registrar Evento'),
                    ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          partido.equipoLocal?.nombre ?? '',
                          style: TextStyle(
                            color: ColoresTema.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          partido.golesLocal.toString(),
                          style: TextStyle(
                            color: ColoresTema.accent1,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _getEstadoColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getEstadoTexto(),
                      style: TextStyle(
                        color: _getEstadoColor(),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          partido.equipoVisitante?.nombre ?? '',
                          style: TextStyle(
                            color: ColoresTema.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          partido.golesVisitante.toString(),
                          style: TextStyle(
                            color: ColoresTema.accent2,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: StreamBuilder<List<EventoPartido>>(
                stream: servicio.obtenerEventosPartidoStream(partido.id),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error al cargar eventos',
                        style: TextStyle(color: ColoresTema.error),
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: ColoresTema.accent1,
                      ),
                    );
                  }

                  final eventos = snapshot.data!;
                  if (eventos.isEmpty) {
                    return Center(
                      child: Text(
                        'No hay eventos registrados',
                        style: TextStyle(color: ColoresTema.textSecondary),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: eventos.length,
                    itemBuilder: (context, index) {
                      final evento = eventos[index];
                      return ListTile(
                        leading: _buildEventoIcono(evento.tipoEvento),
                        title: Text(evento.descripcion),
                        subtitle: Text('${evento.minuto}\''),
                        trailing: Text(
                          evento.equipo?.nombre ?? '',
                          style: TextStyle(
                            color: ColoresTema.textSecondary,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            if (partido.estado == EstadoPartido.en_curso)
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: () => _finalizarPartido(context),
                  icon: const Icon(Icons.stop),
                  label: const Text('Finalizar Partido'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColoresTema.error,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _mostrarRegistroEvento(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => RegistroEvento(partido: partido),
    );
  }

  Future<void> _finalizarPartido(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finalizar Partido'),
        content: const Text('¿Está seguro de finalizar el partido?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColoresTema.error,
            ),
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      final servicio = GetIt.I<ServicioFutbol>();
      await servicio.actualizarPartido(
        partidoId: partido.id,
        golesLocal: partido.golesLocal,
        golesVisitante: partido.golesVisitante,
        estado: EstadoPartido.finalizado,
      );
      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }

  Color _getEstadoColor() {
    switch (partido.estado) {
      case EstadoPartido.en_curso:
        return ColoresTema.warning;
      case EstadoPartido.finalizado:
        return ColoresTema.success;
      default:
        return ColoresTema.accent1;
    }
  }

  String _getEstadoTexto() {
    switch (partido.estado) {
      case EstadoPartido.en_curso:
        return 'EN CURSO';
      case EstadoPartido.finalizado:
        return 'FINALIZADO';
      default:
        return 'PENDIENTE';
    }
  }

  Widget _buildEventoIcono(TipoEvento tipo) {
    IconData icono;
    Color color;

    switch (tipo) {
      case TipoEvento.gol:
        icono = Icons.sports_soccer;
        color = ColoresTema.success;
        break;
      case TipoEvento.tarjeta_amarilla:
        icono = Icons.square;
        color = Colors.yellow;
        break;
      case TipoEvento.tarjeta_roja:
        icono = Icons.square;
        color = ColoresTema.error;
        break;
    }

    return Icon(icono, color: color);
  }
}