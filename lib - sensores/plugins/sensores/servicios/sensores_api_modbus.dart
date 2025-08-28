// lib/plugins/sensores/servicios/sensores_api_modbus.dart
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../modelos/sensores_modbus_data.dart';
import '../constantes/sensores_configuracion.dart';

class SensoresApiModbus {
  final Dio _dio;
  final SupabaseClient _supabase;
  
  SensoresApiModbus() 
    : _dio = Dio(
        BaseOptions(
          baseUrl: '${SensoresConfiguracion.supabaseUrl}/rest/v1',
          headers: SensoresConfiguracion.headers,
          validateStatus: (status) => status! < 500,
        ),
      ),
      _supabase = Supabase.instance.client {
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  Stream<List<ModbusData>> streamDatosModbus() {
    return _supabase
      .from('datostest')
      .stream(primaryKey: ['id'])
      .order('created_at', ascending: false)
      .map((data) {
        try {
          return data.map((json) => ModbusData.fromJson(json)).toList();
        } catch (e) {
          print('Error parseando datos Modbus: $e');
          return <ModbusData>[];
        }
      });
  }

  Future<List<ModbusData>> obtenerUltimosRegistros() async {
    try {
      final response = await _dio.get(
        '/datostest',
        queryParameters: {
          'select': '*',
          'order': 'created_at.desc',
          'limit': 1,
        },
      );

      if (response.statusCode == 200) {
        return (response.data as List)
          .map((json) => ModbusData.fromJson(json))
          .toList();
      }
      
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Error al obtener datos: ${response.statusCode}',
      );
    } catch (e) {
      print('Error en obtenerUltimosRegistros: $e');
      rethrow;
    }
  }

  void dispose() {
    _dio.close();
  }
}