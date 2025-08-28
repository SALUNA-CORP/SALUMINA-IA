// lib/plugins/icg_frontrest/vistas/widgets/tabla_ranking.dart
import 'package:flutter/material.dart';
import '../../modelos/rest_venta_costo.dart';
import '../../../../core/temas/tema_personalizado.dart';
import 'package:intl/intl.dart';

class TablaRanking extends StatefulWidget {
  final List<VentaCosto> ventasCostos;

  const TablaRanking({
    super.key,
    required this.ventasCostos,
  });

  @override
  State<TablaRanking> createState() => _TablaRankingState();
}

class _TablaRankingState extends State<TablaRanking> {
  String _columnaOrden = 'venta';
  bool _ascendente = false;
  String _filtro = '';

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ranking de Productos',
              style: TextStyle(
                color: ColoresTema.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: (valor) {
                setState(() {
                  _filtro = valor.toLowerCase();
                });
              },
              decoration: InputDecoration(
                labelText: 'Buscar',
                prefixIcon: Icon(
                  Icons.search,
                  color: ColoresTema.accent1,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(
                    label: const Text('Referencia'),
                    onSort: (_, __) => _ordenar('referencia'),
                  ),
                  DataColumn(
                    label: const Text('Descripción'),
                    onSort: (_, __) => _ordenar('descripcion'),
                  ),
                  DataColumn(
                    label: const Text('Sección'),
                    onSort: (_, __) => _ordenar('seccion'),
                  ),
                  DataColumn(
                    label: const Text('Cantidad'),
                    numeric: true,
                    onSort: (_, __) => _ordenar('cantidad'),
                  ),
                  DataColumn(
                    label: const Text('Venta'),
                    numeric: true,
                    onSort: (_, __) => _ordenar('venta'),
                  ),
                  DataColumn(
                    label: const Text('Costo'),
                    numeric: true,
                    onSort: (_, __) => _ordenar('costo'),
                  ),
                  DataColumn(
                    label: const Text('Margen'),
                    numeric: true,
                    onSort: (_, __) => _ordenar('margen'),
                  ),
                  DataColumn(
                    label: const Text('% Margen'),
                    numeric: true,
                    onSort: (_, __) => _ordenar('porcentajeMargen'),
                  ),
                ],
                rows: _obtenerFilas(productosOrdenados: _ordenarProductos(
                  _filtrarProductos(widget.ventasCostos)
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<VentaCosto> _filtrarProductos(List<VentaCosto> productos) {
    if (_filtro.isEmpty) return productos;
    return productos.where((p) =>
      p.descripcion.toLowerCase().contains(_filtro) ||
      p.referencia.toLowerCase().contains(_filtro) ||
      p.seccion.toLowerCase().contains(_filtro)
    ).toList();
  }

  void _ordenar(String columna) {
    setState(() {
      if (_columnaOrden == columna) {
        _ascendente = !_ascendente;
      } else {
        _columnaOrden = columna;
        _ascendente = false;
      }
    });
  }

  List<VentaCosto> _ordenarProductos(List<VentaCosto> productos) {
    return List<VentaCosto>.from(productos)..sort((a, b) {
      int comparacion;
      switch (_columnaOrden) {
        case 'referencia':
          comparacion = a.referencia.compareTo(b.referencia);
          break;
        case 'descripcion':
          comparacion = a.descripcion.compareTo(b.descripcion);
          break;
        case 'seccion':
          comparacion = a.seccion.compareTo(b.seccion);
          break;
        case 'cantidad':
          comparacion = a.cantidad.compareTo(b.cantidad);
          break;
        case 'venta':
          comparacion = a.venta.compareTo(b.venta);
          break;
        case 'costo':
          comparacion = a.costo.compareTo(b.costo);
          break;
        case 'margen':
          comparacion = a.margenBruto.compareTo(b.margenBruto);
          break;
        case 'porcentajeMargen':
          comparacion = a.margenPorcentaje.compareTo(b.margenPorcentaje);
          break;
        default:
          comparacion = 0;
      }
      return _ascendente ? comparacion : -comparacion;
    });
  }

  List<DataRow> _obtenerFilas({
    required List<VentaCosto> productosOrdenados
  }) {
    final formatoMoneda = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
      locale: 'es_CO',
    );

    return productosOrdenados.map((producto) {
      return DataRow(
        cells: [
          DataCell(Text(producto.referencia)),
          DataCell(Text(producto.descripcion)),
          DataCell(Text(producto.seccion)),
          DataCell(Text(producto.cantidad.toString())),
          DataCell(Text(formatoMoneda.format(producto.venta))),
          DataCell(Text(formatoMoneda.format(producto.costo))),
          DataCell(Text(formatoMoneda.format(producto.margenBruto))),
          DataCell(
            Text(
              '${producto.margenPorcentaje.toStringAsFixed(1)}%',
              style: TextStyle(
                color: _getColorMargen(producto.margenPorcentaje),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    }).toList();
  }

  Color _getColorMargen(double margen) {
    if (margen >= 30) return ColoresTema.success;
    if (margen >= 15) return ColoresTema.warning;
    return ColoresTema.error;
  }
}