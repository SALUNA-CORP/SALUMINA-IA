// lib/plugins/sensores/constantes/sensores_configuracion.dart
class SensoresConfiguracion {
  static const String supabaseUrl = 'https://kphobvjuwxovrsfgghjn.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtwaG9idmp1d3hvdnJzZmdnaGpuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQwNTk4NzcsImV4cCI6MjA0OTYzNTg3N30.ggtmjesbnFrW8ihHFdiORbJvw4dmhA4IxYPEU4rOGfw';

  static Map<String, String> get headers => {
    'apikey': supabaseAnonKey,
    'Authorization': 'Bearer $supabaseAnonKey',
    'Content-Type': 'application/json',
  };
}