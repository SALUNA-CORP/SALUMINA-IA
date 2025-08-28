// lib/plugins/icg_frontrest/widgets/rest_kpi_cards.dart
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../modelos/rest_kpi_data.dart';
import 'rest_base_card.dart';
import 'rest_progress_indicator.dart';
import '../../../../core/temas/tema_personalizado.dart';

String _formatearMoneda(double valor) {
  if (valor >= 1000000) return '\$${(valor / 1000000).toStringAsFixed(1)}M';
  if (valor >= 1000) return '\$${(valor / 1000).toStringAsFixed(1)}K';
  return '\$${valor.toStringAsFixed(0)}';
}

class VentasKPICard extends StatelessWidget {
  final KPIData data;
  final bool isMobile;

  const VentasKPICard({
    Key? key,
    required this.data,
    this.isMobile = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseKPICard(
      title: data.etiqueta,
      icon: MdiIcons.cashRegister,
      color: ColoresTema.accent1,
      isMobile: isMobile,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatearMoneda(data.valor),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: ColoresTema.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          KPIProgressIndicator(
            label: 'Margen Bruto',
            value: data.porcentaje,
            color: ColoresTema.accent1,
          ),
          const SizedBox(height: 4),
          Text(
            'MB: ${_formatearMoneda(data.datos!['margenBruto'])}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: ColoresTema.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class CostosKPICard extends StatelessWidget {
  final KPIData data;
  final bool isMobile;

  const CostosKPICard({
    Key? key,
    required this.data,
    this.isMobile = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseKPICard(
      title: data.etiqueta,
      icon: MdiIcons.chartPie,
      color: ColoresTema.warning,
      isMobile: isMobile,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatearMoneda(data.valor),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: ColoresTema.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: KPIProgressIndicator(
                  label: 'Fijos',
                  value: data.distribucion!['fijos']!,
                  color: ColoresTema.error,
                  compact: true,
                ),
              ),
              Expanded(
                child: KPIProgressIndicator(
                  label: 'Variables',
                  value: data.distribucion!['variables']!,
                  color: ColoresTema.warning,
                  compact: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class UtilidadKPICard extends StatelessWidget {
  final KPIData data;
  final bool isMobile;

  const UtilidadKPICard({
    Key? key,
    required this.data,
    this.isMobile = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final positive = data.valor > 0;
    final color = positive ? ColoresTema.success : ColoresTema.error;

    return BaseKPICard(
      title: data.etiqueta,
      icon: MdiIcons.trendingUp,
      color: color,
      isMobile: isMobile,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                _formatearMoneda(data.valor.abs()),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                data.tendencia!,
                style: const TextStyle(fontSize: 24),
              ),
            ],
          ),
          const SizedBox(height: 8),
          KPIProgressIndicator(
            label: 'Margen de Utilidad',
            value: data.porcentaje,
            color: color,
          ),
        ],
      ),
    );
  }
}

class ProductosKPICard extends StatelessWidget {
  final KPIData data;
  final bool isMobile;

  const ProductosKPICard({
    Key? key,
    required this.data,
    this.isMobile = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rentable = data.datos!['rentable'] as KPIProducto;
    final vendido = data.datos!['vendido'] as KPIProducto;

    return BaseKPICard(
      title: data.etiqueta,
      icon: MdiIcons.star,
      color: ColoresTema.accent2,
      isMobile: isMobile,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProductoDestacado(
            icono: MdiIcons.chartLine,
            titulo: 'Más Rentable',
            nombre: rentable.nombre,
            metrica: rentable.metrica,
            subtitulo: rentable.subtitulo,
            color: ColoresTema.success,
          ),
          const Divider(height: 16),
          _ProductoDestacado(
            icono: MdiIcons.package,
            titulo: 'Más Vendido',
            nombre: vendido.nombre,
            metrica: vendido.metrica,
            subtitulo: vendido.subtitulo,
            color: ColoresTema.accent1,
          ),
        ],
      ),
    );
  }
}

class _ProductoDestacado extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String nombre;
  final String metrica;
  final String subtitulo;
  final Color color;

  const _ProductoDestacado({
    required this.icono,
    required this.titulo,
    required this.nombre,
    required this.metrica,
    required this.subtitulo,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icono, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: ColoresTema.textSecondary,
                ),
              ),
              Text(
                nombre,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: ColoresTema.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              metrica,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitulo,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: ColoresTema.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}