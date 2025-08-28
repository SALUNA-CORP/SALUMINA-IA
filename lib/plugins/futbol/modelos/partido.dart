import 'equipo.dart';

enum EstadoPartido {
  pendiente,
  en_curso,
  finalizado
}

class Partido {
  final String id;
  final String equipoLocalId;
  final String equipoVisitanteId;
  final int golesLocal;
  final int golesVisitante;
  final EstadoPartido estado;
  final DateTime fecha;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Equipo? equipoLocal;
  final Equipo? equipoVisitante;

  Partido({
    required this.id,
    required this.equipoLocalId,
    required this.equipoVisitanteId,
    required this.golesLocal,
    required this.golesVisitante,
    required this.estado,
    required this.fecha,
    required this.createdAt,
    required this.updatedAt,
    this.equipoLocal,
    this.equipoVisitante,
  });

  factory Partido.fromJson(Map<String, dynamic> json) {
    return Partido(
      id: json['id'],
      equipoLocalId: json['equipo_local'],
      equipoVisitanteId: json['equipo_visitante'],
      golesLocal: json['goles_local'] ?? 0,
      golesVisitante: json['goles_visitante'] ?? 0,
      estado: EstadoPartido.values.firstWhere(
        (e) => e.toString().split('.').last == json['estado'],
        orElse: () => EstadoPartido.pendiente,
      ),
      fecha: DateTime.parse(json['fecha']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      equipoLocal: json['equipos_local'] != null 
        ? Equipo.fromJson(json['equipos_local']) 
        : null,
      equipoVisitante: json['equipos_visitante'] != null 
        ? Equipo.fromJson(json['equipos_visitante']) 
        : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'equipo_local': equipoLocalId,
      'equipo_visitante': equipoVisitanteId,
      'goles_local': golesLocal,
      'goles_visitante': golesVisitante,
      'estado': estado.toString().split('.').last,
      'fecha': fecha.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get resultado => '$golesLocal - $golesVisitante';
  
  bool get enCurso => estado == EstadoPartido.en_curso;
  bool get finalizado => estado == EstadoPartido.finalizado;
  bool get pendiente => estado == EstadoPartido.pendiente;
  
  String? get ganador {
    if (!finalizado) return null;
    if (golesLocal > golesVisitante) return equipoLocal?.nombre;
    if (golesVisitante > golesLocal) return equipoVisitante?.nombre;
    return 'Empate';
  }
}