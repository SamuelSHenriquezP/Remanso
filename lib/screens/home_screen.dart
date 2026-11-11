import 'package:flutter/material.dart';
import '../data/devotional_repository.dart';
import '../models/devotional_models.dart';
import '../theme/remanso_theme.dart';
import '../widgets/editorial_sheets.dart';
import '../widgets/remanso_logo.dart';
import '../widgets/wave_widgets.dart';
import 'devotional_session_screen.dart';

/// Módulo 1: Orden Diario (Home)
/// Arquitectura visual inspirada fielmente en Expand (Monroe Institute):
/// Fondo obsidiana puro, una sola familia tipográfica coherente (Plus Jakarta Sans),
/// tarjeta Hero con la Palabra de Dios y fotografía de naturaleza,
/// lenguaje devocional cristiano y bordes sobrios de 14px.
class HomeScreen extends StatefulWidget {
  final VoidCallback? onTriggerWaveSplash;
  final VoidCallback? onExploreCourses;

  const HomeScreen({
    super.key,
    this.onTriggerWaveSplash,
    this.onExploreCourses,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DevotionalRepository _repo = DevotionalRepository();

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días';
    if (hour < 19) return 'Buenas tardes';
    return 'Buenas noches';
  }

  void _openDevotional(DevotionalDay day) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 320),
        reverseTransitionDuration: const Duration(milliseconds: 240),
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
    return ListenableBuilder(
      listenable: _repo,
      builder: (context, child) {
        final course = _repo.activeCourse;
        final currentDay = _repo.todayDevotional;

        return Scaffold(
          backgroundColor: const Color(0xFF0C0E12),
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. Cabecera Minimalista Estilo Expand (Sol + Saludo + Opciones)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 16,
                    left: 20,
                    right: 20,
                    bottom: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Renglón superior: Icono de sol sutil y opciones
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.wb_sunny_outlined,
                                size: 15,
                                color: Color(0xFF8E9BAE),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _getGreeting(),
                                style: RemansoTheme.displayFont(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              BibleVersionPill(day: currentDay, darkTheme: true),
                              const SizedBox(width: 8),
                              const ThemeSelectorPill(),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Nombre de la app "Remanso" con logotipo
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Remanso',
                            style: RemansoTheme.displayFont(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const RemansoLogo(
                            size: 24,
                            variant: RemansoLogoVariant.iconOnly,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Aguas de reposo para el camino diario',
                        style: RemansoTheme.readingFont(
                          fontSize: 13.5,
                          color: const Color(0xFF8E9BAE),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Tarjeta Hero "LA PALABRA DE HOY" (Inspiración de Hoy - Exacto a Expand)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                  child: _buildExpandHeroCard(course, currentDay),
                ),
              ),

              // 3. Encabezado de Sección: Devocionales y Oración
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Devocionales en la Palabra',
                        style: RemansoTheme.displayFont(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => PlanSelectionGuideSheet.show(context),
                        child: Text(
                          'Ver Planes →',
                          style: RemansoTheme.uiFont(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF3B6882),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 4. Lista Limpia de Devocionales (Tarjetas con Esquinas de 14px)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final day = course.days[index];
                      final isSelected = index == _repo.activeDayIndex;
                      final isCompleted = _repo.isDayCompleted(day.id);

                      return _buildExpandDayCard(
                        day: day,
                        index: index,
                        isSelected: isSelected,
                        isCompleted: isCompleted,
                      );
                    },
                    childCount: course.days.length,
                  ),
                ),
              ),

              // 5. Carrusel de Planes Bíblicos (Expand Estilo)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Text(
                    'Planes de Discipulado',
                    style: RemansoTheme.displayFont(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: SizedBox(
                  height: 140,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _repo.courses.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final c = _repo.courses[index];
                      final isActive = c.id == _repo.activeCourseId;
                      return _buildExpandCourseCard(c, isActive);
                    },
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 48),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- TARJETA HERO: LA PALABRA DE HOY (Estilo Expand - Imagen Central) ---
  Widget _buildExpandHeroCard(DevotionalCourse course, DevotionalDay day) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161A22),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0x18FFFFFF),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Parte Superior: Fotografía de la Naturaleza (Altura equilibrada)
            SizedBox(
              height: 200,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    day.photo.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFF141820),
                    ),
                  ),
                  // Gradiente inferior sobre la foto
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          const Color(0xFF161A22).withOpacity(0.95),
                        ],
                        stops: const [0.55, 1.0],
                      ),
                    ),
                  ),
                  // Badge superior discreto
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'DÍA ${day.dayNumber} • ${day.estimatedMinutes} MIN',
                        style: RemansoTheme.labelFont(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Parte Inferior: La Palabra de Dios, Cita y Botón de Oración
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LA PALABRA DE HOY',
                    style: RemansoTheme.labelFont(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.0,
                      color: const Color(0xFF8E9BAE),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Título del pasaje
                  Text(
                    day.title,
                    style: RemansoTheme.displayFont(
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Versículo bíblico
                  Text(
                    '«${day.getVerse(_repo.preferredBibleVersion)}»',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: RemansoTheme.readingFont(
                      fontSize: 14.5,
                      color: Colors.white.withOpacity(0.92),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),

                  Text(
                    '— ${day.scriptureVerse}',
                    style: RemansoTheme.uiFont(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF8E9BAE),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Botón Pill Acero Azul Estilo Expand (Play ►)
                  TactilePressCard(
                    onTap: () => _openDevotional(day),
                    child: Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B6882),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF3B6882).withOpacity(0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Orar con este pasaje',
                            style: RemansoTheme.uiFont(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.play_arrow_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- RENGLÓN DE DEVOCIONAL (Estilo Expand - 14px radius, foto y datos limpios) ---
  Widget _buildExpandDayCard({
    required DevotionalDay day,
    required int index,
    required bool isSelected,
    required bool isCompleted,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TactilePressCard(
        onTap: () {
          _repo.setActiveDayIndex(index);
          _openDevotional(day);
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF161A22),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF3B6882)
                  : const Color(0x14FFFFFF),
              width: isSelected ? 1.2 : 0.8,
            ),
          ),
          child: Row(
            children: [
              // Miniatura de la naturaleza (60x60, radio de 10px)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: Image.network(
                    day.photo.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFF141820),
                      child: const Icon(Icons.image_outlined, size: 20, color: Colors.white30),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Contenido bíblico y título
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
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                            color: const Color(0xFF8E9BAE),
                          ),
                        ),
                        if (isCompleted)
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 15,
                            color: Color(0xFF3B6882),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      day.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: RemansoTheme.displayFont(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      day.scriptureVerse,
                      style: RemansoTheme.uiFont(
                        fontSize: 12,
                        color: const Color(0xFF8E9BAE),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Flecha o icono sutil de avance
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: Color(0xFF63738A),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- TARJETA DE PLAN / CURSO (Estilo Expand) ---
  Widget _buildExpandCourseCard(DevotionalCourse course, bool isActive) {
    return GestureDetector(
      onTap: () {
        _repo.setActiveCourse(course.id);
      },
      child: Container(
        width: 230,
        decoration: BoxDecoration(
          color: const Color(0xFF161A22),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive
                ? const Color(0xFF3B6882)
                : const Color(0x14FFFFFF),
            width: isActive ? 1.2 : 0.8,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                course.coverImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFF141820),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.85),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${course.days.length} DÍAS',
                        style: RemansoTheme.labelFont(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: RemansoTheme.displayFont(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          course.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: RemansoTheme.uiFont(
                            fontSize: 11,
                            color: const Color(0xFF8E9BAE),
                          ),
                        ),
                      ],
                    ),
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
