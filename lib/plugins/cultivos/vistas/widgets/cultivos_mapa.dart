//lib/plugins/cultivos/vistas/widgets/cultivos_mapa.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../modelos/cultivos_models.dart';
import '../../../../core/temas/tema_personalizado.dart';

class MapaCultivos extends StatelessWidget {
  final MapController mapController;
  final List<Finca> fincas;
  final List<Lote> lotes;
  final String? loteSeleccionadoId;
  final String fincaActual;
  final void Function(String loteId)? onLoteSelected;

  const MapaCultivos({
    super.key,
    required this.mapController,
    required this.fincas,
    required this.lotes,
    required this.fincaActual,
    this.loteSeleccionadoId,
    this.onLoteSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: const LatLng(4.570868, -74.297333),
            initialZoom: 13,
            onTap: (_, point) {
              for (var lote in lotes) {
                if (_estaPuntoEnPoligono(point, lote.coordenadas)) {
                  onLoteSelected?.call(lote.id);
                  break;
                }
              }
            },
          ),
          children: [
            // Capa base OSM
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.app',
              tileProvider: CancellableNetworkTileProvider(),
            ),

            // Capa de fincas
            PolygonLayer(
              polygons: fincas.map((finca) => 
                Polygon(
                  points: finca.coordenadas,
                  color: finca.id == fincaActual 
                    ? ColoresTema.accent1.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.05),
                  borderColor: finca.id == fincaActual 
                    ? ColoresTema.accent1 
                    : Colors.grey,
                  borderStrokeWidth: finca.id == fincaActual ? 2 : 1,
                  isFilled: true,
                ),
              ).toList(),
            ),

            // Capa de lotes
            PolygonLayer(
              polygons: lotes.map((lote) {
                final isSelected = lote.id == loteSeleccionadoId;
                final color = lote.siembraActual?.color ?? Colors.grey;
                
                return Polygon(
                  points: lote.coordenadas,
                  color: color.withOpacity(isSelected ? 0.5 : 0.2),
                  borderColor: isSelected ? Colors.white : color,
                  borderStrokeWidth: isSelected ? 3 : 1,
                  isFilled: true,
                  label: lote.nombre,
                );
              }).toList(),
            ),

            // Etiquetas de lotes
            MarkerLayer(
              markers: lotes.map((lote) {
                final center = _calcularCentroide(lote.coordenadas);
                return Marker(
                  point: center,
                  width: 100,
                  height: 40,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(4),
                      border: lote.id == loteSeleccionadoId ? 
                        Border.all(color: Colors.white, width: 2) : null,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          lote.nombre,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (lote.siembraActual != null)
                          Text(
                            lote.siembraActual!.tipo.nombre,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),

        // Controles de zoom
        Positioned(
          right: 16,
          bottom: 16,
          child: Card(
            child: Column(
              children: [
                IconButton(
                  icon: Icon(MdiIcons.plusCircleOutline),
                  onPressed: () => mapController.move(
                    mapController.camera.center,
                    mapController.camera.zoom + 1,
                  ),
                  tooltip: 'Acercar',
                ),
                Container(
                  height: 1,
                  width: 20,
                  color: ColoresTema.border,
                ),
                IconButton(
                  icon: Icon(MdiIcons.minusCircleOutline),
                  onPressed: () => mapController.move(
                    mapController.camera.center,
                    mapController.camera.zoom - 1,
                  ),
                  tooltip: 'Alejar',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  LatLng _calcularCentroide(List<LatLng> points) {
    if (points.isEmpty) return const LatLng(0, 0);
    
    double latSum = 0;
    double lngSum = 0;
    
    for (var point in points) {
      latSum += point.latitude;
      lngSum += point.longitude;
    }
    
    return LatLng(
      latSum / points.length,
      lngSum / points.length,
    );
  }

  bool _estaPuntoEnPoligono(LatLng point, List<LatLng> polygon) {
    bool inside = false;
    int j = polygon.length - 1;

    for (int i = 0; i < polygon.length; i++) {
      if ((polygon[i].longitude < point.longitude && polygon[j].longitude >= point.longitude ||
          polygon[j].longitude < point.longitude && polygon[i].longitude >= point.longitude) &&
          (polygon[i].latitude <= point.latitude || polygon[j].latitude <= point.latitude)) {
        if (polygon[i].latitude + (point.longitude - polygon[i].longitude) /
            (polygon[j].longitude - polygon[i].longitude) *
            (polygon[j].latitude - polygon[i].latitude) < point.latitude) {
          inside = !inside;
        }
      }
      j = i;
    }

    return inside;
  }
}