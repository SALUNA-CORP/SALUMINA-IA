// lib/plugins/sensores/modelos/sensores_proceso_data.dart
import 'package:flutter/material.dart';
import 'sensores_elemento_proceso.dart';

// Rangos operativos típicos para cada tipo de sensor
class RangosOperativos {
  static const temperaturaDigestor = (min: 85.0, max: 95.0);
  static const presionDigestor = (min: 40.0, max: 60.0);
  static const temperaturaVapor = (min: 130.0, max: 150.0);
  static const presionVapor = (min: 45.0, max: 65.0);
  static const amperajeMotor = (min: 20.0, max: 40.0);
  static const velocidadMotor = (min: 1200.0, max: 1800.0);
  static const tonHora = (min: 15.0, max: 25.0);
  static const nivelTanque = (min: 60.0, max: 80.0);
}

final procesos = [
  ProcesoIndustrial(
    id: 'extraccion',
    nombre: 'Extracción',
    elementos: [
      ElementoProceso(
        id: 'digestor1',
        nombre: 'Digestor 1',
        tipo: TipoElemento.digestor,
        x: 50,
        y: 100,
        propiedades: {
          'temperatura': 90.5,
          'presion': 55.2,
          'nivel': 75.0,
          'estado': true,
          'alarma': false,
        },
        registrosModbus: {
          'temperatura': 'Register 1',
          'presion': 'Register 2',
          'nivel': 'Register 3',
          'estado': 'Register 4',
        },
      ),
      ElementoProceso(
        id: 'prensa1',
        nombre: 'Prensa 1',
        tipo: TipoElemento.prensa,
        x: 150,
        y: 100,
        propiedades: {
          'velocidad': 1500.0,
          'corriente': 32.5,
          'presion': 58.3,
          'estado': true,
          'produccion': 22.5,
        },
        registrosModbus: {
          'velocidad': 'Register 5',
          'corriente': 'Register 6',
          'presion': 'Register 7',
          'estado': 'Register 8',
          'produccion': 'Register 9',
        },
      ),
      ElementoProceso(
        id: 'rensa1',
        nombre: 'Rensa 1',
        tipo: TipoElemento.rensa,
        x: 250,
        y: 100,
        propiedades: {
          'velocidad': 1650.0,
          'corriente': 35.8,
          'estado': true,
        },
        registrosModbus: {
          'velocidad': 'Register 10',
          'corriente': 'Register 11',
          'estado': 'Register 12',
        },
      ),
    ],
  ),
  
  ProcesoIndustrial(
    id: 'desfibrado',
    nombre: 'Desfibrado',
    elementos: [
      ElementoProceso(
        id: 'desfibrador1',
        nombre: 'Desfibrador Principal',
        tipo: TipoElemento.desfibrador,
        x: 150,
        y: 100,
        propiedades: {
          'velocidad': 1750.0,
          'corriente': 38.5,
          'produccion': 20.8,
          'estado': true,
        },
        registrosModbus: {
          'velocidad': 'Register 20',
          'corriente': 'Register 21',
          'produccion': 'Register 22',
          'estado': 'Register 23',
        },
      ),
    ],
  ),

  ProcesoIndustrial(
    id: 'caldera',
    nombre: 'Caldera 1200',
    elementos: [
      ElementoProceso(
        id: 'caldera1200',
        nombre: 'Caldera Principal',
        tipo: TipoElemento.caldera,
        x: 150,
        y: 150,
        propiedades: {
          'temperatura': 145.5,
          'presion': 58.7,
          'nivel': 72.3,
          'estado': true,
        },
        registrosModbus: {
          'temperatura': 'Register 30',
          'presion': 'Register 31',
          'nivel': 'Register 32',
          'estado': 'Register 33',
        },
        subElementos: [
          ElementoProceso(
            id: 'bomba1',
            nombre: 'Bomba Alimentación 1',
            tipo: TipoElemento.bomba,
            x: 200,
            y: 200,
            propiedades: {
              'estado': true,
              'corriente': 28.5,
              'presion': 62.4,
            },
            registrosModbus: {
              'estado': 'Register 34',
              'corriente': 'Register 35',
              'presion': 'Register 36',
            },
          ),
        ],
      ),
    ],
  ),
];

// Función para generar valores aleatorios dentro de rangos operativos
double generarValorOperativo(double min, double max) {
  return min + (max - min) * (DateTime.now().millisecondsSinceEpoch % 1000) / 1000;
}