//lib/plugins/futbol/modelos/equipo.dart
class Equipo {
  final String id;
  final String nombre;
  final String? escudo;
  final int puntos;
  final int partidosJugados;
  final int partidosGanados;
  final int partidosEmpatados;
  final int partidosPerdidos;
  final int golesFavor;
  final int golesContra;
  final int diferenciaGoles;
  final DateTime createdAt;
  final DateTime updatedAt;

  Equipo({
    required this.id,
    required this.nombre,
    this.escudo,
    required this.puntos,
    required this.partidosJugados,
    required this.partidosGanados,
    required this.partidosEmpatados,
    required this.partidosPerdidos,
    required this.golesFavor,
    required this.golesContra,
    required this.diferenciaGoles,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Equipo.fromJson(Map<String, dynamic> json) {
    return Equipo(
      id: json['id'],
      nombre: json['nombre'],
      escudo: json['escudo'],
      puntos: json['puntos'] ?? 0,
      partidosJugados: json['partidos_jugados'] ?? 0,
      partidosGanados: json['partidos_ganados'] ?? 0,
      partidosEmpatados: json['partidos_empatados'] ?? 0,
      partidosPerdidos: json['partidos_perdidos'] ?? 0,
      golesFavor: json['goles_favor'] ?? 0,
      golesContra: json['goles_contra'] ?? 0,
      diferenciaGoles: json['diferencia_goles'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'escudo': escudo,
      'puntos': puntos,
      'partidos_jugados': partidosJugados,
      'partidos_ganados': partidosGanados,
      'partidos_empatados': partidosEmpatados,
      'partidos_perdidos': partidosPerdidos,
      'goles_favor': golesFavor,
      'goles_contra': golesContra,
      'diferencia_goles': diferenciaGoles,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}