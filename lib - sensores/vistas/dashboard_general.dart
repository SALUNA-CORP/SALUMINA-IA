//lib/vistas/dashboard_general.dart
import 'package:flutter/material.dart';
import '../core/temas/tema_personalizado.dart';

class DashboardGeneral extends StatelessWidget {
  const DashboardGeneral({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: ColoresTema.background,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.dashboard_rounded,
                size: 64,
                color: ColoresTema.accent1,
              ),
              const SizedBox(height: 16),
              Text(
                'Bienvenido al Sistema',
                style: TextStyle(
                  color: ColoresTema.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Seleccione un módulo del menú lateral para comenzar',
                style: TextStyle(
                  color: ColoresTema.textSecondary,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}