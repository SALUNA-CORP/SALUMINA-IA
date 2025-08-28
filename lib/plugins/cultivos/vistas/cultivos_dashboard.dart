//lib/plugins/cultivos/vistas/cultivos_dashboard.dart
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../servicios/cultivos_service.dart';
import '../modelos/cultivos_models.dart';
import 'widgets/cultivos_lista_siembras.dart';
import 'widgets/cultivos_mapa.dart';
import 'widgets/cultivos_detalles_lote.dart';
import 'widgets/cultivos_grafico_meta_rendimiento.dart';
import 'widgets/cultivos_resumen_general.dart';
import '../../../core/temas/tema_personalizado.dart';

class DashboardCultivos extends StatefulWidget {
  const DashboardCultivos({super.key});

  @override
  State<DashboardCultivos> createState() => _DashboardCultivosState();
}

class _DashboardCultivosState extends State<DashboardCultivos> {
  final _servicio = GetIt.I<CultivosService>();
  final _mapController = MapController();
  String _fincaActual = '4e674d79-4041-4e2d-b032-4a198470196d';
  String? _loteSeleccionado;

  @override
  void initState() {
    super.initState();
    _cargarPrimerLote();
    Future.delayed(Duration.zero, () => _centrarMapaEnFinca(_fincaActual));
  }

  Future<void> _cargarPrimerLote() async {
    try {
      final lotes = await _servicio.streamLotes(_fincaActual).first;
      if (lotes.isNotEmpty) {
        setState(() {
          _loteSeleccionado = lotes.first.id;
        });
        _centrarEnLote(lotes.first.id);
      }
    } catch (e) {
      print('Error cargando primer lote: $e');
    }
  }

  Future<void> _centrarMapaEnFinca(String fincaId) async {
    try {
      final fincas = await _servicio.streamFincas().first;
      final finca = fincas.firstWhere((f) => f.id == fincaId);
      
      if (finca.coordenadas.isNotEmpty) {
        double latSum = 0;
        double lngSum = 0;
        double maxLat = -90;
        double minLat = 90;
        double maxLng = -180;
        double minLng = 180;
        
        for (var coord in finca.coordenadas) {
          latSum += coord.latitude;
          lngSum += coord.longitude;
          maxLat = maxLat < coord.latitude ? coord.latitude : maxLat;
          minLat = minLat > coord.latitude ? coord.latitude : minLat;
          maxLng = maxLng < coord.longitude ? coord.longitude : maxLng;
          minLng = minLng > coord.longitude ? coord.longitude : minLng;
        }
        
        final centerLat = latSum / finca.coordenadas.length;
        final centerLng = lngSum / finca.coordenadas.length;
        
        final latSpan = maxLat - minLat;
        final lngSpan = maxLng - minLng;
        final maxSpan = latSpan > lngSpan ? latSpan : lngSpan;
        
        final zoom = 14.0 - (maxSpan * 10);
        
        _mapController.move(
          LatLng(centerLat, centerLng),
          zoom.clamp(10.0, 18.0),
        );
      }
    } catch (e) {
      print('Error centrando mapa: $e');
    }
  }

  Future<void> _centrarEnLote(String loteId) async {
    try {
      final lote = await _servicio.streamLote(loteId).first;
      if (lote != null && lote.coordenadas.isNotEmpty) {
        double latSum = 0;
        double lngSum = 0;
        
        for (var coord in lote.coordenadas) {
          latSum += coord.latitude;
          lngSum += coord.longitude;
        }
        
        final centerLat = latSum / lote.coordenadas.length;
        final centerLng = lngSum / lote.coordenadas.length;
        
        _mapController.move(
          LatLng(centerLat, centerLng),
          16.0,
        );
      }
    } catch (e) {
      print('Error centrando en lote: $e');
    }
  }

