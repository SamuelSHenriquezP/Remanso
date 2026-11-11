import 'package:flutter/material.dart';
import '../models/devotional_models.dart';
import '../theme/remanso_theme.dart';
import 'wave_widgets.dart';

/// Hoja de Ruta Devocional ("Roadmap"):
/// Representa el camino formativo y contemplativo del curso mediante
/// tarjetas coordinadas en papel crema, lino y piedra suave (`RemansoTheme`),
/// con acentos orgánicos en salvia de bosque y terracota, sin contrastes mecánicos ni brillos artificiales.
class RoadmapTimeline extends StatelessWidget {
  final DevotionalCourse course;
  final Set<String> completedDayIds;
  final int activeDayIndex;
  final Function(int dayIndex, DevotionalDay day)? onSelectDay;
  final bool isHorizontal;

  const RoadmapTimeline({
    super.key,
    required this.course,
    required this.completedDayIds,
    required this.activeDayIndex,
    this.onSelectDay,
    this.isHorizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isHorizontal) {
      return _buildHorizontalRoadmap(context);
    }
    return _buildVerticalRoadmap(context);
  }

  // --- Versión Horizontal (Para el Home y carruseles de progreso) ---
  Widget _buildHorizontalRoadmap(BuildContext context) {
    return SizedBox(
      height: 154,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        scrollDirection: Axis.horizontal,
        itemCount: course.days.length,
        separatorBuilder: (context, index) {
          final isLinePassed = completedDayIds.contains(course.days[index].id);
          return Center(
            child: Container(
              width: 20,
              height: 2,
              decoration: BoxDecoration(
                color: isLinePassed
                    ? RemansoTheme.accentSage
                    : RemansoTheme.borderSubtle.withOpacity(0.25),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        },
        itemBuilder: (context, index) {
          final day = course.days[index];
          final isCompleted = completedDayIds.contains(day.id);
          final isCurrent = index == activeDayIndex;

          return TactilePressCard(
            onTap: () => onSelectDay?.call(index, day),
            child: _HorizontalRoadmapCard(
              day: day,
              index: index,
              isCompleted: isCompleted,
              isCurrent: isCurrent,
            ),
          );
        },
      ),
    );
  }

  // --- Versión Vertical (Para la vista de detalle de curso) ---
  Widget _buildVerticalRoadmap(BuildContext context) {
    return Column(
      children: List.generate(course.days.length, (index) {
        final day = course.days[index];
        final isCompleted = completedDayIds.contains(day.id);
        final isCurrent = index == activeDayIndex;
        final isLast = index == course.days.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Columna de conexión y nodos orgánicos
              SizedBox(
                width: 44,
                child: Column(
                  children: [
                    // Nodo superior
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? RemansoTheme.accentForest
                            : (isCurrent
                                ? RemansoTheme.surfacePure
                                : RemansoTheme.surfaceStone),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCurrent
                              ? RemansoTheme.accentForest
                              : (isCompleted
                                  ? RemansoTheme.accentForest
                                  : RemansoTheme.borderSubtle),
                          width: isCurrent ? 2 : 1,
                        ),
                        boxShadow: isCurrent ? RemansoTheme.subtleShadow : null,
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                            : (isCurrent
                                ? Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: RemansoTheme.accentForest,
                                      shape: BoxShape.circle,
                                    ),
                                  )
                                : Text(
                                    '${index + 1}',
                                    style: RemansoTheme.uiFont(
                                      fontSize: 10,
                                      color: RemansoTheme.textSubtle,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  )),
                      ),
                    ),
                    // Línea vertical conectora
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? RemansoTheme.accentSage
                                : RemansoTheme.borderSubtle.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Tarjeta táctil editorial de la hoja de ruta
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TactilePressCard(
                    onTap: () => onSelectDay?.call(index, day),
                    child: _VerticalRoadmapCard(
                      day: day,
                      index: index,
                      isCompleted: isCompleted,
                      isCurrent: isCurrent,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

/// Tarjeta horizontal compacta coordinada en lino crema / piedra suave
class _HorizontalRoadmapCard extends StatelessWidget {
  final DevotionalDay day;
  final int index;
  final bool isCompleted;
  final bool isCurrent;

  const _HorizontalRoadmapCard({
    required this.day,
    required this.index,
    required this.isCompleted,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isCurrent
        ? RemansoTheme.surfacePure
        : (isCompleted
            ? RemansoTheme.surfaceStone
            : RemansoTheme.surfaceStone.withOpacity(0.6));

    final borderColor = isCurrent
        ? RemansoTheme.accentForest
        : (isCompleted
            ? RemansoTheme.accentSage.withOpacity(0.4)
            : RemansoTheme.borderSubtle);

    return Container(
      width: 148,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: borderColor,
          width: isCurrent ? 1.6 : 1,
        ),
        boxShadow: isCurrent
            ? RemansoTheme.subtleShadow
            : [
                BoxShadow(
                  color: RemansoTheme.textCharcoal.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? RemansoTheme.accentForest.withOpacity(0.12)
                      : (isCompleted
                          ? RemansoTheme.accentSageLight.withOpacity(0.6)
                          : RemansoTheme.borderSubtle.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'DÍA ${index + 1}',
                  style: RemansoTheme.labelFont(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: isCurrent
                        ? RemansoTheme.accentForest
                        : (isCompleted
                            ? RemansoTheme.accentForest
                            : RemansoTheme.textSubtle),
                  ),
                ),
              ),
              if (isCompleted)
                Icon(
                  Icons.check_circle_rounded,
                  color: RemansoTheme.accentForest,
                  size: 16,
                )
              else if (isCurrent)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: RemansoTheme.accentForest,
                    shape: BoxShape.circle,
                  ),
                )
              else
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: RemansoTheme.textSubtle.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          Text(
            day.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: RemansoTheme.displayFont(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: RemansoTheme.textCharcoal,
              height: 1.25,
            ),
          ),
          Row(
            children: [
              Icon(
                Icons.menu_book_outlined,
                color: RemansoTheme.textSubtle,
                size: 12,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  day.scriptureVerse,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: RemansoTheme.uiFont(
                    fontSize: 10.5,
                    color: RemansoTheme.textMuted,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Tarjeta vertical completa coordinada en piedra suave y crema editorial
class _VerticalRoadmapCard extends StatelessWidget {
  final DevotionalDay day;
  final int index;
  final bool isCompleted;
  final bool isCurrent;

  const _VerticalRoadmapCard({
    required this.day,
    required this.index,
    required this.isCompleted,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isCurrent
        ? RemansoTheme.surfacePure
        : (isCompleted
            ? RemansoTheme.surfaceStone
            : RemansoTheme.surfaceStone.withOpacity(0.65));

    final borderColor = isCurrent
        ? RemansoTheme.accentForest
        : (isCompleted
            ? RemansoTheme.accentSage.withOpacity(0.35)
            : RemansoTheme.borderSubtle);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: borderColor,
          width: isCurrent ? 1.6 : 1,
        ),
        boxShadow: isCurrent
            ? RemansoTheme.subtleShadow
            : [
                BoxShadow(
                  color: RemansoTheme.textCharcoal.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Miniatura fotográfica con bordes finos
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              day.photo.imageUrl,
              width: 58,
              height: 58,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 58,
                height: 58,
                color: RemansoTheme.surfaceStone,
                child: Icon(
                  Icons.image_outlined,
                  color: RemansoTheme.textSubtle,
                  size: 22,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Contenido textual con tipografía editorial
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'DÍA ${index + 1} • ${day.estimatedMinutes} MIN',
                      style: RemansoTheme.labelFont(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                        color: isCurrent
                            ? RemansoTheme.accentForest
                            : RemansoTheme.textMuted,
                      ),
                    ),
                    if (isCompleted)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: RemansoTheme.accentSageLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check,
                              color: RemansoTheme.accentForest,
                              size: 11,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'HECHO',
                              style: RemansoTheme.labelFont(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: RemansoTheme.accentForest,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (isCurrent)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: RemansoTheme.accentForest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'HOY',
                          style: RemansoTheme.labelFont(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  day.title,
                  style: RemansoTheme.displayFont(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: RemansoTheme.textCharcoal,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  day.scriptureVerse,
                  style: RemansoTheme.uiFont(
                    fontSize: 12,
                    color: RemansoTheme.textMuted,
                    letterSpacing: 0.3,
                  ),
                ),
                if (day.rootWord != null) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: RemansoTheme.accentTerracotta.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: RemansoTheme.accentTerracotta.withOpacity(0.2),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      '${day.rootWord!.language.toUpperCase()} • ${day.rootWord!.originalScript} (${day.rootWord!.transliteration})',
                      style: RemansoTheme.labelFont(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: RemansoTheme.accentTerracotta,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
