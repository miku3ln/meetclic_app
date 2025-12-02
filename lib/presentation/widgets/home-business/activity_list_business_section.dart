import 'package:flutter/material.dart';
import 'package:meetclic_app/domain/entities/business_data.dart';

import 'activity_item_business_section.dart';

class ActivityListBusiness extends StatelessWidget {
  final BusinessData businessData;
  const ActivityListBusiness({super.key, required this.businessData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: const [
        ActivityItemBusiness(
          icon: Icons.new_releases,
          title: 'Lanzamiento de nuevo producto',
          subtitle: 'Ahora disponible: Pack ahorro de limpieza ecológica',
          color: Colors.orangeAccent,
          time: 'Hace 10 min',
        ),
        ActivityItemBusiness(
          icon: Icons.thumb_up,
          title: 'Mejoramos atención al cliente',
          subtitle: 'Nuevo sistema de respuesta en menos de 2 horas',
          color: Colors.green,
          time: 'Hace 1 hora',
        ),
        ActivityItemBusiness(
          icon: Icons.campaign,
          title: 'Campaña de descuentos activos',
          subtitle: 'Descuento del 20% en servicios por tiempo limitado',
          color: Colors.purpleAccent,
          time: 'Hace 2 horas',
        ),
        ActivityItemBusiness(
          icon: Icons.star,
          title: 'Opiniones de clientes analizadas',
          subtitle: 'Mejoras aplicadas según sugerencias recientes',
          color: Colors.teal,
          time: 'Hace 3 horas',
        ),
        ActivityItemBusiness(
          icon: Icons.shopping_cart,
          title: 'Nueva categoría en la tienda',
          subtitle: 'Ahora también vendemos productos orgánicos',
          color: Colors.blueAccent,
          time: 'Hoy',
        ),
        ActivityItemBusiness(
          icon: Icons.support_agent,
          title: 'Ticket de queja resuelto',
          subtitle: 'Cliente satisfecho con atención brindada',
          color: Colors.redAccent,
          time: 'Ayer',
        ),
      ],
    );
  }
}
