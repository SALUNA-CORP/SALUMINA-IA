// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/servicios/gestor_plugins.dart';
import 'core/temas/gestor_temas.dart';
import 'core/constantes/configuracion.dart';
import 'vistas/menu_principal.dart';
import 'vistas/dashboard_general.dart';

final getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await inicializarServicios();
  runApp(const ERPApp());
}

Future<void> inicializarServicios() async {
  try {
    await initializeDateFormatting('es_CO', null);
    
    await Supabase.initialize(
      url: Configuracion.supabaseUrl,
      anonKey: Configuracion.supabaseAnonKey,
      debug: true,
    );
    
    getIt.registerSingleton(GestorTemas.instancia);
    getIt.registerSingleton<GestorPlugins>(GestorPlugins());

    await getIt<GestorPlugins>().cargarPlugin('peladoras');
    await getIt<GestorPlugins>().cargarPlugin('icg_frontrest');
    await getIt<GestorPlugins>().cargarPlugin('futbol');
    await getIt<GestorPlugins>().cargarPlugin('cultivos');
    await getIt<GestorPlugins>().cargarPlugin('sensores');
    
  } catch (e, stackTrace) {
    print('Error inicializando servicios: $e');
    print('Stack trace: $stackTrace');
    rethrow;
  }
}

class ERPApp extends StatelessWidget {
  const ERPApp({super.key});

  @override
  Widget build(BuildContext context) {
    final pluginRoutes = getIt<GestorPlugins>().rutas;
    
    return MaterialApp(
      title: 'ERP Sistema',
      theme: getIt<GestorTemas>().temaActual,
      debugShowCheckedModeBanner: false,
      initialRoute: '/', // Definimos la ruta inicial
      routes: {
        '/': (context) => const MenuPrincipal(), // Ruta raíz
        '/dashboard': (context) => const DashboardGeneral(),
        ...pluginRoutes,
      },
      onGenerateRoute: (settings) {
        debugPrint('Intentando generar ruta: ${settings.name}');
        return MaterialPageRoute(
          builder: (context) => const DashboardGeneral(),
        );
      },
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'CO'),
      ],
    );
  }
}