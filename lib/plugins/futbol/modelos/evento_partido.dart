import 'package:flutter/material.dart';
import 'equipo.dart';

enum TipoEvento {
  gol,
  tarjeta_amarilla,
  tarjeta_roja
}

class EventoPartido {
  final String id;
  final String partidoId;
  final String equipoId;
  final String jugador;
  final TipoEvento tipoEvento;
  final int minuto;
  final DateTime createdAt;
  final Equipo? equipo;

  EventoPartido({
    required this.id,
    required this.partidoId,
    required this.equipoId,
    required this.jugador,
    required this.tipoEvento,
    required this.minuto,
    required this.createdAt,
    this.equipo,
  });

  factory EventoPartido.fromJson(Map<String, dynamic> json) {
    return EventoPartido(
      id: json['id'],
      partidoId: json['partido_id'],
      equipoId: json['equipo_id'],
      jugador: json['jugador'],
      tipoEvento: TipoEvento.values.firstWhere(
        (e) => e.toString().split('.').last == json['tipo_evento'],
      ),
      minuto: json['minuto'],
      createdAt: DateTime.parse(json['created_at']),
      equipo: json['equipos'] != null 
        ? Equipo.fromJson(json['equipos']) 
        : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'partido_id': partidoId,
      'equipo_id': equipoId,
      'jugador': jugador,
      'tipo_evento': tipoEvento.toString().split('.').last,
      'minuto': minuto,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get descripcion {
    switch (tipoEvento) {
      case TipoEvento.gol:
        return '⚽ Gol de $jugador';
      case TipoEvento.tarjeta_amarilla:
        return '🟨 Tarjeta amarilla para $jugador';
      case TipoEvento.tarjeta_roja:
        return '🟥 Tarjeta roja para $jugador';
    }
  }
}