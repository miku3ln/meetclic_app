import 'package:flutter/material.dart';

import '../../../../domain/models/business_day.dart';
import '../../../../domain/models/day_schedule.dart';
import '../../atoms/scheduling/day_text_atom.dart';
import '../../atoms/scheduling/schedule_status_atom.dart';

class ScheduleRowMolecule extends StatelessWidget {
  final String day;
  final String status;
  final bool isToday;

  const ScheduleRowMolecule({
    super.key,
    required this.day,
    required this.status,
    this.isToday = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          DayTextAtom(day: day, isToday: isToday),
          ScheduleStatusAtom(status: status, isToday: isToday),
        ],
      ),
    );
  }
}

class ScheduleAccordionMolecule extends StatelessWidget {
  final DaySchedule daySchedule;

  /// Colores opcionales (si son null se usan los defaults)
  final Color? dayColor; // color del texto del día
  final Color? todayDayColor; // color del día si es hoy
  final Color? openStatusColor; // color del rango cuando está abierto
  final Color? closedStatusColor; // color del texto "Cerrado"
  final Color? rangeColor; // color de los rangos al expandir

  const ScheduleAccordionMolecule({
    super.key,
    required this.daySchedule,
    this.dayColor,
    this.todayDayColor,
    this.openStatusColor,
    this.closedStatusColor,
    this.rangeColor,
  });

  @override
  Widget build(BuildContext context) {
    final isToday = daySchedule.isToday;
    final hasRanges = daySchedule.openRanges.isNotEmpty;
    final bool isOpen = daySchedule.isOpen && hasRanges;

    // Texto principal:
    final String mainStatus = isOpen
        ? "Abierto: " + _formatRange(daySchedule.openRanges.first)
        : "Cerrado";

    // ====== Colores resueltos con fallback ======
    final Color resolvedDayColor = isToday & isOpen
        ? (todayDayColor ?? Colors.green)
        : (dayColor ?? Colors.black);

    final Color resolvedStatusColor = isToday & isOpen
        ? (openStatusColor ?? Colors.green)
        : (closedStatusColor ?? Colors.black);

    final Color resolvedRangeColor = rangeColor ?? Colors.black87;
    // ============================================

    // Si NO hay rangos o está cerrado: fila simple (sin acordeón)
    if (!hasRanges || !daySchedule.isOpen) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Día a la IZQUIERDA
            Text(
              daySchedule.day,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: resolvedDayColor,
              ),
            ),
            // Estado/Rango a la DERECHA
            Text(
              mainStatus,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: resolvedStatusColor,
              ),
            ),
          ],
        ),
      );
    }

    // Si HAY rangos → usamos ExpansionTile
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 0.0),
      childrenPadding: const EdgeInsets.only(left: 0.0, bottom: 8.0),
      // Cabecera: día izquierda, hora derecha
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            daySchedule.day,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              color: resolvedDayColor,
            ),
          ),
          Text(
            mainStatus,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: resolvedStatusColor,
            ),
          ),
        ],
      ),
      // Flecha de expansión la maneja ExpansionTile automáticamente
      children: daySchedule.openRanges
          .map(
            (range) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Sangría visual para alinear con el texto del día
                  const SizedBox(width: 16),
                  // Rango alineado a la derecha
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        _formatRange(range),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: resolvedRangeColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  // Ajusta esto según tu modelo de ScheduleRange
  String _formatRange(ScheduleRange range) {
    // Ejemplo si ScheduleRange tiene startTime y endTime en "HH:mm:ss"
    final start = _shortTime(range.startTime.modelBreakdown);
    final end = _shortTime(range.endTime.modelBreakdown);
    return "$start - $end";
  }

  String _shortTime(String full) {
    // full: "08:33:00" -> "08:33"
    final parts = full.split(":");
    if (parts.length >= 2) {
      return "${parts[0]}:${parts[1]}";
    }
    return full;
  }
}
