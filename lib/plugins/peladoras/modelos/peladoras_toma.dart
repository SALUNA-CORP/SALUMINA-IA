// lib/plugins/peladoras/modelos/toma.dart
class Toma {
  final int peladoraId;
  final DateTime fecha;
  final DateTime horaInicio;
  final double kilogramos;
  final double costoToma;
  final Peladora peladora;

  Toma({
    required this.peladoraId,
    required this.fecha,
    required this.horaInicio,
    required this.kilogramos,
    required this.costoToma,
    required this.peladora,
  });

  factory Toma.fromJson(Map<String, dynamic> json) {
    return Toma(
      peladoraId: json['peladora_id'],
      fecha: DateTime.parse(json['fecha']),
      horaInicio: DateTime.parse(json['hora_inicio']),
      kilogramos: json['kilogramos'].toDouble(),
      costoToma: json['costo_toma'].toDouble(),
      peladora: Peladora.fromJson(json['peladoras']),
    );
  }
}

class Peladora {
  final String nombre;
  final String apellido;
  final bool activo;

  Peladora({
    required this.nombre, 
    required this.apellido,
    required this.activo,
  });

  factory Peladora.fromJson(Map<String, dynamic> json) {
    return Peladora(
      nombre: json['nombre'],
      apellido: json['apellido'],
      activo: json['activo'] ?? false,
    );
  }

  String get nombreCompleto => '$nombre $apellido';
}