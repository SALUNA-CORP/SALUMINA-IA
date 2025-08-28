import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import '../../servicios/servicio_futbol.dart';
import '../../modelos/partido.dart';
import '../../../../core/temas/tema_personalizado.dart';
import 'partido_card.dart';

class ListaPartidos extends StatelessWidget {
  const ListaPartidos({super.key});

  @override
  Widget build(BuildContext context) {
    final servicio = GetIt.I<ServicioFutbol>();

    return StreamBuilder<List<Partido>>(
      stream: servicio.obtenerPartidosStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error al cargar partidos: ${snapshot.error}',
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

        final partidos = snapshot.data!;
        if (partidos.isEmpty) {
          return Center(
            child: Text(
              'No hay partidos programados',
              style: TextStyle(color: ColoresTema.textSecondary),
            ),
          );
        }

        // Agrupar partidos por fecha
        final partidosPorFecha = <DateTime, List<Partido>>{};
        for (var partido in partidos) {
          final fecha = DateTime(
            partido.fecha.year,
            partido.fecha.month,
            partido.fecha.day,
          );
          if (!partidosPorFecha.containsKey(fecha)) {
            partidosPorFecha[fecha] = [];
          }
          partidosPorFecha[fecha]!.add(partido);
        }

        final fechasOrdenadas = partidosPorFecha.keys.toList()
          ..sort((a, b) => a.compareTo(b));

        return ListView.builder(
          itemCount: fechasOrdenadas.length,
          itemBuilder: (context, index) {
            final fecha = fechasOrdenadas[index];
            final partidosDelDia = partidosPorFecha[fecha]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    _formatearFecha(fecha),
                    style: TextStyle(
                      color: ColoresTema.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: partidosDelDia.length,
                  itemBuilder: (context, i) => PartidoCard(
                    partido: partidosDelDia[i],
                  ),
                ),
                if (index < fechasOrdenadas.length - 1)
                  Divider(color: ColoresTema.border),
              ],
            );
          },
        );
      },
    );
  }

  String _formatearFecha(DateTime fecha) {
    final hoy = DateTime.now();
    final manana = DateTime(hoy.year, hoy.month, hoy.day + 1);
    final ayer = DateTime(hoy.year, hoy.month, hoy.day - 1);

    if (fecha.year == hoy.year && 
        fecha.month == hoy.month && 
        fecha.day == hoy.day) {
      return 'HOY';
    } else if (fecha.year == manana.year && 
               fecha.month == manana.month && 
               fecha.day == manana.day) {
      return 'MAÑANA';
    } else if (fecha.year == ayer.year && 
               fecha.month == ayer.month && 
               fecha.day == ayer.day) {
      return 'AYER';
    } else {
      final formatter = DateFormat('EEEE, d MMMM', 'es');
      return formatter.format(fecha).toUpperCase();
    }
  }
}