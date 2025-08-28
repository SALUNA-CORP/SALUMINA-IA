// lib/plugins/peladoras/vistas/widgets/filtros.dart
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../modelos/peladoras_toma.dart';
import '../../../../core/temas/tema_personalizado.dart';

class FiltroPeladoras extends StatelessWidget {
  final String? peladoraSeleccionada;
  final List<Toma> tomas;
  final Function(String?) onPeladoraChanged;
  final Function(DateTimeRange) onFechasChanged;
  final DateTime fechaInicio;
  final DateTime fechaFin;

  const FiltroPeladoras({
    Key? key,
    required this.peladoraSeleccionada,
    required this.tomas,
    required this.onPeladoraChanged,
    required this.onFechasChanged,
    required this.fechaInicio,
    required this.fechaFin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: peladoraSeleccionada,
                    decoration: InputDecoration(
                      labelText: 'Peladora',
                      prefixIcon: Icon(MdiIcons.accountOutline, color: ColoresTema.accent1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: ColoresTema.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: ColoresTema.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: ColoresTema.accent1),
                      ),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Todas las peladoras'),
                      ),
                      ...tomas.map((t) => t.peladoraId.toString()).toSet().map((id) {
                        final toma = tomas.firstWhere((t) => t.peladoraId.toString() == id);
                        return DropdownMenuItem(
                          value: id,
                          child: Text(toma.peladora.nombreCompleto),
                        );
                      }),
                    ],
                    onChanged: onPeladoraChanged,
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    final fechas = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      initialDateRange: DateTimeRange(
                        start: fechaInicio,
                        end: fechaFin,
                      ),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.dark(
                              primary: ColoresTema.accent1,
                              onPrimary: ColoresTema.textPrimary,
                              surface: ColoresTema.cardBackground,
                              onSurface: ColoresTema.textPrimary,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (fechas != null) {
                      onFechasChanged(fechas);
                    }
                  },
                  icon: Icon(MdiIcons.calendarMonth, color: ColoresTema.textPrimary),
                  label: const Text('Seleccionar fechas'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColoresTema.accent1,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () => onFechasChanged(DateTimeRange(
                    start: fechaInicio,
                    end: fechaFin,
                  )),
                  icon: Icon(MdiIcons.refresh, color: ColoresTema.accent2),
                  tooltip: 'Recargar datos',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}