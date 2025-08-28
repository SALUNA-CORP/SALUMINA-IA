//lib/plugins/cultivos/servicios/cultivos_service.dart
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../modelos/cultivos_models.dart';

class CultivosService {
  final SupabaseClient _supabase;
  final _filtrosController = BehaviorSubject<FiltrosCultivos>.seeded(FiltrosCultivos());
  
  CultivosService(this._supabase);

  Stream<FiltrosCultivos> get filtrosStream => _filtrosController.stream;
  FiltrosCultivos get filtrosActuales => _filtrosController.value;

  void actualizarFiltros(FiltrosCultivos filtros) {
    _filtrosController.add(filtros);
  }

  Stream<List<Finca>> streamFincas() {
    return _supabase
      .from('cultivos_fincas')
      .select()
      .then((data) {
        return (data as List).map((json) => Finca.fromJson(json)).toList();
      })
      .asStream();
  }

  Future<Finca?> obtenerFinca(String fincaId) async {
    try {
      final response = await _supabase
        .from('cultivos_fincas')
        .select()
        .eq('id', fincaId)
        .single();
      
      return response != null ? Finca.fromJson(response) : null;
    } catch (e) {
      print('Error obteniendo finca: $e');
      return null;
    }
  }

  Stream<Lote?> streamLote(String loteId) {
    return _supabase
      .from('cultivos_lotes')
      .select('''
        *,
        cultivos_siembras (
          *,
          cultivos_estados ( * ),
          cultivos_tipos ( * )
        )
      ''')
      .eq('id', loteId)
      .single()
      .then((data) => data != null ? Lote.fromJson(data) : null)
      .asStream();
  }

  Stream<List<Lote>> streamLotes(String fincaId) {
    return _supabase
      .from('cultivos_lotes')
      .select('''
        *,
        cultivos_siembras (
          *,
          cultivos_estados ( * ),
          cultivos_tipos ( * )
        )
      ''')
      .eq('finca_id', fincaId)
      .then((data) {
        return (data as List).map((json) => Lote.fromJson(json)).toList();
      })
      .asStream();
  }

  Stream<List<Siembra>> streamSiembras([String? fincaId]) {
    var query = _supabase
      .from('cultivos_siembras')
      .select('''
        *,
        cultivos_estados(*),
        cultivos_tipos(*),
        cultivos_lotes!inner(
          *,
          cultivos_fincas(*)
        )
      ''');

    if (fincaId != null) {
      query = query.eq('cultivos_lotes.finca_id', fincaId);
    }

    return query
      .then((data) {
        return (data as List).map((json) => Siembra.fromJson(json)).toList();
      })
      .asStream();
  }

  Stream<List<Siembra>> streamSiembrasFiltradas() {
    return Rx.combineLatest2(
      streamSiembras(),
      filtrosStream,
      (List<Siembra> siembras, FiltrosCultivos filtros) {
        var siembrasFiltradas = siembras;

        // Filtro por fechas
        if (filtros.fechas != null) {
          siembrasFiltradas = siembrasFiltradas.where((siembra) => 
            siembra.fechaInicio.isAfter(filtros.fechas!.start.subtract(const Duration(days: 1))) &&
            siembra.fechaInicio.isBefore(filtros.fechas!.end.add(const Duration(days: 1)))
          ).toList();
        }

        // Filtro por tipo de cultivo
        if (filtros.tipoId != null && filtros.tipoId!.isNotEmpty) {
          siembrasFiltradas = siembrasFiltradas.where((siembra) => 
            siembra.tipo.id == filtros.tipoId
          ).toList();
        }

        // Filtro por finca
        if (filtros.fincaId != null && filtros.fincaId!.isNotEmpty) {
          siembrasFiltradas = siembrasFiltradas.where((siembra) => 
            siembra.loteId == filtros.fincaId
          ).toList();
        }

        // Filtro por estado
        if (filtros.estadoId != null && filtros.estadoId!.isNotEmpty) {
          siembrasFiltradas = siembrasFiltradas.where((siembra) => 
            siembra.estado.id == filtros.estadoId
          ).toList();
        }

        return siembrasFiltradas;
      }
    );
  }
  
  Stream<Map<String, List<dynamic>>> streamEstadisticasAgrupadas() {
    return _supabase
      .from('cultivos_siembras')
      .select('''
        *,
        cultivos_lotes!inner(
          *,
          cultivos_fincas(*)
        ),
        cultivos_estados(*),
        cultivos_tipos(*)
      ''')
      .then((data) {
        final porFinca = <String, List<dynamic>>{};
        final porCultivo = <String, List<dynamic>>{};

        for (var siembra in data) {
          final fincaId = siembra['cultivos_lotes']['cultivos_fincas']['id'];
          final tipoId = siembra['cultivos_tipos']['id'];

          porFinca.putIfAbsent(fincaId, () => []).add(siembra);
          porCultivo.putIfAbsent(tipoId, () => []).add(siembra);
        }

        return {
          'por_finca': porFinca.values.toList(),
          'por_cultivo': porCultivo.values.toList(),
        };
      }).asStream();
  }

  Future<List<TipoCultivo>> obtenerTiposCultivo() async {
    try {
      final response = await _supabase
        .from('cultivos_tipos')
        .select();
      
      return (response as List).map((json) => TipoCultivo.fromJson(json)).toList();
    } catch (e) {
      print('Error obteniendo tipos de cultivo: $e');
      return [];
    }
  }

  Future<List<EstadoCultivo>> obtenerEstados() async {
    try {
      final response = await _supabase
        .from('cultivos_estados')
        .select();
      
      return (response as List).map((json) => EstadoCultivo.fromJson(json)).toList();
    } catch (e) {
      print('Error obteniendo estados: $e');
      return [];
    }
  }

  void dispose() {
    _filtrosController.close();
  }
}

class FiltrosCultivos {
  final DateTimeRange? fechas;
  final String? tipoId;
  final String? fincaId;
  final String? estadoId;

  FiltrosCultivos({
    this.fechas,
    this.tipoId,
    this.fincaId,
    this.estadoId,
  });

  FiltrosCultivos copyWith({
    DateTimeRange? fechas,
    String? tipoId,
    String? fincaId,
    String? estadoId,
    bool clearFechas = false,
    bool clearTipoId = false,
    bool clearFincaId = false,
    bool clearEstadoId = false,
  }) {
    return FiltrosCultivos(
      fechas: clearFechas ? null : fechas ?? this.fechas,
      tipoId: clearTipoId ? null : tipoId ?? this.tipoId,
      fincaId: clearFincaId ? null : fincaId ?? this.fincaId,
      estadoId: clearEstadoId ? null : estadoId ?? this.estadoId,
    );
  }
}