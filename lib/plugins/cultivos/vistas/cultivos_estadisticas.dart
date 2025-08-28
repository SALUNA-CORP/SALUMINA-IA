// lib/plugins/cultivos/vistas/cultivos_estadisticas.dart

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../servicios/cultivos_service.dart';
import '../../../core/temas/tema_personalizado.dart';
import 'widgets/estadisticas/cultivos_estadisticas_filtros.dart';
import 'widgets/estadisticas/cultivos_estadisticas_kpis.dart';
import 'widgets/estadisticas/cultivos_estadisticas_tendencia_rendimiento.dart';
import 'widgets/estadisticas/cultivos_estadisticas_calidad_yuca.dart';
import 'widgets/estadisticas/cultivos_estadisticas_costos_rendimiento.dart';
import 'widgets/estadisticas/cultivos_estadisticas_estacionalidad.dart';
import 'widgets/estadisticas/cultivos_estadisticas_tabla_general.dart';

class EstadisticasCultivos extends StatefulWidget {
  const EstadisticasCultivos({super.key});

  @override
  State<EstadisticasCultivos> createState() => _EstadisticasCultivosState();
}

class _EstadisticasCultivosState extends State<EstadisticasCultivos> {
  final _servicio = GetIt.I<CultivosService>();

  @override
  void initState() {
    super.initState();
    _servicio.actualizarFiltros(FiltrosCultivos(
      fechas: DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 30)),
        end: DateTime.now(),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final isTablet = size.width < 1200;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Análisis Global de Cultivos'),
        leading: IconButton(
          icon: Icon(MdiIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<FiltrosCultivos>(
        stream: _servicio.filtrosStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final filtros = snapshot.data!;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CultivosEstadisticasFiltros(
                  onFechasChanged: (fechas) => _servicio.actualizarFiltros(
                    filtros.copyWith(fechas: fechas)),
                  onTipoCultivoChanged: (tipo) => _servicio.actualizarFiltros(
                    filtros.copyWith(tipoId: tipo)),
                  onFincaChanged: (finca) => _servicio.actualizarFiltros(
                    filtros.copyWith(fincaId: finca)),
                  onEstadoChanged: (estado) => _servicio.actualizarFiltros(
                    filtros.copyWith(estadoId: estado)),
                  fechasActuales: filtros.fechas ?? DateTimeRange(
                    start: DateTime.now().subtract(const Duration(days: 30)),
                    end: DateTime.now(),
                  ),
                  tipoSeleccionado: filtros.tipoId,
                  fincaSeleccionada: filtros.fincaId,
                  estadoSeleccionado: filtros.estadoId,
                ),
                const SizedBox(height: 16),
                const SizedBox(
                  height: 140,
                  child: CultivosEstadisticasKPIs(),
                ),
                const SizedBox(height: 16),

                if (isMobile) 
                  _buildMobileLayout()
                else if (isTablet)
                  _buildTabletLayout()
                else
                  _buildDesktopLayout(),
              ],
            ),
          );
        }
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: const [
        SizedBox(
          height: 400,
          child: CultivosEstadisticasTendenciaRendimiento(),
        ),
        SizedBox(height: 16),
        SizedBox(
          height: 400,
          child: CultivosEstadisticasCostosRendimiento(),
        ),
        SizedBox(height: 16),
        SizedBox(
          height: 400,
          child: CultivosEstadisticasCalidadYuca(),
        ),
        SizedBox(height: 16),
        SizedBox(
          height: 400,
          child: CultivosEstadisticasEstacionalidad(),
        ),
        SizedBox(height: 16),
        TablaGeneralCultivos(),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(
          height: 400,
          child: CultivosEstadisticasTendenciaRendimiento(),
        ),
        const SizedBox(height: 16),
        const SizedBox(
          height: 400,
          child: CultivosEstadisticasCostosRendimiento(),
        ),
        const SizedBox(height: 16),
        Row(
          children: const [
            Expanded(
              flex: 1,
              child: SizedBox(
                height: 400,
                child: CultivosEstadisticasCalidadYuca(),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              flex: 1,
              child: SizedBox(
                height: 400,
                child: CultivosEstadisticasEstacionalidad(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const TablaGeneralCultivos(),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(
          height: 400,
          child: CultivosEstadisticasTendenciaRendimiento(),
        ),
        const SizedBox(height: 16),
        const SizedBox(
          height: 400,
          child: CultivosEstadisticasCostosRendimiento(),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Expanded(
              flex: 1,
              child: SizedBox(
                height: 500,
                child: CultivosEstadisticasCalidadYuca(),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              flex: 1,
              child: SizedBox(
                height: 500,
                child: CultivosEstadisticasEstacionalidad(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const TablaGeneralCultivos(),
      ],
    );
  }
}