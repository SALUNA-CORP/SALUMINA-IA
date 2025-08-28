// lib/plugins/peladoras/vistas/dashboard_peladoras.dart
import 'package:flutter/material.dart';
import '../modelos/peladoras_toma.dart';
import '../servicios/peladoras_api.dart';
import '../../../core/temas/tema_personalizado.dart';
import 'widgets/peladoras_filtros.dart';
import 'widgets/peladoras_tarjetas_resumen.dart';
import 'widgets/peladoras_grafico_horario.dart';
import 'widgets/peladoras_tabla_ranking.dart';
import 'widgets/peladoras_grafico_produccion.dart';

class DashboardPeladoras extends StatefulWidget {
  const DashboardPeladoras({Key? key}) : super(key: key);

  @override
  State<DashboardPeladoras> createState() => _DashboardPeladorasState();
}

class _DashboardPeladorasState extends State<DashboardPeladoras> {
  final _api = ApiPeladoras();
  List<Toma> _tomas = [];
  bool _cargando = true;
  String? _peladoraSeleccionada;
  DateTime _fechaInicio = DateTime.now();
  DateTime _fechaFin = DateTime.now();

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      setState(() => _cargando = true);
      final tomas = await _api.obtenerTomas(_fechaInicio, _fechaFin);
      if (mounted) {
        setState(() {
          _tomas = tomas;
          _cargando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _cargando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: ColoresTema.error,
          )
        );
      }
    }
  }

  List<Toma> _filtrarTomas() {
    if (_peladoraSeleccionada == null) return _tomas;
    return _tomas.where((t) => t.peladoraId.toString() == _peladoraSeleccionada).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: ColoresTema.background,
          ),
        child: _cargando 
          ? Center(
              child: CircularProgressIndicator(
                color: ColoresTema.accent1,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FiltroPeladoras(
                    peladoraSeleccionada: _peladoraSeleccionada,
                    tomas: _tomas,
                    onPeladoraChanged: (String? value) {
                      setState(() => _peladoraSeleccionada = value);
                    },
                    onFechasChanged: (DateTimeRange range) {
                      setState(() {
                        _fechaInicio = range.start;
                        _fechaFin = range.end;
                      });
                      _cargarDatos();
                    },
                    fechaInicio: _fechaInicio,
                    fechaFin: _fechaFin,
                  ),
                  const SizedBox(height: 16),
                  TarjetasResumen(tomas: _filtrarTomas()),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: GraficoHorario(tomas: _filtrarTomas()),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GraficoProduccion(tomas: _filtrarTomas()),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TablaRanking(tomas: _filtrarTomas()),
                ],
              ),
            ),
      ),
    );
  }
}