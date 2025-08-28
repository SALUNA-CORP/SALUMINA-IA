import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../servicios/cultivos_service.dart';
import '../../../modelos/cultivos_models.dart';
import '../../../../../core/temas/tema_personalizado.dart';

class _DatosMes {
  final double rendimiento;
  final int siembras;
  final List<String> lotes;
  final String tipoCultivo;
  final int year;
  final double totalKilos;

  const _DatosMes({
    this.rendimiento = 0.0,
    this.siembras = 0,
    required this.lotes,
    required this.tipoCultivo,
    required this.year,
    this.totalKilos = 0.0,
  });
}

class CultivosEstadisticasEstacionalidad extends StatelessWidget {
  const CultivosEstadisticasEstacionalidad({super.key});

  @override
  Widget build(BuildContext context) {
    final servicio = GetIt.I<CultivosService>();
    final formatoNumero = NumberFormat('#,##0.0', 'es_CO');

    return Card(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(MdiIcons.chartTimelineVariant, 
                    color: ColoresTema.accent1, 
                    size: 24
                  ),
                  const SizedBox(width: 12),
                  Text('Estacionalidad de Cultivos',
                    style: TextStyle(
                      color: ColoresTema.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    )),
                ],
              ),
              const SizedBox(height: 24),
              StreamBuilder<List<Siembra>>(
                stream: servicio.streamSiembrasFiltradas(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator()
                    );
                  }

                  final siembras = snapshot.data!;
                  if (siembras.isEmpty) {
                    return Center(
                      child: Text('No hay datos disponibles',
                        style: TextStyle(color: ColoresTema.textSecondary))
                    );
                  }

                  final datos = _procesarDatos(siembras);
                  final mejoresMeses = _obtenerMejoresMeses(datos);
                  final years = datos.keys.toList()..sort();

