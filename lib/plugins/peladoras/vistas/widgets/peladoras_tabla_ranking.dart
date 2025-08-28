// lib/plugins/peladoras/vistas/widgets/tabla_ranking.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../modelos/peladoras_toma.dart';
import '../../modelos/peladoras_estadisticas.dart';
import '../../utils/peladoras_calculadora_estadisticas.dart';
import 'peladoras_badge_alertas.dart';
import '../../../../core/temas/tema_personalizado.dart';

class TablaRanking extends StatefulWidget {
  final List<Toma> tomas;
  const TablaRanking({super.key, required this.tomas});

  @override
  State<TablaRanking> createState() => _TablaRankingState();
}

class _TablaRankingState extends State<TablaRanking> {
  final _formatoNumero = NumberFormat("#,##0.0", "es_CO");
  final _formatoMoneda = NumberFormat.currency(locale: 'es_CO', symbol: '\$');
  final _formatoFecha = DateFormat("dd/MM/yyyy", "es_CO");
  EstadisticasPeladora? _peladoraSeleccionada;

  @override
  Widget build(BuildContext context) {
    final estadisticas = CalculadoraEstadisticas.procesarEstadisticas(widget.tomas)
      ..sort((a, b) => b.totalKg.compareTo(a.totalKg));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColoresTema.cardBackground,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: ColoresTema.border),
        boxShadow: [
          BoxShadow(
            color: ColoresTema.accent1.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _construirEncabezado(),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              showCheckboxColumn: false,
              columns: const [
                DataColumn(label: Text('Posición')),
                DataColumn(label: Text('Nombre')),
                DataColumn(label: Text('Total Kg'), numeric: true),
                DataColumn(label: Text('Eficiencia'), numeric: true),
                DataColumn(label: Text('Costo Total'), numeric: true),
                DataColumn(label: Text('Mejor Día')),
                DataColumn(label: Text('Días Trabajados'), numeric: true),
                DataColumn(label: Text('Días Meta'), numeric: true),
                DataColumn(label: Text('Calificación')),
                DataColumn(label: Text('Alertas')),
                DataColumn(label: Text('Estado')),
              ],
              rows: estadisticas.asMap().entries.map((entry) {
                final stats = entry.value;
                return _construirFila(entry.key + 1, stats);
              }).toList(),
            ),
          ),
          if (_peladoraSeleccionada != null) ...[
            const SizedBox(height: 20),
            _construirDetalleSeleccionado(_peladoraSeleccionada!),
          ],
        ],
      ),
    );
  }

  Widget _construirEncabezado() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        'Ranking de Peladoras',
        style: TextStyle(
          color: ColoresTema.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(
        'Meta Diaria: ${_formatoNumero.format(CalculadoraEstadisticas.META_DIARIA)} Kg',
        style: TextStyle(
          color: ColoresTema.accent2,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );

  DataRow _construirFila(int posicion, EstadisticasPeladora stats) {
    return DataRow(
      selected: _peladoraSeleccionada?.id == stats.id,
      onSelectChanged: (_) => setState(() {
        _peladoraSeleccionada = _peladoraSeleccionada?.id == stats.id ? null : stats;
      }),
      cells: [
        DataCell(_construirPosicion(posicion)),
        DataCell(Text(stats.nombreCompleto)),
        DataCell(Text('${_formatoNumero.format(stats.totalKg)} Kg')),
        DataCell(_construirEficiencia(stats.eficiencia)),
        DataCell(Text(_formatoMoneda.format(stats.totalCosto))),
        DataCell(_construirMejorDia(stats)),
        DataCell(Text(stats.diasTrabajados.toString())),
        DataCell(Text(stats.diasMeta.toString())),
        DataCell(_construirCalificacion(stats)),
        DataCell(BadgeAlertas(estadisticas: stats)),
        DataCell(_construirEstado(stats.activo)),
      ],
    );
  }

  Widget _construirPosicion(int posicion) {
    final color = switch(posicion) {
      1 => ColoresTema.accent1,
      2 => ColoresTema.accent2,
      3 => ColoresTema.warning,
      _ => ColoresTema.textSecondary
    };

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        '#$posicion',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _construirEficiencia(double eficiencia) {
    final color = CalculadoraEstadisticas.getColorEficiencia(eficiencia);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${eficiencia.toStringAsFixed(1)}%',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 100,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: eficiencia / 100,
              backgroundColor: color.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
      ],
    );
  }

  Widget _construirMejorDia(EstadisticasPeladora stats) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(_formatoFecha.format(stats.mejorDia)),
      Text(
        '${_formatoNumero.format(stats.kgMejorDia)} Kg',
        style: TextStyle(
          color: ColoresTema.accent2,
          fontSize: 12,
        ),
      ),
    ],
  );

  Widget _construirCalificacion(EstadisticasPeladora stats) => Row(
    mainAxisSize: MainAxisSize.min,
    children: List.generate(5, (index) => 
      Icon(
        index < stats.estrellas 
          ? MdiIcons.star
          : MdiIcons.starOutline,
        color: ColoresTema.accent1,
        size: 16,
      )
    ),
  );

  Widget _construirEstado(bool activo) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: activo ? ColoresTema.success : ColoresTema.error,
      borderRadius: BorderRadius.circular(15),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          activo ? Icons.check_circle : Icons.cancel,
          color: Colors.white,
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          activo ? 'Activo' : 'Inactivo',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );

  Widget _construirDetalleSeleccionado(EstadisticasPeladora stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Análisis Detallado - ${stats.nombreCompleto}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => setState(() => _peladoraSeleccionada = null),
                  icon: const Icon(Icons.close),
                  label: const Text('Cerrar'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMetricaDetalle(
                        'Productividad',
                        '${_formatoNumero.format(stats.promedioKgHora)} Kg/h',
                        Icons.speed,
                      ),
                      const SizedBox(height: 8),
                      _buildMetricaDetalle(
                        'Eficiencia',
                        '${stats.eficiencia.toStringAsFixed(1)}%',
                        Icons.trending_up,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMetricaDetalle(
                        'Costo por Kg',
                        _formatoMoneda.format(stats.costoPorKg),
                        Icons.payments,
                      ),
                      const SizedBox(height: 8),
                      _buildMetricaDetalle(
                        'Días Meta Cumplida',
                        '${stats.diasMeta} de ${stats.diasTrabajados}',
                        Icons.calendar_today,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricaDetalle(String titulo, String valor, IconData icono) {
    return Row(
      children: [
        Icon(icono, size: 20, color: ColoresTema.accent1),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: const TextStyle(fontSize: 12)),
            Text(
              valor,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}