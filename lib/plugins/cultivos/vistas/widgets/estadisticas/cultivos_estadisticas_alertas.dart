//lib/plugins/cultivos/vistas/widgets/cultivos_estadisticas_alertas.dart
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../servicios/cultivos_service.dart';
import '../../../modelos/cultivos_models.dart';
import '../../../../../core/temas/tema_personalizado.dart';

class CultivosEstadisticasAlertas extends StatelessWidget {
  const CultivosEstadisticasAlertas({super.key});

  @override
  Widget build(BuildContext context) {
    final servicio = GetIt.I<CultivosService>();

    return StreamBuilder<List<Siembra>>(
      stream: servicio.streamSiembrasFiltradas(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final alertas = _generarAlertas(snapshot.data!);

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: alertas.length,
          itemBuilder: (context, index) {
            final alerta = alertas[index];
            return Card(
              color: ColoresTema.cardBackground,
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: alerta.color.withOpacity(0.2),
                  child: Icon(alerta.icono, color: alerta.color, size: 20),
                ),
                title: Text(alerta.titulo,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(alerta.descripcion),
                    if (alerta.accion != null) ...[
                      const SizedBox(height: 4),
                      Text('→ ${alerta.accion!}',
                        style: TextStyle(color: ColoresTema.accent1)),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<_AlertaCultivo> _generarAlertas(List<Siembra> siembras) {
    final alertas = <_AlertaCultivo>[];

    for (var siembra in siembras) {
      // Alerta de cosecha atrasada
      if (siembra.fechaFinEstimada != null &&
          siembra.fechaFinEstimada!.isBefore(DateTime.now()) &&
          siembra.porcentajeAreaCosechada < 100) {
        alertas.add(
          _AlertaCultivo(
            titulo: 'Cosecha Atrasada',
            descripcion: 'La fecha estimada de fin ya pasó y aún queda ${(100 - siembra.porcentajeAreaCosechada).toStringAsFixed(1)}% por cosechar.',
            color: ColoresTema.warning,
            icono: MdiIcons.alertCircleOutline,
            accion: 'Actualizar cronograma de cosecha',
          ),
        );
      }

      // Alerta de bajo rendimiento
      if (siembra.hectareasCosechadas > 0 && siembra.kgPorHectareaCosechada < 15000) {
        alertas.add(
          _AlertaCultivo(
            titulo: 'Bajo Rendimiento',
            descripcion: 'El rendimiento actual es de ${siembra.kgPorHectareaCosechada.toStringAsFixed(0)} Kg/Ha en el lote ${siembra.codigoLote}.',
            color: ColoresTema.error,
            icono: MdiIcons.trendingDown,
            accion: 'Revisar manejo del cultivo',
          ),
        );
      }

      // Alerta de presupuesto
      if (siembra.porcentajeInversion > 90 && !siembra.estado.nombre.toUpperCase().contains('FINALIZADO')) {
        alertas.add(
          _AlertaCultivo(
            titulo: 'Presupuesto Crítico',
            descripcion: 'Se ha ejecutado el ${siembra.porcentajeInversion.toStringAsFixed(1)}% del presupuesto en el lote ${siembra.codigoLote}.',
            color: ColoresTema.error,
            icono: MdiIcons.cashRemove,
            accion: 'Revisar ejecución presupuestal',
          ),
        );
      }
    }

    return alertas;
  }
}

class _AlertaCultivo {
  final String titulo;
  final String descripcion;
  final Color color;
  final IconData icono;
  final String? accion;

  _AlertaCultivo({
    required this.titulo,
    required this.descripcion,
    required this.color,
    required this.icono,
    this.accion,
  });
}