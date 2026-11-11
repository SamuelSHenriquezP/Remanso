import 'package:flutter/material.dart';
import '../data/devotional_repository.dart';
import '../models/devotional_models.dart';
import '../theme/remanso_theme.dart';
import '../widgets/roadmap_timeline.dart';
import '../widgets/wave_widgets.dart';
import 'devotional_session_screen.dart';

/// Pantalla de Detalle de Curso / Ruta Devocional:
/// Muestra cabecera inmersiva con cresta de ola, biografía del autor humano,
/// botón para activarlo como curso actual y la Hoja de Ruta completa
/// con sus tarjetas coordinadas en papel crema y piedra suave.
class CourseDetailScreen extends StatefulWidget {
  final DevotionalCourse course;

  const CourseDetailScreen({
    super.key,
    required this.course,
  });

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  final DevotionalRepository _repo = DevotionalRepository();

  void _openDay(DevotionalDay day) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return DevotionalSessionScreen(
            day: day,
            onCompleted: () => setState(() {}),
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final course = widget.course;
    final isCurrentActive = _repo.activeCourseId == course.id;
    final progress = _repo.getCourseProgress(course.id);

    return Scaffold(
      backgroundColor: RemansoTheme.scaffoldLinen,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Cabecera Sliver con imagen de portada y cresta de ola
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: RemansoTheme.scaffoldLinen,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    course.coverImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: RemansoTheme.matteObsidian,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.4),
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  // Ola en la base de la cabecera fotográfica
                  Positioned(
                    bottom: -1,
                    left: 0,
                    right: 0,
                    child: AmbientWaveBar(
                      height: 38,
                      color: RemansoTheme.scaffoldLinen,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Contenido Editorial del Curso
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categoría y Días
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: RemansoTheme.accentSageLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          course.category.toUpperCase(),
                          style: RemansoTheme.labelFont(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.4,
                            color: RemansoTheme.accentForest,
                          ),
                        ),
                      ),
                      Text(
                        '${course.totalDays} DÍAS DE PAUSA',
                        style: RemansoTheme.labelFont(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                          color: RemansoTheme.textSubtle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Título del curso
                  Text(
                    course.title,
                    style: RemansoTheme.displayFont(
                      fontSize: 30,
                      fontWeight: FontWeight.w400,
                      color: RemansoTheme.textCharcoal,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    course.subtitle,
                    style: RemansoTheme.uiFont(
                      fontSize: 13.5,
                      color: RemansoTheme.accentTerracotta,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Barra de Progreso
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'PROGRESO DEL CURSO',
                            style: RemansoTheme.labelFont(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                              color: RemansoTheme.textSubtle,
                            ),
                          ),
                          Text(
                            '${(progress * 100).toInt()}% completado',
                            style: RemansoTheme.uiFont(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: RemansoTheme.accentForest,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: RemansoTheme.surfaceStone,
                          valueColor: AlwaysStoppedAnimation<Color>(RemansoTheme.accentForest),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Botón Activar como Curso Actual con TactilePressCard
                  TactilePressCard(
                    onTap: isCurrentActive
                        ? null
                        : () async {
                            final messenger = ScaffoldMessenger.of(context);
                            await _repo.setActiveCourse(course.id);
                            setState(() {});
                            if (!mounted) return;
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('«${course.title}» es ahora tu ruta activa'),
                                backgroundColor: RemansoTheme.accentForest,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        color: isCurrentActive
                            ? RemansoTheme.surfaceStone
                            : RemansoTheme.accentForest,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: isCurrentActive ? null : RemansoTheme.darkGlowShadow,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isCurrentActive ? Icons.check_circle_outline_rounded : Icons.play_arrow_rounded,
                            size: 20,
                            color: isCurrentActive ? RemansoTheme.accentForest : Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isCurrentActive ? 'Ruta Actualmente Activa' : 'Hacer Mi Ruta Actual',
                            style: RemansoTheme.uiFont(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: isCurrentActive ? RemansoTheme.accentForest : Colors.white,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Descripción general
                  Text(
                    course.description,
                    style: RemansoTheme.readingFont(
                      fontSize: 16,
                      color: RemansoTheme.textCharcoal,
                      height: 1.68,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Ficha y Biografía del Autor Humano Real
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: RemansoTheme.surfacePure,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: RemansoTheme.borderSubtle, width: 1),
                      boxShadow: RemansoTheme.subtleShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AUTOR Y MENTOR DE ESTA RUTA',
                          style: RemansoTheme.labelFont(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            color: RemansoTheme.accentForest,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundImage: NetworkImage(course.author.avatarUrl),
                              backgroundColor: RemansoTheme.surfaceStone,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    course.author.name,
                                    style: RemansoTheme.displayFont(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: RemansoTheme.textCharcoal,
                                    ),
                                  ),
                                  Text(
                                    course.author.role,
                                    style: RemansoTheme.uiFont(
                                      fontSize: 12,
                                      color: RemansoTheme.accentTerracotta,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          course.author.bio,
                          style: RemansoTheme.readingFont(
                            fontSize: 14,
                            color: RemansoTheme.textMuted,
                            height: 1.55,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Título de la Hoja de Ruta
                  Text(
                    'HOJA DE RUTA DEL DEVOCIONAL',
                    style: RemansoTheme.labelFont(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.8,
                      color: RemansoTheme.accentForest,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Camino de los días',
                    style: RemansoTheme.displayFont(
                      fontSize: 23,
                      fontWeight: FontWeight.w400,
                      color: RemansoTheme.textCharcoal,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Hoja de ruta completa coordinada en lino crema y piedra
                  RoadmapTimeline(
                    course: course,
                    completedDayIds: _repo.completedDayIds,
                    activeDayIndex: _repo.activeDayIndex,
                    isHorizontal: false,
                    onSelectDay: (index, day) {
                      _openDay(day);
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