                  return Column(
                    children: [
                      ...years.map((year) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              'Año $year',
                              style: TextStyle(
                                color: ColoresTema.accent1,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 200,
                            child: GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 6,
                                childAspectRatio: 1.5,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: 12,
                              itemBuilder: (context, index) {
                                final mes = DateTime(year, index + 1);
                                final datosDelMes = datos[year]?[index + 1] ?? 
                                  _DatosMes(
                                    lotes: [], 
                                    tipoCultivo: '', 
                                    year: year,
                                    totalKilos: 0.0
                                  );
                                
                                return _construirTarjetaMes(mes, datosDelMes);
                              },
                            ),
                          ),
                        ],
                      )).toList(),
                      const SizedBox(height: 24),
                      _construirResumenAnual(datos),
                      const SizedBox(height: 16),
                      _construirResumenEstacional(mejoresMeses),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirTarjetaMes(DateTime mes, _DatosMes datos) {
    final valor = datos.siembras > 0 ? datos.rendimiento / datos.siembras : 0.0;
    final formatoNumero = NumberFormat('#,##0.0', 'es_CO');
    final nombreMes = DateFormat('MMMM', 'es_CO').format(mes).toLowerCase();
    
    return Tooltip(
      message: datos.siembras > 0 
        ? '''
          $nombreMes ${datos.year}
          ${datos.tipoCultivo}
          Total: ${formatoNumero.format(datos.totalKilos)} Kg
          Rendimiento: ${formatoNumero.format(valor)} Kg/Ha
          Siembras: ${datos.siembras}
          Lotes: ${datos.lotes.join(', ')}
        '''
        : 'Sin datos para $nombreMes',
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _obtenerColorFondo(valor),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _obtenerColorBorde(valor),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _obtenerColorBorde(valor).withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: datos.siembras > 0 ? 1 : 0,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(nombreMes,
              style: TextStyle(
                color: datos.siembras > 0 
                  ? ColoresTema.textPrimary 
                  : ColoresTema.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            if (datos.siembras > 0) ...[
              const SizedBox(height: 8),
              Text('${formatoNumero.format(datos.totalKilos)} Kg',
                style: TextStyle(
                  color: ColoresTema.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text('${datos.siembras} siembras',
                style: TextStyle(
                  color: ColoresTema.textSecondary,
                  fontSize: 11,
                ),
              ),
            ] else
              Text('Sin datos',
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

  Widget _construirResumenEstacional(List<(int, double, int)> mejoresMeses) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColoresTema.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColoresTema.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(MdiIcons.podium, 
                color: ColoresTema.accent1,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text('Mejores Meses',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                )),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: mejoresMeses.map((mes) {
              final nombreMes = DateFormat('MMMM yyyy', 'es_CO')
                .format(DateTime(mes.$3, mes.$1));
              return Chip(
                label: Text(nombreMes,
                  style: TextStyle(color: ColoresTema.textPrimary),
                ),
                backgroundColor: ColoresTema.accent1.withOpacity(0.1),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _construirResumenAnual(Map<int, Map<int, _DatosMes>> datos) {
    final formatoNumero = NumberFormat('#,##0.0', 'es_CO');
    final years = datos.keys.toList()..sort();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColoresTema.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColoresTema.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(MdiIcons.chartBox, 
                color: ColoresTema.accent1,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text('Resumen Anual',
                style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          ...years.map((year) {
            double totalKilos = 0;
            int totalSiembras = 0;
            double rendimientoPromedio = 0;
            
            datos[year]!.forEach((_, datos) {
              totalKilos += datos.totalKilos;
              totalSiembras += datos.siembras;
              if (datos.siembras > 0) {
                rendimientoPromedio += datos.rendimiento / datos.siembras;
              }
            });
            
            if (totalSiembras > 0) {
              rendimientoPromedio = rendimientoPromedio / totalSiembras;
            }
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('$year',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('${formatoNumero.format(totalKilos)} Kg',
                    style: TextStyle(color: ColoresTema.accent2)),
                  Text('$totalSiembras siembras',
                    style: TextStyle(color: ColoresTema.textSecondary)),
                  Text('${formatoNumero.format(rendimientoPromedio)} Kg/Ha',
                    style: TextStyle(color: ColoresTema.success)),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Color _obtenerColorFondo(double valor) {
    if (valor <= 0) return Colors.grey.withOpacity(0.1);
    if (valor < 10000) return const Color(0xFFB71C1C).withOpacity(0.2);
    if (valor < 15000) return const Color(0xFFC78E00).withOpacity(0.2);
    return const Color(0xFF00813C).withOpacity(0.2);
  }

  Color _obtenerColorBorde(double valor) {
    if (valor <= 0) return Colors.grey;
    if (valor < 10000) return const Color(0xFFFF5252);
    if (valor < 15000) return const Color(0xFFFFD700);
    return const Color(0xFF00E676);
  }

  Map<int, Map<int, _DatosMes>> _procesarDatos(List<Siembra> siembras) {
    final datos = <int, Map<int, _DatosMes>>{};

    for (var siembra in siembras) {
      final year = siembra.fechaInicio.year;
      final mes = siembra.fechaInicio.month;
      
      datos.putIfAbsent(year, () => {});
      datos[year]!.putIfAbsent(mes, () => _DatosMes(
        lotes: [],
        tipoCultivo: siembra.tipo.nombre,
        year: year,
        totalKilos: 0.0,
      ));

      final datosMes = datos[year]![mes]!;
      datos[year]![mes] = _DatosMes(
        rendimiento: datosMes.rendimiento + siembra.kgPorHectareaCosechada,
        siembras: datosMes.siembras + 1,
        lotes: [...datosMes.lotes, siembra.codigoLote],
        tipoCultivo: siembra.tipo.nombre,
        year: year,
        totalKilos: datosMes.totalKilos + siembra.kgCosechados,
      );
    }

    return datos;
  }

  List<(int, double, int)> _obtenerMejoresMeses(
    Map<int, Map<int, _DatosMes>> datos
  ) {
    final meses = <(int, double, int)>[];
    
    datos.forEach((year, mesesData) {
      mesesData.forEach((mes, datos) {
        if (datos.siembras > 0) {
          meses.add((
            mes, 
            datos.rendimiento / datos.siembras,
            year
          ));
        }
      });
    });

    meses.sort((a, b) => b.$2.compareTo(a.$2));
    return meses.take(3).toList();
  }
}