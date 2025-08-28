//lib/plugins/cultivos/vistas/widgets/cultivos_lista_siembras.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../modelos/cultivos_models.dart';
import '../../../../core/temas/tema_personalizado.dart';

class ListaSiembras extends StatelessWidget {
  final List<Siembra> siembras;
  final void Function(String loteId)? onLoteSelected;
  final String? loteSeleccionadoId;

  const ListaSiembras({
    super.key,
    required this.siembras,
    this.onLoteSelected,
    this.loteSeleccionadoId
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: siembras.length,
      itemBuilder: (context, index) {
        final siembra = siembras[index];
        final isSelected = siembra.loteId == loteSeleccionadoId;
        return _SiembraListTile(
          siembra: siembra,
          isSelected: isSelected,
          onTap: () => onLoteSelected?.call(siembra.loteId),
        );
      },
    );
  }
}

class _SiembraListTile extends StatelessWidget {
  final Siembra siembra;
  final bool isSelected;
  final VoidCallback? onTap;

  const _SiembraListTile({
    required this.siembra,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final nombreLote = siembra.nombreLote ?? 'Lote sin nombre';
    final codigoLote = siembra.codigoLote ?? '';
    
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: siembra.color.withOpacity(0.2),
          child: Text(
            nombreLote.isNotEmpty ? nombreLote[0] : 'L',
            style: TextStyle(color: siembra.color),
          ),
        ),
        title: Text(nombreLote),
        subtitle: Row(
          children: [
            if (codigoLote.isNotEmpty) Text(
              codigoLote,
              style: TextStyle(
                color: ColoresTema.textSecondary,
                fontSize: 12,
              ),
            ),
            if (codigoLote.isNotEmpty) const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: siembra.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                siembra.tipo.nombre,
                style: TextStyle(
                  color: siembra.color,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${siembra.porcentajeInversion.toStringAsFixed(1)}%',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'inversión',
              style: TextStyle(
                color: ColoresTema.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}