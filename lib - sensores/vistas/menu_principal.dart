import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../plugins/sensores/vistas/widgets/sensores_menu.dart';
import '../core/temas/tema_personalizado.dart';
import 'dashboard_general.dart';

class MenuPrincipal extends StatefulWidget {
  const MenuPrincipal({super.key});

  @override
  State<MenuPrincipal> createState() => _MenuPrincipalState();
}

class _MenuPrincipalState extends State<MenuPrincipal> {
  String _rutaActual = '/dashboard';
  double _anchoMenu = 280;
  bool _menuContraido = false;

  void _navegarA(String ruta) {
    setState(() => _rutaActual = ruta);
    Navigator.pushNamed(context, ruta);
  }

  void _toggleMenu() {
    setState(() {
      _menuContraido = !_menuContraido;
      _anchoMenu = _menuContraido ? 70 : 280;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _anchoMenu,
            color: ColoresTema.cardBackground,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromRGBO(
                          ColoresTema.accent1.red,
                          ColoresTema.accent1.green,
                          ColoresTema.accent1.blue,
                          0.2
                        ),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(_menuContraido ? MdiIcons.menuRight : MdiIcons.menuLeft),
                        onPressed: _toggleMenu,
                        color: ColoresTema.accent1,
                      ),
                      if (!_menuContraido) ...[
                        const SizedBox(width: 8),
                        Icon(MdiIcons.viewDashboard,
                          color: ColoresTema.accent1,
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'ERP Modular',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView(
                    children: [
                      if (_menuContraido)
                        ..._construirMenuContraido()
                      else
                        ..._construirMenuExpandido(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: ColoresTema.background,
              ),
              child: Navigator(
                onGenerateRoute: (settings) {
                  return MaterialPageRoute(
                    builder: (_) => const DashboardGeneral(),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _construirMenuContraido() {
    return [
      ListTile(
        leading: Icon(MdiIcons.viewDashboardOutline),
        selected: _rutaActual == '/dashboard',
        selectedColor: ColoresTema.accent1,
        onTap: () => _navegarA('/dashboard'),
      ),
      ListTile(
        leading: Icon(MdiIcons.gauge),
        selected: _rutaActual.startsWith('/sensores/'),
        selectedColor: ColoresTema.accent1,
        onTap: () => _navegarA('/sensores/dashboard'),
      ),
    ];
  }

  List<Widget> _construirMenuExpandido() {
    return [
      ListTile(
        leading: Icon(MdiIcons.viewDashboardOutline),
        title: const Text('Dashboard'),
        selected: _rutaActual == '/dashboard',
        selectedColor: ColoresTema.accent1,
        onTap: () => _navegarA('/dashboard'),
      ),
      SensoresMenu(
        rutaActual: _rutaActual,
        onRutaSeleccionada: _navegarA
      ),
    ];
  }
}