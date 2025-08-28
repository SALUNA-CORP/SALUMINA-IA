// lib/plugins/sensores/modelos/sensores_elemento_maquina.dart
import 'package:flutter/material.dart';

enum TipoElemento {
  digestor,
  valvula,
  motor,
  bomba,
  sensor,
  tuberia,
  compuerta,
  banda,
  desfibrador,
  caldera,
  prensa,
  rensa
}

class ElementoMaquina {
  final String id;
  final String nombre;
  final TipoElemento tipo;
  final double x;
  final double y;
  final Map<String, dynamic> propiedades;
  final Map<String, String>? registrosModbus;
  final List<ElementoMaquina>? subElementos;

  ElementoMaquina({
    required this.id,
    required this.nombre,
    required this.tipo,
    required this.x,
    required this.y,
    this.propiedades = const {},
    this.registrosModbus,
    this.subElementos,
  });
}

class SeccionMaquina {
  final String id;
  final String nombre;
  final List<ElementoMaquina> elementos;
  final Size dimension;

  SeccionMaquina({
    required this.id,
    required this.nombre,
    required this.elementos,
    this.dimension = const Size(1200, 800),
  });
}