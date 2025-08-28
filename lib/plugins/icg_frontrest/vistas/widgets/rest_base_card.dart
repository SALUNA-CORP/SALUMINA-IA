// lib/plugins/icg_frontrest/widgets/rest_base_card.dart
import 'package:flutter/material.dart';
import '../../../../core/temas/tema_personalizado.dart';

class BaseKPICard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;
  final bool isMobile;

  const BaseKPICard({
    Key? key,
    required this.title,
    required this.icon,
    required this.color,
    required this.child,
    this.isMobile = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.2)),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ColoresTema.cardBackground,
              ColoresTema.cardBackground.withOpacity(0.9),
            ],
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: Icon(icon, size: 120, color: color.withOpacity(0.05)),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color.withOpacity(0.6), color.withOpacity(0.2)],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(isMobile ? 12 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(icon, color: color, size: 18),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: ColoresTema.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    child,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}