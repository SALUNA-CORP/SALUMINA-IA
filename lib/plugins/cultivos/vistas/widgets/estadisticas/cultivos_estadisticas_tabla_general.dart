// lib/plugins/cultivos/vistas/widgets/estadisticas/cultivos_estadisticas_tabla_general.dart

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../servicios/cultivos_service.dart';
import '../../../modelos/cultivos_models.dart';
import '../../../../../core/temas/tema_personalizado.dart';
import './cultivos_estadisticas_badge_alertas.dart';

class TablaGeneralCultivos extends StatefulWidget {
  const TablaGeneralCultivos({super.key});

  @override
  State<TablaGeneralCultivos> createState() => _TablaGeneralCultivosState();
}

class _TablaGeneralCultivosState extends State<TablaGeneralCultivos> {
  String? _ordenColumna;
  bool _ascendente = true;
  String _busqueda = '';
  final formatoMoneda = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);
  final formatoNumero = NumberFormat('#,##0', 'es_CO');
  
  @override
  Widget build(BuildContext context) {
    final servicio = GetIt.I<CultivosService>();
    final formatoFecha = DateFormat('dd/MM/yyyy');
    final screenWidth = MediaQuery.of(context).size.width;

    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(MdiIcons.chartBox, color: ColoresTema.accent1),
                    const SizedBox(width: 8),
                    Text(
                      'Análisis Comparativo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ColoresTema.textPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: 300,
                  child: TextField(
                    onChanged: (valor) => setState(() => _busqueda = valor),
                    decoration: InputDecoration(
                      labelText: 'Buscar',
                      prefixIcon: Icon(MdiIcons.magnify),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            StreamBuilder<List<Siembra>>(
              stream: servicio.streamSiembrasFiltradas(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var siembras = _filtrarSiembras(snapshot.data!, _busqueda);
                siembras = _ordenarSiembras(siembras);

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: screenWidth - 32,
                    ),
                    child: DataTable(
                      columnSpacing: 8.0,
                      horizontalMargin: 8.0,
                      sortColumnIndex: _ordenColumna != null ? 
                        _obtenerIndiceColumna(_ordenColumna!) : null,
                      sortAscending: _ascendente,
                      columns: [
                        _columna('Lote', 'finca', icon: MdiIcons.home),
                        _columna('Tipo', 'tipo', icon: MdiIcons.sprout),
                        _columna('Estado', 'estado', icon: MdiIcons.progressCheck),
                        _columna('Inicio', 'inicio', numeric: true, icon: MdiIcons.calendar),
                        _columna('Ha Cosechadas', 'hectareas', numeric: true, icon: MdiIcons.chartAreaspline),
                        _columna('Kg Total', 'kgTotal', numeric: true, icon: MdiIcons.weight),
                        _columna('Kg/Ha', 'kgHa', numeric: true, icon: MdiIcons.chartBar),
                        _columna('Calidad', 'calidad', numeric: true, icon: MdiIcons.podium),
                        _columna('Inversión', 'inversion', numeric: true, icon: MdiIcons.cash),
                        _columna('Progreso', 'progreso', numeric: true, icon: MdiIcons.percent),
                        _columna('Costo/Ha', 'costoHa', numeric: true, icon: MdiIcons.cashRemove),
                        _columna('Costo/Kg', 'costoKg', numeric: true, icon: MdiIcons.cashCheck),
                        const DataColumn(label: Text('Alertas')),
                      ],
                      rows: siembras.map((siembra) {
                        final porcentajeInversion = (siembra.inversionActual / siembra.presupuestoTotal) * 100;
                        
                        return DataRow(
                          cells: [
                            DataCell(Text(siembra.nombreLote)),
                            DataCell(Text(siembra.tipo.nombre)),
                            DataCell(_buildEstadoWidget(siembra.estado)),
                            DataCell(Text(formatoFecha.format(siembra.fechaInicio))),
                            DataCell(Text('${formatoNumero.format(siembra.hectareasCosechadas)} / ${formatoNumero.format(siembra.hectareasSembradas)}')),
                            DataCell(Text(formatoNumero.format(siembra.kgCosechados))),
                            DataCell(Text(formatoNumero.format(siembra.kgPorHectareaCosechada))),
                            DataCell(siembra.tipo.nombre.toUpperCase() == 'YUCA' ? 
                              _buildCalidadWidget(siembra.porcentajePrimera, siembra.porcentajeSegunda) :
                              const Text('-')),
                            DataCell(Text(formatoMoneda.format(siembra.inversionActual))),
                            DataCell(_buildProgressCell(
                              porcentajeInversion,
                              '${formatoNumero.format(porcentajeInversion)}%',
                              colorByProgress: true,
                            )),
                            DataCell(Text(formatoMoneda.format(siembra.costoHectarea))),
                            DataCell(Text(formatoMoneda.format(siembra.costoKilogramo))),
                            DataCell(BadgeAlertasCultivos(siembra: siembra)),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  DataColumn _columna(String titulo, String campo, {bool numeric = false, IconData? icon}) {
    return DataColumn(
      numeric: numeric,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: ColoresTema.accent1),
            const SizedBox(width: 4),
          ],
          Text(titulo),
        ],
      ),
      onSort: (columnIndex, ascending) {
        setState(() {
          _ordenColumna = campo;
          _ascendente = ascending;
        });
      },
    );
  }

  Widget _buildEstadoWidget(EstadoCultivo estado) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: estado.color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(MdiIcons.circle, size: 8, color: estado.color),
          const SizedBox(width: 4),
          Text(
            estado.nombre,
            style: TextStyle(color: estado.color),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCell(double porcentaje, String texto, {bool colorByProgress = false}) {
    Color getProgressColor() {
      if (colorByProgress) {
        if (porcentaje >= 90) return ColoresTema.error;
        if (porcentaje >= 70) return ColoresTema.warning;
        return ColoresTema.success;
      }
      return ColoresTema.accent1;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(texto),
        const SizedBox(height: 4),
        SizedBox(
          width: 100,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: porcentaje / 100,
              backgroundColor: getProgressColor().withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(getProgressColor()),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalidadWidget(double porcentajePrimera, double porcentajeSegunda) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(MdiIcons.podiumGold, size: 16, color: ColoresTema.accent1),
        const SizedBox(width: 4),
        Text('${formatoNumero.format(porcentajePrimera)}%'),
        const SizedBox(width: 8),
        Icon(MdiIcons.podiumSilver, size: 16, color: ColoresTema.warning),
        const SizedBox(width: 4),
        Text('${formatoNumero.format(porcentajeSegunda)}%'),
      ],
    );
  }

  int _obtenerIndiceColumna(String campo) {
    const campos = ['finca', 'tipo', 'estado', 'inicio', 'hectareas',
                   'kgTotal', 'kgHa', 'calidad', 'inversion', 
                   'progreso', 'costoHa', 'costoKg'];
    return campos.indexOf(campo);
  }

  List<Siembra> _filtrarSiembras(List<Siembra> siembras, String busqueda) {
    if (busqueda.isEmpty) return siembras;
    
    return siembras.where((siembra) {
      final terminoBusqueda = busqueda.toLowerCase();
      return siembra.nombreLote.toLowerCase().contains(terminoBusqueda) ||
             siembra.tipo.nombre.toLowerCase().contains(terminoBusqueda) ||
             siembra.estado.nombre.toLowerCase().contains(terminoBusqueda);
    }).toList();
  }

  List<Siembra> _ordenarSiembras(List<Siembra> siembras) {
    if (_ordenColumna == null) return siembras;

    return List.from(siembras)..sort((a, b) {
      int comparacion;
      switch (_ordenColumna) {
        case 'finca':
          comparacion = a.nombreLote.compareTo(b.nombreLote);
          break;
        case 'tipo':
          comparacion = a.tipo.nombre.compareTo(b.tipo.nombre);
          break;
        case 'estado':
          comparacion = a.estado.nombre.compareTo(b.estado.nombre);
          break;
        case 'inicio':
          comparacion = a.fechaInicio.compareTo(b.fechaInicio);
          break;
        case 'hectareas':
          comparacion = a.hectareasSembradas.compareTo(b.hectareasSembradas);
          break;
        case 'kgTotal':
          comparacion = a.kgCosechados.compareTo(b.kgCosechados);
          break;
        case 'kgHa':
          comparacion = a.kgPorHectareaCosechada.compareTo(b.kgPorHectareaCosechada);
          break;
        case 'calidad':
          comparacion = a.porcentajePrimera.compareTo(b.porcentajePrimera);
          break;
        case 'inversion':
          comparacion = a.inversionActual.compareTo(b.inversionActual);
          break;
        case 'progreso':
          final progresoA = a.inversionActual / a.presupuestoTotal;
          final progresoB = b.inversionActual / b.presupuestoTotal;
          comparacion = progresoA.compareTo(progresoB);
          break;
        case 'costoHa':
          comparacion = a.costoHectarea.compareTo(b.costoHectarea);
          break;
        case 'costoKg':
          comparacion = a.costoKilogramo.compareTo(b.costoKilogramo);
          break;
        default:
          return 0;
      }
      return _ascendente ? comparacion : -comparacion;
    });
  }
}