// lib/plugins/sensores/vistas/monitoreo/sensores_dashboard_movil.dart
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:math' show min, max;
import '../../servicios/sensores_api_modbus.dart';
import '../../modelos/sensores_modbus_data.dart';
import '../../modelos/sensores_proceso_data.dart';
import '../../modelos/sensores_elemento_proceso.dart';
import '../../modelos/sensores_historico_data.dart';
import 'widgets/sensores_badge_alertas.dart';
import '../../../../core/temas/tema_personalizado.dart';

extension ListExtension<T extends num> on Iterable<T> {
  double get average => isEmpty ? 0.0 : fold<double>(0.0, (sum, item) => sum + item.toDouble()) / length;
}

class SensoresDashboardMovil extends StatefulWidget {
  const SensoresDashboardMovil({super.key});

  @override
  State<SensoresDashboardMovil> createState() => _SensoresDashboardMovilState();
}

class _SensoresDashboardMovilState extends State<SensoresDashboardMovil> 
    with SingleTickerProviderStateMixin {
  final _api = GetIt.instance<SensoresApiModbus>();
  late TabController _tabController;
  List<ModbusData> _historicoDatos = [];
  ModbusData? _ultimosDatos;
  String _procesoSeleccionado = 'extraccion';
  bool _mostrarGraficas = false;
  final _formatoNumero = NumberFormat("#,##0.0", "es_CO");
  final _alertas = generarAlertas();
  final _historico = historicoSensores;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _iniciarActualizaciones();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _iniciarActualizaciones() async {
    await _actualizarDatos();
    _api.streamDatosModbus().listen((datos) {
      if (mounted && datos.isNotEmpty) {
        setState(() {
          _ultimosDatos = datos.first;
          _historicoDatos = datos;
        });
      }
    });
  }

  Future<void> _actualizarDatos() async {
    try {
      final datos = await _api.obtenerUltimosRegistros();
      if (mounted && datos.isNotEmpty) {
        setState(() {
          _ultimosDatos = datos.first;
          _historicoDatos = datos;
        });
      }
    } catch (e) {
      debugPrint('Error actualizando datos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Digestor - Prensa 1'),
        actions: [
          BadgeAlertas(alertas: _alertas),
          IconButton(
            icon: Icon(_mostrarGraficas ? MdiIcons.chartBox : MdiIcons.viewDashboard),
            onPressed: () => setState(() => _mostrarGraficas = !_mostrarGraficas),
          ),
          IconButton(
            icon: Icon(MdiIcons.refresh),
            onPressed: _actualizarDatos,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Proceso'),
            Tab(text: 'Tendencias'),
            Tab(text: 'Mantenimiento'),
            Tab(text: 'Producción'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProceso('extraccion'),
          _buildResumenGeneral(),
          _buildProceso('desfibrado'),
          _buildProceso('caldera'),
        ],
      ),
    );
  }

  Widget _buildResumenGeneral() {
    if (_ultimosDatos == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _actualizarDatos,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildKPIGrid(),
            if (_mostrarGraficas) ...[
              const SizedBox(height: 16),
              _buildGraficaTendencias(),
              const SizedBox(height: 16),
              _buildGraficoHistorico(),
            ],
            const SizedBox(height: 16),
            _buildTablaResumen(),
          ],
        ),
      ),
    );
  }

  Widget _buildKPIGrid() {
    final produccion = _historico
      .where((h) => h.tipo == 'produccion')
      .firstOrNull?.valor ?? 0.0;
      
    final temperatura = _historico
      .where((h) => h.tipo == 'temperatura_digestor')
      .firstOrNull?.valor ?? 0.0;
      
    final presion = _historico
      .where((h) => h.tipo == 'presion_vapor')
      .firstOrNull?.valor ?? 0.0;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.5,
      children: [
        _buildKPICard(
          'Producción Total',
          '${_formatoNumero.format(produccion)} Ton/h',
          MdiIcons.packageVariantClosed,
          ColoresTema.accent1,
        ),
        _buildKPICard(
          'Eficiencia',
          '${_formatoNumero.format(92.8)}%',
          MdiIcons.chartLineVariant,
          ColoresTema.success,
        ),
        _buildKPICard(
          'Presión Promedio',
          '${_formatoNumero.format(presion)} PSI',
          MdiIcons.gauge,
          ColoresTema.warning,
        ),
        _buildKPICard(
          'Temperatura',
          '${_formatoNumero.format(temperatura)} °C',
          MdiIcons.thermometer,
          ColoresTema.error,
        ),
      ],
    );
  }

  Widget _buildKPICard(String titulo, String valor, IconData icono, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icono, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              titulo,
              style: TextStyle(
                color: ColoresTema.textSecondary,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              valor,
              style: TextStyle(
                color: ColoresTema.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGraficaTendencias() {
    final datos = _historico
      .where((h) => h.tipo == 'produccion')
      .toList()
      ..sort((a, b) => a.fecha.compareTo(b.fecha));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(MdiIcons.chartLine, color: ColoresTema.accent1),
                const SizedBox(width: 8),
                const Text('Tendencia de Producción',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: ColoresTema.border.withOpacity(0.2),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: datos.asMap().entries.map((e) {
                        return FlSpot(e.key.toDouble(), e.value.valor);
                      }).toList(),
                      isCurved: true,
                      color: ColoresTema.accent1,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          if (value.toInt() >= datos.length) return const Text('');
                          return Text(
                            DateFormat('dd/MM').format(datos[value.toInt()].fecha),
                            style: TextStyle(
                              color: ColoresTema.textSecondary,
                              fontSize: 10,
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) => Text(
                          _formatoNumero.format(value),
                          style: TextStyle(
                            color: ColoresTema.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildLeyenda(String texto, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(texto),
      ],
    );
  }

  Widget _buildTablaResumen() {
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Variable')),
            DataColumn(label: Text('Valor Actual')),
            DataColumn(label: Text('Mínimo')),
            DataColumn(label: Text('Máximo')),
            DataColumn(label: Text('Promedio')),
          ],
          rows: [
            _buildFilaResumen('Temperatura', 'temperatura_digestor', '°C'),
            _buildFilaResumen('Presión', 'presion_vapor', 'PSI'),
            _buildFilaResumen('Producción', 'produccion', 'Ton/h'),
            _buildFilaResumen('Nivel', 'nivel_tanque', '%'),
          ],
        ),
      ),
    );
  }

  DataRow _buildFilaResumen(String nombre, String tipo, String unidad) {
    final datos = _historico.where((h) => h.tipo == tipo).toList();
    if (datos.isEmpty) return DataRow(cells: List.filled(5, const DataCell(Text('-'))));

    final actual = datos.first.valor;
    final minimo = datos.map((d) => d.valor).reduce(min);
    final maximo = datos.map((d) => d.valor).reduce(max);
    final promedio = datos.map((d) => d.valor).average;

    return DataRow(cells: [
      DataCell(Text(nombre)),
      DataCell(Text('${_formatoNumero.format(actual)} $unidad')),
      DataCell(Text('${_formatoNumero.format(minimo)} $unidad')),
      DataCell(Text('${_formatoNumero.format(maximo)} $unidad')),
      DataCell(Text('${_formatoNumero.format(promedio)} $unidad')),
    ]);
  }

  Widget _buildGraficoHistorico() {
    final datosTemp = _historico
        .where((h) => h.tipo == 'temperatura_digestor')
        .toList()
      ..sort((a, b) => a.fecha.compareTo(b.fecha));

    final datosPres = _historico
        .where((h) => h.tipo == 'presion_vapor')
        .toList()
      ..sort((a, b) => a.fecha.compareTo(b.fecha));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(MdiIcons.chartMultiline, color: ColoresTema.accent1),
                const SizedBox(width: 8),
                const Text('Histórico de Variables',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: ColoresTema.border.withOpacity(0.2),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: datosTemp.asMap().entries.map((e) {
                        return FlSpot(e.key.toDouble(), e.value.valor);
                      }).toList(),
                      isCurved: true,
                      color: ColoresTema.accent1,
                      dotData: FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: datosPres.asMap().entries.map((e) {
                        return FlSpot(e.key.toDouble(), e.value.valor);
                      }).toList(),
                      isCurved: true,
                      color: ColoresTema.accent2,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) => Text(
                          _formatoNumero.format(value),
                          style: TextStyle(
                            color: ColoresTema.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          if (value.toInt() >= datosTemp.length) return const Text('');
                          return Text(
                            DateFormat('dd/MM').format(datosTemp[value.toInt()].fecha),
                            style: TextStyle(
                              color: ColoresTema.textSecondary,
                              fontSize: 10,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLeyenda('Temperatura', ColoresTema.accent1),
                const SizedBox(width: 16),
                _buildLeyenda('Presión', ColoresTema.accent2),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProceso(String proceso) {
    return RefreshIndicator(
      onRefresh: _actualizarDatos,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Digestor 1
            _buildEquipoCard(
              'Digestor',
              MdiIcons.tank,
              [
                _buildVariable('Nivel', '85%'),
                _buildVariable('Temperatura', '92°C'),
                _buildVariable('Intensidad', '39 A'),
              ],
            ),

            // Prensa 1
            _buildEquipoCard(
              'Prensa',
              MdiIcons.engine,
              [
                _buildSeccionVariables('Variables motor', [
                  _buildVariable('Velocidad', '20 RPM'),
                  _buildVariable('Intensidad', '12 A'),
                  _buildVariable('Torque', '30 Nm'),
                ]),
                _buildSeccionVariables('Capacidad', [
                  _buildVariable('Toneladas/Hora', '20'),
                  _buildVariable('Toneladas/Día', '400'),
                ]),
                _buildSeccionVariables('Horómetro', [
                  _buildVariable('Canastas', '120 h'),
                  _buildVariable('Tornillos', '20 h'),
                  _buildVariable('General', '230 h'),
                ]),
              ],
            ),

            // Unidad H
            _buildEquipoCard(
              'Unidad Hidráulica',
              MdiIcons.pump,
              [
                _buildVariable('Presión', '120 PSI'),
                _buildVariable('Desplazamiento', '10%'),
              ],
            ),
          ],
        ),
      ),
    );
  }

Widget _buildEquipoCard(String titulo, IconData icono, List<Widget> contenido) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icono, color: ColoresTema.accent1),
                const SizedBox(width: 8),
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            ...contenido,
          ],
        ),
      ),
    );
  }

  Widget _buildSeccionVariables(String titulo, List<Widget> variables) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: Text(
            titulo,
            style: TextStyle(
              color: ColoresTema.accent2,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...variables,
      ],
    );
  }

  Widget _buildVariable(String nombre, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(nombre),
          Text(
            valor,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconoElemento(TipoElemento tipo) {
    switch (tipo) {
      case TipoElemento.digestor:
        return MdiIcons.tank;
      case TipoElemento.valvula:
        return MdiIcons.valve;
      case TipoElemento.motor:
        return MdiIcons.engine;
      case TipoElemento.bomba:
        return MdiIcons.pump;
      case TipoElemento.caldera:
        return MdiIcons.waterBoiler;
      case TipoElemento.banda:
        return MdiIcons.elevator;
      case TipoElemento.desfibrador:
        return MdiIcons.blenderOutline;
      case TipoElemento.prensa:
        return MdiIcons.carBrakeHold;
      case TipoElemento.rensa:
        return MdiIcons.robotIndustrialOutline;
      case TipoElemento.sensor:
        return MdiIcons.gauge;
      case TipoElemento.tuberia:
        return MdiIcons.pipe;
      case TipoElemento.compuerta:
        return MdiIcons.gate;
    }
  }

  String _getResumenElemento(ElementoProceso elemento) {
    final estado = elemento.propiedades['estado'] == true ? 'Activo' : 'Inactivo';
    final temp = elemento.propiedades['temperatura'];
    final pres = elemento.propiedades['presion'];
    
    final detalles = <String>[];
    if (temp != null) detalles.add('${_formatoNumero.format(temp)}°C');
    if (pres != null) detalles.add('${_formatoNumero.format(pres)} PSI');
    
    return '$estado | ${detalles.join(" | ")}';
  }

  String _formatearValor(dynamic valor, String clave) {
    if (valor is bool) return valor ? 'Activo' : 'Inactivo';
    if (valor is num) {
      if (clave.contains('temperatura')) return '${_formatoNumero.format(valor)}°C';
      if (clave.contains('presion')) return '${_formatoNumero.format(valor)} PSI';
      if (clave.contains('corriente')) return '${_formatoNumero.format(valor)} A';
      if (clave.contains('velocidad')) return '${_formatoNumero.format(valor)} RPM';
      if (clave.contains('produccion')) return '${_formatoNumero.format(valor)} Ton/h';
      if (clave.contains('nivel')) return '${_formatoNumero.format(valor)}%';
    }
    return valor.toString();
  }
}