import 'package:supabase_flutter/supabase_flutter.dart';
import '../modelos/equipo.dart';
import '../modelos/partido.dart';
import '../modelos/evento_partido.dart';

class ServicioFutbol {
  final SupabaseClient _supabase;
  
  ServicioFutbol(this._supabase);

  // Stream para tablas de posiciones en tiempo real
  Stream<List<Equipo>> obtenerTablaPosiciones() {
    return _supabase
      .from('equipos')
      .stream(primaryKey: ['id'])
      .order('puntos', ascending: false)
      .order('diferencia_goles', ascending: false)
      .map((data) => data.map((json) => Equipo.fromJson(json)).toList());
  }

  // Gestión de Equipos
  Future<List<Equipo>> obtenerEquipos() async {
    final response = await _supabase
      .from('equipos')
      .select()
      .order('nombre');
    
    return response.map((json) => Equipo.fromJson(json)).toList();
  }

  Future<Equipo> crearEquipo(String nombre, String? escudo) async {
    final response = await _supabase
      .from('equipos')
      .insert({
        'nombre': nombre,
        'escudo': escudo,
      })
      .select()
      .single();
    
    return Equipo.fromJson(response);
  }

  // Gestión de Partidos
  Future<List<Partido>> obtenerPartidos() async {
    final response = await _supabase
      .from('partidos')
      .select('''
        *,
        equipos_local: equipo_local(*),
        equipos_visitante: equipo_visitante(*)
      ''')
      .order('fecha');
    
    return response.map((json) => Partido.fromJson(json)).toList();
  }

  Stream<List<Partido>> obtenerPartidosStream() {
    return _supabase
      .from('partidos')
      .stream(primaryKey: ['id'])
      .map((data) => data.map((json) => Partido.fromJson(json)).toList());
  }

  Future<Partido> crearPartido({
    required String equipoLocalId,
    required String equipoVisitanteId,
    required DateTime fecha,
  }) async {
    final response = await _supabase
      .from('partidos')
      .insert({
        'equipo_local': equipoLocalId,
        'equipo_visitante': equipoVisitanteId,
        'fecha': fecha.toIso8601String(),
      })
      .select('''
        *,
        equipos_local: equipo_local(*),
        equipos_visitante: equipo_visitante(*)
      ''')
      .single();
    
    return Partido.fromJson(response);
  }

  Future<void> actualizarPartido({
    required String partidoId,
    required int golesLocal,
    required int golesVisitante,
    required EstadoPartido estado,
  }) async {
    await _supabase
      .from('partidos')
      .update({
        'goles_local': golesLocal,
        'goles_visitante': golesVisitante,
        'estado': estado.toString().split('.').last,
      })
      .eq('id', partidoId);
  }

  // Gestión de Eventos
  Future<List<EventoPartido>> obtenerEventosPartido(String partidoId) async {
    final response = await _supabase
      .from('eventos_partido')
      .select('''
        *,
        equipos: equipo_id(*)
      ''')
      .eq('partido_id', partidoId)
      .order('minuto');
    
    return response.map((json) => EventoPartido.fromJson(json)).toList();
  }

  Stream<List<EventoPartido>> obtenerEventosPartidoStream(String partidoId) {
    return _supabase
      .from('eventos_partido')
      .stream(primaryKey: ['id'])
      .eq('partido_id', partidoId)
      .map((data) => data.map((json) => EventoPartido.fromJson(json)).toList());
  }

  Future<EventoPartido> registrarEvento({
    required String partidoId,
    required String equipoId,
    required String jugador,
    required TipoEvento tipoEvento,
    required int minuto,
  }) async {
    final response = await _supabase
      .from('eventos_partido')
      .insert({
        'partido_id': partidoId,
        'equipo_id': equipoId,
        'jugador': jugador,
        'tipo_evento': tipoEvento.toString().split('.').last,
        'minuto': minuto,
      })
      .select('*, equipos:equipo_id(*)')
      .single();
    
    return EventoPartido.fromJson(response);
  }
}