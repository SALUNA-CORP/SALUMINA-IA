// lib/plugins/icg_frontrest/vistas/rest_dashboard_costos.dart
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../servicios/rest_api_icg.dart';
import '../servicios/rest_kpi_service.dart';
import '../modelos/rest_venta_costo.dart';
import '../modelos/rest_costo_fijo.dart';
import '../modelos/rest_kpi_data.dart';
import 'widgets/rest_kpi_cards.dart';
import 'widgets/rest_grafico_costos.dart';
import 'widgets/rest_grafico_participacion.dart';
import 'widgets/rest_grafico_dispersion.dart';
import 'widgets/rest_tabla_ranking.dart';
import '../../../core/temas/tema_personalizado.dart';
import '../../../core/widgets/tarjeta_glass.dart';

class DashboardCostos extends StatefulWidget {
  const DashboardCostos({Key? key}) : super(key: key);

  @override
  State<DashboardCostos> createState() => _DashboardCostosState();
}

class _DashboardCostosState extends State<DashboardCostos> {
  final _api = ApiICG();
  List<VentaCosto> _ventasCostos = [];
  List<CostoFijo> _costosFijos = [];
  bool _cargando = true;
  DateTime _fechaInicio = DateTime.now().subtract(const Duration(days: 30));
  DateTime _fechaFin = DateTime.now();

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      setState(() => _cargando = true);
      
      final ventasCostos = await _api.obtenerVentasCostos(
        fechaInicio: _fechaInicio,
        fechaFin: _fechaFin,
      );
      
      final costosFijos = await _api.obtenerCostosFijos(
        fechaInicio: _fechaInicio,
        fechaFin: _fechaFin,
      );
      
      if (mounted) {
        setState(() {
          _ventasCostos = ventasCostos;
          _costosFijos = costosFijos;
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
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth < 1200;

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
          : RefreshIndicator(
              onRefresh: _cargarDatos,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(isMobile ? 8.0 : 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(isMobile),
                    const SizedBox(height: 16),
                    
                    // Panel KPIs
                    _buildKPIPanel(isMobile),
                    const SizedBox(height: 24),
                    
                    // Gráficos principales
                    if (isMobile || isTablet) ...[
                      GraficoCostos(
                        ventasCostos: _ventasCostos,
                        costosFijos: _costosFijos,
                      ),
                      const SizedBox(height: 16),
                      GraficoParticipacion(
                        ventasCostos: _ventasCostos,
                      ),
                    ] else ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: GraficoCostos(
                              ventasCostos: _ventasCostos,
                              costosFijos: _costosFijos,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: GraficoParticipacion(
                              ventasCostos: _ventasCostos,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 24),
                    
                    GraficoDispersion(ventasCostos: _ventasCostos),
                    const SizedBox(height: 24),
                    
                    TablaRanking(ventasCostos: _ventasCostos),
                  ],
                ),
              ),
            ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _cargarDatos,
        backgroundColor: ColoresTema.accent1,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Dashboard de Costos',
          style: TextStyle(
            color: ColoresTema.textPrimary,
            fontSize: isMobile ? 20 : 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: [
            TarjetaGlass(
              child: ElevatedButton.icon(
                onPressed: () async {
                  final DateTimeRange? rango = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    initialDateRange: DateTimeRange(
                      start: _fechaInicio,
                      end: _fechaFin,
                    ),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.dark(
                            primary: ColoresTema.accent1,
                            onPrimary: ColoresTema.textPrimary,
                            surface: ColoresTema.cardBackground,
                            onSurface: ColoresTema.textPrimary,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );

                  if (rango != null) {
                    setState(() {
                      _fechaInicio = rango.start;
                      _fechaFin = rango.end;
                    });
                    await _cargarDatos();
                  }
                },
                icon: const Icon(Icons.calendar_today),
                label: Text(isMobile ? '' : 
                  '${_fechaInicio.toIso8601String().split('T')[0]} - '
                  '${_fechaFin.toIso8601String().split('T')[0]}'
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKPIPanel(bool isMobile) {
    final kpis = KPIService.calcularKPIs(_ventasCostos, _costosFijos);
    
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          constraints: BoxConstraints(
            minHeight: isMobile ? 480 : 180,
            maxHeight: isMobile ? 600 : 220,
          ),
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(child: VentasKPICard(
                      data: kpis['ventas']!,
                      isMobile: isMobile,
                    )),
                    const SizedBox(width: 8),
                    Expanded(child: CostosKPICard(
                      data: kpis['costos']!,
                      isMobile: isMobile,
                    )),
                    const SizedBox(width: 8),
                    Expanded(child: UtilidadKPICard(
                      data: kpis['utilidad']!,
                      isMobile: isMobile,
                    )),
                    const SizedBox(width: 8),
                    Expanded(child: ProductosKPICard(
                      data: kpis['productos']!,
                      isMobile: isMobile,
                    )),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}