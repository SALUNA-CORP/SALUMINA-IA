// lib/core/constantes/configuracion.dart
class Configuracion {
  // URLs
  static const String supabaseUrl = 'https://expzmnyhsnbgpxjiahqx.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV4cHptbnloc25iZ3B4amlhaHF4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzEyMjg3NDEsImV4cCI6MjA0NjgwNDc0MX0.TBXMbNWOLSBm1f8dNcIJIeWAIDHp030Zt4y0Z34VEuM';
  static const String apiUrl = 'https://expzmnyhsnbgpxjiahqx.supabase.co/rest/v1';
  
  // API
  static const String apiVersion = 'v1';
  static const Duration timeoutApi = Duration(seconds: 30);
  static const Duration tiempoActualizacionCache = Duration(minutes: 15);
  
  // Headers
  static Map<String, String> get headersApi => {
    'apikey': supabaseAnonKey,
    'Authorization': 'Bearer $supabaseAnonKey',
    'Content-Type': 'application/json',
  };
}