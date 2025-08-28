import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../servicios/servicio_futbol.dart';
import '../../../../core/temas/tema_personalizado.dart';

class RegistroEquipo extends StatefulWidget {
  const RegistroEquipo({super.key});

  @override
  State<RegistroEquipo> createState() => _RegistroEquipoState();
}

class _RegistroEquipoState extends State<RegistroEquipo> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _urlEscudoController = TextEditingController();

  bool _guardando = false;

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    try {
      final servicio = GetIt.I<ServicioFutbol>();
      await servicio.crearEquipo(
        _nombreController.text,
        _urlEscudoController.text.isEmpty ? null : _urlEscudoController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Equipo registrado correctamente'),
            backgroundColor: ColoresTema.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al registrar equipo: $e'),
            backgroundColor: ColoresTema.error,
          ),
        );
      }
    } finally {
      setState(() => _guardando = false);
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _urlEscudoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Registrar Equipo',
                style: TextStyle(
                  color: ColoresTema.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Equipo',
                  hintText: 'Ej: Real Madrid',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el nombre del equipo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _urlEscudoController,
                decoration: const InputDecoration(
                  labelText: 'URL del Escudo (opcional)',
                  hintText: 'https://...',
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _guardando ? null : () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _guardando ? null : _guardar,
                    child: _guardando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(),
                        )
                      : const Text('Guardar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}