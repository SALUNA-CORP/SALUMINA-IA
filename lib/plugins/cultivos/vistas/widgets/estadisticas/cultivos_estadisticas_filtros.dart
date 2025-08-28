// lib/plugins/cultivos/vistas/widgets/estadisticas/cultivos_estadisticas_filtros.dart

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../servicios/cultivos_service.dart';
import '../../../../../core/temas/tema_personalizado.dart';

class CultivosEstadisticasFiltros extends StatefulWidget {
  final void Function(DateTimeRange) onFechasChanged;
  final void Function(String?) onTipoCultivoChanged;
  final void Function(String?) onFincaChanged;
  final void Function(String?) onEstadoChanged;
  final DateTimeRange fechasActuales;
  final String? tipoSeleccionado;
  final String? fincaSeleccionada;
  final String? estadoSeleccionado;

  const CultivosEstadisticasFiltros({
    super.key,
    required this.onFechasChanged,
    required this.onTipoCultivoChanged,
    required this.onFincaChanged,
    required this.onEstadoChanged,
    required this.fechasActuales,
    this.tipoSeleccionado,
    this.fincaSeleccionada,
    this.estadoSeleccionado,
  });

  @override
  State<CultivosEstadisticasFiltros> createState() => _CultivosEstadisticasFiltrosState();
}

class _CultivosEstadisticasFiltrosState extends State<CultivosEstadisticasFiltros> {
  final _servicio = GetIt.I<CultivosService>();

  @override
  Widget build(BuildContext context) {
    final formatoFecha = DateFormat('dd/MM/yyyy');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            // Selector de rango de fechas
            SizedBox(
              width: 250,
              child: InkWell(
                onTap: () async {
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    initialDateRange: widget.fechasActuales,
                    saveText: 'Guardar',
                    cancelText: 'Cancelar',
                    confirmText: 'Aceptar',
                    helpText: 'Selecciona un periodo',
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.dark(
                            primary: ColoresTema.accent1,
                            onPrimary: Colors.white,
                            surface: ColoresTema.cardBackground,
                            onSurface: ColoresTema.textPrimary,
                          ),
                          iconTheme: IconThemeData(
                            color: ColoresTema.accent1,
                          ),
                          navigationRailTheme: NavigationRailThemeData(
                            backgroundColor: ColoresTema.cardBackground,
                            selectedIconTheme: IconThemeData(color: ColoresTema.accent1),
                            unselectedIconTheme: IconThemeData(color: ColoresTema.textSecondary),
                          ),
                          appBarTheme: AppBarTheme(
                            iconTheme: IconThemeData(color: ColoresTema.accent1),
                          ),
                          textButtonTheme: TextButtonThemeData(
                            style: TextButton.styleFrom(
                              foregroundColor: ColoresTema.accent1,
                            ),
                          ),
                        ),
                        child: Localizations.override(
                          context: context,
                          locale: const Locale('es', 'ES'),
                          child: child!,
                        ),
                      );
                    },
                  );
                  if (picked != null) {
                    widget.onFechasChanged(picked);
                    _servicio.actualizarFiltros(
                      _servicio.filtrosActuales.copyWith(fechas: picked)
                    );
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    prefixIcon: Icon(MdiIcons.calendarMonth, color: ColoresTema.accent1),
                    labelText: 'Rango de Fechas',
                    border: const OutlineInputBorder(),
                  ),
                  child: Text('${formatoFecha.format(widget.fechasActuales.start)} - ${formatoFecha.format(widget.fechasActuales.end)}'),
                ),
              ),
            ),

            // Selector de tipo de cultivo
            StreamBuilder(
              stream: _servicio.obtenerTiposCultivo().asStream(),
              builder: (context, snapshot) {
                return SizedBox(
                  width: 200,
                  child: DropdownButtonFormField<String>(
                    value: widget.tipoSeleccionado,
                    decoration: InputDecoration(
                      prefixIcon: Icon(MdiIcons.sprout, color: ColoresTema.accent1),
                      labelText: 'Tipo de Cultivo',
                      border: const OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Todos')),
                      if (snapshot.hasData)
                        ...snapshot.data!.map((tipo) => DropdownMenuItem(
                          value: tipo.id,
                          child: Text(tipo.nombre),
                        )),
                    ],
                    onChanged: (value) {
                      widget.onTipoCultivoChanged(value);
                      _servicio.actualizarFiltros(
                        _servicio.filtrosActuales.copyWith(
                          tipoId: value,
                          clearTipoId: value == null,
                        )
                      );
                    },
                  ),
                );
              }
            ),

            // Selector de finca
            StreamBuilder(
              stream: _servicio.streamFincas(),
              builder: (context, snapshot) {
                return SizedBox(
                  width: 200,
                  child: DropdownButtonFormField<String>(
                    value: widget.fincaSeleccionada,
                    decoration: InputDecoration(
                      prefixIcon: Icon(MdiIcons.homeCityOutline, color: ColoresTema.accent1),
                      labelText: 'Finca',
                      border: const OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Todas')),
                      if (snapshot.hasData)
                        ...snapshot.data!.map((finca) => DropdownMenuItem(
                          value: finca.id,
                          child: Text(finca.nombre),
                        )),
                    ],
                    onChanged: (value) {
                      widget.onFincaChanged(value);
                      _servicio.actualizarFiltros(
                        _servicio.filtrosActuales.copyWith(
                          fincaId: value,
                          clearFincaId: value == null,
                        )
                      );
                    },
                  ),
                );
              }
            ),

            // Selector de estado
            StreamBuilder(
              stream: _servicio.obtenerEstados().asStream(),
              builder: (context, snapshot) {
                return SizedBox(
                  width: 200,
                  child: DropdownButtonFormField<String>(
                    value: widget.estadoSeleccionado,
                    decoration: InputDecoration(
                      prefixIcon: Icon(MdiIcons.chartDonut, color: ColoresTema.accent1),
                      labelText: 'Estado',
                      border: const OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Todos')),
                      if (snapshot.hasData)
                        ...snapshot.data!.map((estado) => DropdownMenuItem(
                          value: estado.id,
                          child: Text(estado.nombre),
                        )),
                    ],
                    onChanged: (value) {
                      widget.onEstadoChanged(value);
                      _servicio.actualizarFiltros(
                        _servicio.filtrosActuales.copyWith(
                          estadoId: value,
                          clearEstadoId: value == null,
                        )
                      );
                    },
                  ),
                );
              }
            ),

            // Botón de limpiar filtros
            FilledButton.icon(
              onPressed: () {
                final fechaInicial = DateTime.now().subtract(const Duration(days: 30));
                final rango = DateTimeRange(
                  start: fechaInicial,
                  end: DateTime.now(),
                );
                widget.onFechasChanged(rango);
                widget.onTipoCultivoChanged(null);
                widget.onFincaChanged(null);
                widget.onEstadoChanged(null);
                _servicio.actualizarFiltros(FiltrosCultivos(
                  fechas: rango,
                ));
              },
              icon: Icon(MdiIcons.filterRemoveOutline),
              label: const Text('Limpiar Filtros'),
            ),
          ],
        ),
      ),
    );
  }
}