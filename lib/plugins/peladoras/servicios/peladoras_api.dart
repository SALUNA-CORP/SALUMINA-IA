import 'package:dio/dio.dart';
import '../modelos/peladoras_toma.dart';
import '../modelos/peladoras_estadisticas.dart';
import '../utils/peladoras_calculadora_estadisticas.dart';
import '../../../core/constantes/configuracion.dart';

class ApiPeladoras {
  final Dio _dio;
  
  ApiPeladoras() 
    : _dio = Dio(
        BaseOptions(
          baseUrl: Configuracion.apiUrl,
          headers: Configuracion.headersApi,
          validateStatus: (status) => status! < 500,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      ) {
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  Future<List<Toma>> obtenerTomas(DateTime inicio, DateTime fin) async {
    try {
      final fechaInicio = inicio.toIso8601String().split('T')[0];
      final fechaFin = fin.toIso8601String().split('T')[0];
      
      final response = await _dio.get(
        '/tomas',
        queryParameters: {
          'select': 'peladora_id,fecha,hora_inicio,kilogramos,costo_toma,peladoras(nombre,apellido,activo)',
          'and': '(fecha.gte.$fechaInicio,fecha.lte.$fechaFin)',
        },
      );

      if (response.statusCode != 200) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Error ${response.statusCode}: ${response.data['message']}',
        );
      }

      final tomas = (response.data as List).map((json) => Toma.fromJson(json)).toList();
      
      // Ordenar por fecha y hora
      tomas.sort((a, b) => a.horaInicio.compareTo(b.horaInicio));
      
      return tomas;
    } catch (e) {
      print('Error en obtenerTomas: $e');
      if (e is DioException) {
        print('Status code: ${e.response?.statusCode}');
        print('Response data: ${e.response?.data}');
        // Manejo de error de autenticación
        if (e.response?.statusCode == 401) {
          // Implementar refresco de token si es necesario
        }
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> obtenerEstadisticasHistoricas(int peladoraId) async {
    try {
      final response = await _dio.get(
        '/tomas',
        queryParameters: {
          'select': 'fecha,kilogramos,costo_toma',
          'peladora_id': 'eq.$peladoraId',
          'order': 'fecha.asc',
        },
      );

      if (response.statusCode == 200) {
        return {
          'datos': response.data,
          'peladora_id': peladoraId,
        };
      }
      return {};
    } catch (e) {
      print('Error obteniendo estadísticas históricas: $e');
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> obtenerAlertas() async {
    try {
      final now = DateTime.now();
      final twoHoursAgo = now.subtract(const Duration(hours: 2));
      
      final response = await _dio.get(
        '/tomas',
        queryParameters: {
          'select': 'peladora_id,hora_inicio,peladoras(nombre,apellido)',
          'hora_inicio.gte': twoHoursAgo.toIso8601String(),
          'order': 'hora_inicio.desc',
        },
      );

      if (response.statusCode == 200) {
        return (response.data as List).cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Error obteniendo alertas: $e');
      return [];
    }
  }

  Future<bool> registrarObservacion({
    required int peladoraId,
    required String tipo,
    required String descripcion,
  }) async {
    try {
      final response = await _dio.post(
        '/observaciones',
        data: {
          'peladora_id': peladoraId,
          'tipo': tipo,
          'descripcion': descripcion,
          'fecha': DateTime.now().toIso8601String(),
        },
      );

      return response.statusCode == 201;
    } catch (e) {
      print('Error registrando observación: $e');
      return false;
    }
  }
}