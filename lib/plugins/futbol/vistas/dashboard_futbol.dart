import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../servicios/servicio_futbol.dart';
import '../../../core/temas/tema_personalizado.dart';
import 'widgets/tabla_posiciones.dart';
import 'widgets/lista_partidos.dart';
import 'widgets/gestor_partido.dart';
import 'widgets/registro_equipo.dart';

class DashboardFutbol extends StatefulWidget {
  const DashboardFutbol({super.key});

  @override
  State<DashboardFutbol> createState() => _DashboardFutbolState();
}

class _DashboardFutbolState extends State<DashboardFutbol> {
  final _servicio = GetIt.I<ServicioFutbol>();

  void _mostrarRegistroEquipo() {
    showDialog(
      context: context,
      builder: (context) => const RegistroEquipo(),
    );
  }

  void _mostrarCrearPartido() {
    showDialog(
      context: context,
      builder: (context) => const GestorPartido(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final esPantallaPequena = size.width < 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campeonato de Fútbol'),
        actions: [
          if (!esPantallaPequena) ...[
            TextButton.icon(
              onPressed: _mostrarRegistroEquipo,
              icon: const Icon(Icons.group_add),
              label: const Text('Registrar Equipo'),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: _mostrarCrearPartido,
              icon: const Icon(Icons.sports_soccer),
              label: const Text('Nuevo Partido'),
            ),
          ],
        ],
      ),
      floatingActionButton: esPantallaPequena ? Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'registrar_equipo',
            onPressed: _mostrarRegistroEquipo,
            backgroundColor: ColoresTema.accent1,
            child: const Icon(Icons.group_add),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'nuevo_partido',
            onPressed: _mostrarCrearPartido,
            backgroundColor: ColoresTema.accent2,
            child: const Icon(Icons.sports_soccer),
          ),
        ],
      ) : null,
      body: Container(
        decoration: BoxDecoration(
          color: ColoresTema.background,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: esPantallaPequena 
            ? SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Tabla de posiciones
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tabla de Posiciones',
                              style: TextStyle(
                                color: ColoresTema.textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const SizedBox(
                              height: 400,
                              child: TablaPosiciones(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Lista de partidos
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Partidos',
                              style: TextStyle(
                                color: ColoresTema.textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const SizedBox(
                              height: 400,
                              child: ListaPartidos(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tabla de posiciones
                  Expanded(
                    flex: 2,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tabla de Posiciones',
                              style: TextStyle(
                                color: ColoresTema.textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Expanded(
                              child: TablaPosiciones(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Lista de partidos
                  Expanded(
                    flex: 3,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Partidos',
                              style: TextStyle(
                                color: ColoresTema.textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Expanded(
                              child: ListaPartidos(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
        ),
      ),
    );
  }
}