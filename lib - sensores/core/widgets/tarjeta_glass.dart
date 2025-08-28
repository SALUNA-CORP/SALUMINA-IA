// lib/core/widgets/tarjeta_glass.dart
import 'package:flutter/material.dart';

class TarjetaGlass extends StatelessWidget {
 final Widget child;
 
 const TarjetaGlass({
   super.key,
   required this.child,
 });
 
 @override
 Widget build(BuildContext context) {
   return ClipRRect(
     borderRadius: BorderRadius.circular(15),
     child: Container(
       decoration: BoxDecoration(
         color: Colors.white.withOpacity(0.1),
         borderRadius: BorderRadius.circular(15),
         border: Border.all(
           color: Colors.white.withOpacity(0.2),
           width: 1.5,
         ),
       ),
       child: child,
     ),
   );
 }
}