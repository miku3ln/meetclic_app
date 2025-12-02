import 'package:flutter/material.dart';
import 'package:meetclic_app/presentation/pages/business_detail_page.dart';

import '../molecules/sponsor_footer.dart';
import '../molecules/task_body_text.dart';
import '../molecules/task_header.dart';
import '../molecules/task_image.dart';

class GamifiedTaskCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final String badge;
  final IconData icon;
  final String imageUrl;
  final String sponsor;
  final String endDate;
  final String buttonText;
  final Color buttonColor;
  final VoidCallback onPressed;

  const GamifiedTaskCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.badge,
    required this.icon,
    required this.imageUrl,
    required this.sponsor,
    required this.endDate,
    required this.buttonText,
    required this.buttonColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 6,
      color: Colors.white, // Fondo blanco
      shadowColor: theme.primaryColor, // Sombra azul clara
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Bordes redondeados
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TaskHeader(title: title, subtitle: subtitle, badge: badge),
                  const SizedBox(height: 10),
                  TaskBodyText(
                    description: description,
                    buttonText: buttonText,
                    buttonColor: buttonColor,
                    onPressed: onPressed,
                  ),
                  const SizedBox(height: 10),
                  SponsorFooter(
                    sponsor: sponsor,
                    sponsorTitle: 'AUSPICIADO POR',
                    endDateTitle: 'FINALIZA',
                    endDate: endDate,
                    onSponsorTap: () {
                      // Navigator.pushNamed(context, '/empresa/$sponsor');
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BusinessDetailPage(businessId: 1),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            TaskImage(imageUrl: imageUrl),
          ],
        ),
      ),
    );
  }
}
