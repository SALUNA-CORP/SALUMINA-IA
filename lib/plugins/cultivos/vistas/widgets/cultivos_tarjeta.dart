// lib/plugins/cultivos/vistas/widgets/tarjeta_cultivo.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../modelos/cultivos_models.dart';
import '../../../../core/temas/tema_personalizado.dart';

class TarjetaCultivo extends StatelessWidget {
  final Siembra siembra;
  final VoidCallback? onTap;

  const TarjetaCultivo({
    super.key,
    required this.siembra,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: siembra.color.withOpacity(0.2),
                    child: Text(
                      siembra.tipo.nombre[0],
                      style: TextStyle(color: siembra.color),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          siembra.tipo.nombre,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          DateFormat('dd/MM/yyyy').format(siembra.fechaInicio),
                          style: TextStyle(
                            color: ColoresTema.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: siembra.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      siembra.estado.nombre,
                      style: TextStyle(
                        color: siembra.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: siembra.porcentajeInversion / 100,
                backgroundColor: ColoresTema.accent1.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(ColoresTema.accent1),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${siembra.hectareasSembradas} Ha',
                    style: TextStyle(
                      color: ColoresTema.textSecondary,
                    ),
                  ),
                  Text(
                    '${siembra.porcentajeInversion.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
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
}