import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../modelos/partido.dart';
import '../../../../core/temas/tema_personalizado.dart';
import 'partido_detalles.dart';

class PartidoCard extends StatelessWidget {
  final Partido partido;

  const PartidoCard({
    super.key,
    required this.partido,
  });

  void _mostrarDetalles(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => PartidoDetalles(partido: partido),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: InkWell(
        onTap: () => _mostrarDetalles(context),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('HH:mm').format(partido.fecha),
                    style: TextStyle(
                      color: ColoresTema.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  _buildEstadoBadge(),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildEquipo(
                      nombre: partido.equipoLocal?.nombre ?? '',
                      escudo: partido.equipoLocal?.escudo,
                      alineacion: CrossAxisAlignment.end,
                    ),
                  ),
                  const SizedBox(width: 20),
                  _buildMarcador(),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildEquipo(
                      nombre: partido.equipoVisitante?.nombre ?? '',
                      escudo: partido.equipoVisitante?.escudo,
                      alineacion: CrossAxisAlignment.start,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEstadoBadge() {
    Color color;
    String texto;

    switch (partido.estado) {
      case EstadoPartido.en_curso:
        color = ColoresTema.warning;
        texto = 'EN CURSO';
        break;
      case EstadoPartido.finalizado:
        color = ColoresTema.success;
        texto = 'FINALIZADO';
        break;
      default:
        color = ColoresTema.accent1;
        texto = 'PENDIENTE';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        texto,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEquipo({
    required String nombre,
    String? escudo,
    required CrossAxisAlignment alineacion,
  }) {
    return Column(
      crossAxisAlignment: alineacion,
      children: [
        if (escudo != null)
          Image.network(
            escudo,
            width: 40,
            height: 40,
          ),
        const SizedBox(height: 8),
        Text(
          nombre,
          style: TextStyle(
            color: ColoresTema.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          textAlign: alineacion == CrossAxisAlignment.end 
            ? TextAlign.end 
            : TextAlign.start,
        ),
      ],
    );
  }

  Widget _buildMarcador() {
    final mostrarMarcador = partido.estado != EstadoPartido.pendiente;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: ColoresTema.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ColoresTema.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            mostrarMarcador 
              ? partido.golesLocal.toString() 
              : '-',
            style: TextStyle(
              color: ColoresTema.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              '-',
              style: TextStyle(
                color: ColoresTema.textSecondary,
                fontSize: 24,
              ),
            ),
          ),
          Text(
            mostrarMarcador 
              ? partido.golesVisitante.toString() 
              : '-',
            style: TextStyle(
              color: ColoresTema.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}