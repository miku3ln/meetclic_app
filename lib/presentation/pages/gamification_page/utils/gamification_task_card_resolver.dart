import 'package:flutter/material.dart';
import 'package:meetclic_app/domain/gamification/entities/c2b_gamification_task.dart';

import '../models/gamification_page_all_model.dart';

class GamificationCardTypeResolver {
  static GamificationCardVariant resolve(C2BGamificationTask task) {
    try {
      // 1) Imagen
      final String source = task.sourceUrl ?? '';
      final bool hasImage = source.trim().isNotEmpty;

      // 2) Expiración (todo null-safe)
      final DateTime now = DateTime.now();
      final DateTime? end = task.endDate;

      bool isExpired = false;
      bool isAboutToExpire = false;

      if (task.hasExpiration && end != null) {
        isExpired = now.isAfter(end);
        if (!isExpired) {
          final diffDays = end.difference(now).inDays;
          isAboutToExpire = diffDays >= 0 && diffDays <= 3;
        }
      }

      Color badgeColor = Colors.grey;
      if (isExpired) {
        badgeColor = Colors.red;
      } else if (isAboutToExpire) {
        badgeColor = Colors.orange;
      } else if (task.hasExpiration && end != null) {
        badgeColor = Colors.blue;
      }

      // 3) Tipo de puntos
      final typePoints = task.typePoints ?? '';
      Color rewardColor = Colors.purple;
      if (typePoints == 'suma-yapitas') {
        rewardColor = Colors.amber;
      } else if (typePoints == 'yapitas') {
        rewardColor = Colors.purple;
      }

      // 4) Layout
      GamificationCardLayout layout = GamificationCardLayout.compact;
      if (hasImage) {
        layout = GamificationCardLayout.imageLeft;
      }
      if ((task.points ?? 0) >= 120) {
        layout = GamificationCardLayout.full;
      }

      return GamificationCardVariant(
        layout: layout,
        badgeColor: badgeColor,
        rewardColor: rewardColor,
        showImage: hasImage,
      );
    } catch (e, st) {
      debugPrint('[GamificationCardTypeResolver] ERROR: $e\n$st');
      // Fallback súper seguro
      return const GamificationCardVariant(
        layout: GamificationCardLayout.compact,
        badgeColor: Colors.grey,
        rewardColor: Colors.grey,
        showImage: false,
      );
    }
  }

  /// Devuelve las tasks agrupadas por layout
  static Map<GamificationCardLayout, List<C2BGamificationTask>> groupByLayout(
    List<C2BGamificationTask> tasks,
  ) {
    final Map<GamificationCardLayout, List<C2BGamificationTask>> map = {
      GamificationCardLayout.imageLeft: [],
      GamificationCardLayout.full: [],
      GamificationCardLayout.compact: [],
    };

    for (final task in tasks) {
      final layout = resolve(task);
      map[layout]!.add(task);
    }

    return map;
  }
}
