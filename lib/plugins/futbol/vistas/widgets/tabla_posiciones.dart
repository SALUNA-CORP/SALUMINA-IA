import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../servicios/servicio_futbol.dart';
import '../../modelos/equipo.dart';
import '../../../../core/temas/tema_personalizado.dart';

class TablaPosiciones extends StatelessWidget {
  const TablaPosiciones({super.key});

  @override
  Widget build(BuildContext context) {
    final servicio = GetIt.I<ServicioFutbol>();
    final esPantallaPequena = MediaQuery.of(context).size.width < 600;

    return StreamBuilder<List<Equipo>>(
      stream: servicio.obtenerTablaPosiciones(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error al cargar la tabla: ${snapshot.error}',
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

        final equipos = snapshot.data!;
        if (equipos.isEmpty) {
          return Center(
            child: Text(
              'No hay equipos registrados',
              style: TextStyle(color: ColoresTema.textSecondary),
            ),
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: esPantallaPequena ? 15 : 20,
            horizontalMargin: esPantallaPequena ? 10 : 20,
            columns: [
              const DataColumn(label: Text('Pos')),
              const DataColumn(label: Text('Equipo')),
              const DataColumn(label: Text('PJ'), numeric: true),
              const DataColumn(label: Text('G'), numeric: true),
              const DataColumn(label: Text('E'), numeric: true),
              const DataColumn(label: Text('P'), numeric: true),
              const DataColumn(label: Text('GF'), numeric: true),
              const DataColumn(label: Text('GC'), numeric: true),
              const DataColumn(label: Text('DG'), numeric: true),
              const DataColumn(label: Text('Pts'), numeric: true),
            ],
            rows: equipos.asMap().entries.map((entry) {
              final index = entry.key;
              final equipo = entry.value;
              final medallaColor = _obtenerColorMedalla(index);

              return DataRow(
                cells: [
                  DataCell(
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: medallaColor?.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: medallaColor ?? ColoresTema.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (equipo.escudo != null) ...[
                          Image.network(
                            equipo.escudo!,
                            width: 24,
                            height: 24,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(equipo.nombre),
                      ],
                    ),
                  ),
                  DataCell(Text('${equipo.partidosJugados}')),
                  DataCell(Text('${equipo.partidosGanados}')),
                  DataCell(Text('${equipo.partidosEmpatados}')),
                  DataCell(Text('${equipo.partidosPerdidos}')),
                  DataCell(Text('${equipo.golesFavor}')),
                  DataCell(Text('${equipo.golesContra}')),
                  DataCell(
                    Text(
                      '${equipo.diferenciaGoles}',
                      style: TextStyle(
                        color: equipo.diferenciaGoles > 0
                            ? ColoresTema.success
                            : equipo.diferenciaGoles < 0
                                ? ColoresTema.error
                                : null,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      '${equipo.puntos}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Color? _obtenerColorMedalla(int posicion) {
    switch (posicion) {
      case 0:
        return Colors.amber; // Oro
      case 1:
        return Colors.grey[300]; // Plata
      case 2:
        return Colors.brown[300]; // Bronce
      default:
        return null;
    }
  }
}