import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../../../../core/temas/tema_personalizado.dart';

enum EstadoMaquina { run, ready, fault }

class SensoresExtraccionVista extends StatefulWidget {
  final int digPrensa;

  const SensoresExtraccionVista({
    Key? key,
    required this.digPrensa,
  }) : super(key: key);

  @override
  State<SensoresExtraccionVista> createState() => _SensoresExtraccionVistaState();
}

class _SensoresExtraccionVistaState extends State<SensoresExtraccionVista> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final formatoHora = DateFormat('HH:mm');
  final formatoFecha = DateFormat('dd/MM/yyyy');
  final formatoNumero = NumberFormat('#,##0.0', 'es_CO');
  
  Map<String, bool> expandedSections = {
    'digestor': true,
    'prensa': true,
    'hidraulica': true,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Digestor - Prensa ${widget.digPrensa}'),
        bottom: TabBar(
          controller: _tabController,
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
          _buildProcesoTab(),
          _buildTendenciasTab(),
          _buildMantenimientoTab(),
          _buildProduccionTab(),
        ],
      ),
    );
  }

  // Métodos de construcción de la vista de Proceso
  Widget _buildProcesoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildExpandableSection(
            'Digestor',
            MdiIcons.engine,
            EstadoMaquina.run,
            _buildDigestorContent(),
          ),
          const SizedBox(height: 16),
          _buildExpandableSection(
            'Prensa',
            MdiIcons.engineOutline,
            EstadoMaquina.ready,
            _buildPrensaContent(),
          ),
          const SizedBox(height: 16),
          _buildExpandableSection(
            'Unidad Hidráulica',
            MdiIcons.waterPump,
            EstadoMaquina.fault,
            _buildHidraulicaContent(),
          ),
        ],
      ),
    );
  }
  // Widgets compartidos y métodos de construcción
  Widget _buildExpandableSection(
    String title,
    IconData icon,
    EstadoMaquina estado,
    Widget content,
  ) {
    final isExpanded = expandedSections[title.toLowerCase()] ?? false;
    
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(icon, color: ColoresTema.accent1),
            title: Text(title),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildEstadoIndicador(estado),
                const SizedBox(width: 8),
                Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
              ],
            ),
            onTap: () {
              setState(() {
                expandedSections[title.toLowerCase()] = !isExpanded;
              });
            },
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.all(16),
              child: content,
            ),
        ],
      ),
    );
  }

  Widget _buildEstadoIndicador(EstadoMaquina estado) {
    Color color;
    String texto;
    
    switch (estado) {
      case EstadoMaquina.run:
        color = Colors.green;
        texto = 'Run';
        break;
      case EstadoMaquina.ready:
        color = Colors.yellow;
        texto = 'Ready';
        break;
      case EstadoMaquina.fault:
        color = Colors.red;
        texto = 'Fault';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(texto, style: TextStyle(color: color)),
        ],
      ),
    );
  }

  Widget _buildDigestorContent() {
    return Column(
      children: [
        _buildDataRow('Nivel', '85', '%'),
        _buildDataRow('Temperatura', '92', '°C'),
        _buildDataRow('Intensidad', '39', 'A'),
      ],
    );
  }

  Widget _buildPrensaContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubsection('Variables motor', [
          _buildDataRow('Velocidad', '20', 'RPM'),
          _buildDataRow('Intensidad', '12', 'A'),
          _buildDataRow('Torque', '30', 'Nm'),
        ]),
        _buildSubsection('Capacidad', [
          _buildDataRow('Toneladas/Hora', '20', ''),
          _buildDataRow('Toneladas/Día', '400', ''),
        ]),
        _buildSubsection('Horómetro', [
          _buildDataRow('Canastas', '120', 'h'),
          _buildDataRow('Tornillos', '20', 'h'),
          _buildDataRow('General', '230', 'h'),
        ]),
      ],
    );
  }

  Widget _buildHidraulicaContent() {
    return Column(
      children: [
        _buildDataRow('Presión', '120', 'PSI'),
        _buildDataRow('Desplazamiento', '10', '%'),
      ],
    );
  }

  Widget _buildDataRow(String label, String value, String unit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text('$value $unit', style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSubsection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              color: ColoresTema.accent2,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  // Implementación de Tendencias
  Widget _buildTendenciasTab() {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            tabs: const [
              Tab(text: 'Digestor'),
              Tab(text: 'Prensa'),
              Tab(text: 'Hidráulica'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildDigestorTendencias(),
                _buildPrensaTendencias(),
                _buildHidraulicaTendencias(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGraficoTendencia(String titulo, List<_DatosTendencia> datos) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: ColoresTema.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  lineBarsData: datos.map((dato) =>
                    LineChartBarData(
                      spots: List.generate(24, (i) {
                        return FlSpot(
                          i.toDouble(),
                          dato.min + (dato.max - dato.min) * Random().nextDouble(),
                        );
                      }),
                      isCurved: true,
                      color: dato.color,
                      barWidth: 2,
                      dotData: FlDotData(show: false),
                    ),
                  ).toList(),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      axisNameWidget: const Text('Tiempo (horas)'),
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) => 
                          Text(value.toInt().toString()),
                      ),
                    ),
                    leftTitles: AxisTitles(
                      axisNameWidget: Text('Valor (${datos.first.unidad})'),
                      sideTitles: SideTitles(showTitles: true),
                    ),
                  ),
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: true),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              children: datos.map((dato) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: dato.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(dato.nombre),
                ],
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildDigestorTendencias() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildGraficoTendencia(
            'Temperatura vs Presión',
            [
              _DatosTendencia('Temperatura', Colors.red, '°C', 85, 95),
              _DatosTendencia('Presión', Colors.blue, 'PSI', 40, 60),
            ],
          ),
          const SizedBox(height: 16),
          _buildGraficoTendencia(
            'Nivel y Eficiencia',
            [
              _DatosTendencia('Nivel', Colors.green, '%', 70, 90),
              _DatosTendencia('Eficiencia', Colors.amber, '%', 80, 100),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrensaTendencias() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildGraficoTendencia(
            'Velocidad y Torque',
            [
              _DatosTendencia('Velocidad', Colors.purple, 'RPM', 15, 25),
              _DatosTendencia('Torque', Colors.orange, 'Nm', 25, 35),
            ],
          ),
          const SizedBox(height: 16),
          _buildGraficoTendencia(
            'Producción Horaria',
            [
              _DatosTendencia('Toneladas/Hora', Colors.green, 'T/h', 15, 25),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHidraulicaTendencias() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildGraficoTendencia(
            'Presión del Sistema',
            [
              _DatosTendencia('Presión', Colors.blue, 'PSI', 110, 130),
            ],
          ),
          const SizedBox(height: 16),
          _buildGraficoTendencia(
            'Desplazamiento',
            [
              _DatosTendencia('Desplazamiento', Colors.amber, '%', 5, 15),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildMantenimientoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAlertasMantenimiento(),
          const SizedBox(height: 16),
          _buildPlanMantenimiento(),
          const SizedBox(height: 16),
          _buildIndicadoresMantenimiento(),
        ],
      ),
    );
  }

  Widget _buildAlertasMantenimiento() {
    final alertas = [
      _AlertaMantenimiento(
        'Crítica',
        'Cambio de rodamientos en Prensa 1',
        'Vibración excesiva detectada',
        DateTime.now().add(const Duration(hours: 24)),
        true,
      ),
      _AlertaMantenimiento(
        'Preventivo',
        'Lubricación general Digestor',
        'Mantenimiento programado',
        DateTime.now().add(const Duration(days: 5)),
        false,
      ),
    ];

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(MdiIcons.alertCircle, color: ColoresTema.accent1),
                const SizedBox(width: 8),
                const Text(
                  'Alertas de Mantenimiento',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: alertas.length,
            itemBuilder: (context, index) {
              final alerta = alertas[index];
              return ListTile(
                leading: Icon(
                  alerta.critica ? MdiIcons.alertCircle : MdiIcons.information,
                  color: alerta.critica ? Colors.red : Colors.amber,
                ),
                title: Text(alerta.titulo),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(alerta.descripcion),
                    Text(
                      'Vence: ${formatoFecha.format(alerta.fecha)}',
                      style: TextStyle(color: ColoresTema.accent2),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  Widget _buildPlanMantenimiento() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Plan de Mantenimiento',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ColoresTema.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Equipo')),
                  DataColumn(label: Text('Tipo')),
                  DataColumn(label: Text('Frecuencia')),
                  DataColumn(label: Text('Próximo')),
                  DataColumn(label: Text('Estado')),
                ],
                rows: [
                  DataRow(cells: [
                    const DataCell(Text('Digestor')),
                    const DataCell(Text('Preventivo')),
                    const DataCell(Text('Mensual')),
                    DataCell(Text(formatoFecha.format(
                      DateTime.now().add(const Duration(days: 15))))),
                    const DataCell(Text('Pendiente')),
                  ]),
                  DataRow(cells: [
                    const DataCell(Text('Prensa')),
                    const DataCell(Text('Predictivo')),
                    const DataCell(Text('Trimestral')),
                    DataCell(Text(formatoFecha.format(
                      DateTime.now().add(const Duration(days: 45))))),
                    const DataCell(Text('En Proceso')),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicadoresMantenimiento() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Indicadores de Mantenimiento',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ColoresTema.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildIndicadorCard(
                    'MTBF',
                    '120h',
                    'Tiempo medio entre fallas',
                    MdiIcons.chartLine,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildIndicadorCard(
                    'MTTR',
                    '4.5h',
                    'Tiempo medio de reparación',
                    MdiIcons.wrench,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildIndicadorCard(
                    'Disponibilidad',
                    '96.4%',
                    'Disponibilidad total',
                    MdiIcons.check,
                    Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildIndicadorCard(
    String titulo,
    String valor,
    String subtitulo,
    IconData icono,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icono, color: color, size: 32),
          const SizedBox(height: 8),
          Text(valor,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(titulo,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(subtitulo,
            style: TextStyle(
              fontSize: 12,
              color: ColoresTema.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProduccionTab() {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Diario'),
              Tab(text: 'Mensual'),
              Tab(text: 'Anual'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildProduccionDiaria(),
                _buildProduccionMensual(),
                _buildProduccionAnual(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProduccionDiaria() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildTarjetaResumen(
            'Producción del Día',
            [
              _DatoProduccion('Toneladas procesadas', 125.5),
              _DatoProduccion('Eficiencia', 92.3, unidad: '%'),
              _DatoProduccion('Tiempo efectivo', 22.5, unidad: 'h'),
            ],
          ),
          const SizedBox(height: 16),
          _buildTablaProduccionTurnos(),
        ],
      ),
    );
  }
  Widget _buildProduccionMensual() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildTarjetaResumen(
            'Producción del Mes',
            [
              _DatoProduccion('Toneladas acumuladas', 3750.5),
              _DatoProduccion('Promedio diario', 125.0),
              _DatoProduccion('Eficiencia', 89.7, unidad: '%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProduccionAnual() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildTarjetaResumen(
            'Producción Anual',
            [
              _DatoProduccion('Toneladas acumuladas', 45000.0),
              _DatoProduccion('Promedio mensual', 3750.0),
              _DatoProduccion('Eficiencia', 91.2, unidad: '%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTarjetaResumen(String titulo, List<_DatoProduccion> datos) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ColoresTema.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ...datos.map((dato) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(dato.nombre),
                  Text(
                    '${formatoNumero.format(dato.valor)}${dato.unidad.isNotEmpty ? ' ${dato.unidad}' : ''}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTablaProduccionTurnos() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Producción por Turnos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ColoresTema.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Turno')),
                  DataColumn(label: Text('Hora Inicio')),
                  DataColumn(label: Text('Hora Fin')),
                  DataColumn(label: Text('Toneladas')),
                  DataColumn(label: Text('Eficiencia')),
                ],
                rows: [
                  DataRow(cells: [
                    const DataCell(Text('1')),
                    const DataCell(Text('06:00')),
                    const DataCell(Text('14:00')),
                    DataCell(Text(formatoNumero.format(42.5))),
                    const DataCell(Text('94.2%')),
                  ]),
                  DataRow(cells: [
                    const DataCell(Text('2')),
                    const DataCell(Text('14:00')),
                    const DataCell(Text('22:00')),
                    DataCell(Text(formatoNumero.format(40.8))),
                    const DataCell(Text('90.7%')),
                  ]),
                  DataRow(cells: [
                    const DataCell(Text('3')),
                    const DataCell(Text('22:00')),
                    const DataCell(Text('06:00')),
                    DataCell(Text(formatoNumero.format(42.2))),
                    const DataCell(Text('93.8%')),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DatosTendencia {
  final String nombre;
  final Color color;
  final String unidad;
  final double min;
  final double max;

  _DatosTendencia(this.nombre, this.color, this.unidad, this.min, this.max);
}

class _AlertaMantenimiento {
  final String tipo;
  final String titulo;
  final String descripcion;
  final DateTime fecha;
  final bool critica;

  _AlertaMantenimiento(this.tipo, this.titulo, this.descripcion, this.fecha, this.critica);
}

class _DatoProduccion {
  final String nombre;
  final double valor;
  final String unidad;

  _DatoProduccion(this.nombre, this.valor, {this.unidad = ''});
}