  void _seleccionarFinca(String? fincaId) {
    if (fincaId != null) {
      setState(() {
        _fincaActual = fincaId;
        _loteSeleccionado = null;
      });
      _centrarMapaEnFinca(fincaId);
      _cargarPrimerLote();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final isTablet = size.width < 1200;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Cultivos'),
        actions: [
          FilledButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/cultivos/estadisticas'),
            icon: Icon(MdiIcons.chartBox),
            label: Text(isMobile ? '' : 'Análisis Global'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: isMobile ? _buildMobileLayout() :
            isTablet ? _buildTabletLayout() :
            _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        // Panel superior (mapa y resumen)
        Expanded(
          flex: 2,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: _buildResumenGeneral(),
              ),
              Expanded(child: _buildMapa()),
            ],
          ),
        ),
        // Panel inferior (lista de lotes)
        Expanded(
          child: _buildPanelIzquierdo(),
        ),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      children: [
        // Panel izquierdo
        SizedBox(
          width: 280,
          child: _buildPanelIzquierdo(),
        ),
        // Panel central y derecho
        Expanded(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: _buildResumenGeneral(),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildMapa(),
                    ),
                    if (_loteSeleccionado != null)
                      SizedBox(
                        width: 300,
                        child: _buildPanelDerecho(),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Panel izquierdo
        SizedBox(
          width: 280,
          child: _buildPanelIzquierdo(),
        ),
        // Panel central
        Expanded(
          flex: 2,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: _buildResumenGeneral(),
              ),
              Expanded(child: _buildMapa()),
            ],
          ),
        ),
        // Panel derecho
        SizedBox(
          width: 350,
          child: _buildPanelDerecho(),
        ),
      ],
    );
  }

  Widget _buildResumenGeneral() {
    return StreamBuilder<List<Siembra>>(
      stream: _servicio.streamSiembras(_fincaActual),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        return ResumenGeneral(siembras: snapshot.data!);
      },
    );
  }

  Widget _buildPanelIzquierdo() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: StreamBuilder<List<Finca>>(
            stream: _servicio.streamFincas(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const LinearProgressIndicator();
              return DropdownButtonFormField<String>(
                value: _fincaActual,
                decoration: InputDecoration(
                  labelText: 'Finca',
                  prefixIcon: Icon(MdiIcons.home),
                  border: const OutlineInputBorder(),
                ),
                items: snapshot.data!.map((finca) => 
                  DropdownMenuItem(
                    value: finca.id,
                    child: Text(finca.nombre),
                  ),
                ).toList(),
                onChanged: _seleccionarFinca,
              );
            },
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Siembra>>(
            stream: _servicio.streamSiembras(_fincaActual),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              return ListaSiembras(
                siembras: snapshot.data!,
                onLoteSelected: (loteId) {
                  setState(() => _loteSeleccionado = loteId);
                  _centrarEnLote(loteId);
                },
                loteSeleccionadoId: _loteSeleccionado,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMapa() {
    return StreamBuilder<List<Finca>>(
      stream: _servicio.streamFincas(),
      builder: (context, snapshotFincas) {
        if (!snapshotFincas.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return StreamBuilder<List<Lote>>(
          stream: _servicio.streamLotes(_fincaActual),
          builder: (context, snapshotLotes) {
            if (!snapshotLotes.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            return MapaCultivos(
              mapController: _mapController,
              fincas: snapshotFincas.data!,
              lotes: snapshotLotes.data!,
              loteSeleccionadoId: _loteSeleccionado,
              fincaActual: _fincaActual,
              onLoteSelected: (loteId) {
                setState(() => _loteSeleccionado = loteId);
                _centrarEnLote(loteId);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildPanelDerecho() {
    if (_loteSeleccionado == null) {
      return const Center(child: Text('Seleccione un lote'));
    }

    return StreamBuilder<Lote?>(
      stream: _servicio.streamLote(_loteSeleccionado!),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final lote = snapshot.data!;
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: DetallesLote(lote: lote),
              ),
            ),
            if (lote.siembraActual != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: GraficoMetaRendimiento(
                  siembra: lote.siembraActual!,
                ),
              ),
          ],
        );
      },
    );
  }
}