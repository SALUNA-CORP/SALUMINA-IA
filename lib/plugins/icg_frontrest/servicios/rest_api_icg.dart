// lib/plugins/icg_frontrest/servicios/api_icg.dart
import 'package:dio/dio.dart';
import '../modelos/rest_venta_costo.dart';
import '../modelos/rest_costo_fijo.dart';
import '../../../core/constantes/configuracion.dart';

class ApiICG {
  final Dio _dio;
  
  ApiICG() 
    : _dio = Dio(
        BaseOptions(
          baseUrl: 'https://icgreportes.mrbumaudiobar.com',
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
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

  Future<List<VentaCosto>> obtenerVentasCostos({
    required DateTime fechaInicio,
    required DateTime fechaFin,
  }) async {
    try {
      final response = await _dio.get(
        '/ventas-costos_variables',
        queryParameters: {
          'startDate': fechaInicio.toIso8601String().split('T')[0],
          'endDate': fechaFin.toIso8601String().split('T')[0],
        },
      );

      if (response.statusCode == 200) {
        return (response.data as List)
          .map((json) => VentaCosto.fromJson(json))
          .toList();
      }
      
      throw Exception('Error obteniendo datos: ${response.statusCode}');
    } catch (e) {
      print('Error en obtenerVentasCostos: $e');
      rethrow;
    }
  }

  Future<List<CostoFijo>> obtenerCostosFijos({
    required DateTime fechaInicio,
    required DateTime fechaFin,
  }) async {
    try {
      final response = await _dio.get(
        '/costos-fijos',
        queryParameters: {
          'startDate': fechaInicio.toIso8601String().split('T')[0],
          'endDate': fechaFin.toIso8601String().split('T')[0],
        },
      );

      if (response.statusCode == 200) {
        return (response.data as List)
          .map((json) => CostoFijo.fromJson(json))
          .toList();
      }
      
      throw Exception('Error obteniendo datos: ${response.statusCode}');
    } catch (e) {
      print('Error en obtenerCostosFijos: $e');
      rethrow;
    }
  }
}