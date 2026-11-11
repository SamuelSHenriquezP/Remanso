import 'package:flutter/material.dart';
import '../data/devotional_repository.dart';
import '../models/devotional_models.dart';
import '../theme/remanso_theme.dart';
import '../widgets/editorial_sheets.dart';
import '../widgets/remanso_logo.dart';
import '../widgets/wave_widgets.dart';
import 'devotional_session_screen.dart';

/// Módulo 1: Orden Diario (Home)
/// Experiencia estética inspirada en Calm, Expand y Bambú:
/// Atmósfera crepuscular serena, grid fotográfico de 2 columnas de alta gama,
/// hero card de inspiración diaria y filtros interactivos en píldoras fluidas.
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
  String _selectedFilter = 'Todos';

  final List<String> _filters = [
    'Todos',
    'Salmos de Paz',
    'Quietud',
    'Noche de Reposo',
    'Alba & Fe',
  ];

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'BUENOS DÍAS • PAZ A TU ALMA';
    if (hour < 19) return 'BUENAS TARDES • TIEMPO DE REPOSO';
    return 'BUENAS NOCHES • PAZ EN SU PRESENCIA';
  }

  void _openDevotional(DevotionalDay day) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 380),
        reverseTransitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (context, animation, secondaryAnimation) {
          return DevotionalSessionScreen(
            day: day,
            onCompleted: () => setState(() {}),
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
      ),
    );
  }

  List<DevotionalDay> _getFilteredDays(List<DevotionalCourse> courses) {
    // Extraer todos los días de todos los cursos para formar la biblioteca rica estilo Calm
    final List<DevotionalDay> allDays = [];
    for (final course in courses) {
      allDays.addAll(course.days);
    }

    if (_selectedFilter == 'Todos') {
      return allDays;
    } else if (_selectedFilter == 'Salmos de Paz') {
      return allDays.where((d) => d.scriptureVerse.toLowerCase().contains('salmo')).toList();
    } else if (_selectedFilter == 'Quietud') {
      return allDays.where((d) => d.courseId == 'habitar-en-la-quietud').toList();
    } else if (_selectedFilter == 'Noche de Reposo') {
      return allDays.where((d) => d.dayNumber % 2 == 0).toList();
    } else {
      return allDays.where((d) => d.dayNumber % 2 != 0).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _repo,
      builder: (context, child) {
        final course = _repo.activeCourse;
        final currentDay = _repo.todayDevotional;
        final filteredDays = _getFilteredDays(_repo.courses);

        return Scaffold(
          backgroundColor: const Color(0xFF101927),
          body: Stack(
            children: [
              // 1. Fondo Atmosférico Calm (Gradiente Crepuscular profundo con halo)
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF1B2B44),
                        Color(0xFF131D2E),
                        Color(0xFF0E1522),
                      ],
                      stops: [0.0, 0.45, 1.0],
                    ),
                  ),
                ),
              ),

              // 2. Contenido Desplazable Fluido y Cinemático
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // A. Encabezado de la App (Saludo + Remanso + Emblema)
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
                          // Renglón superior: Saludo cálido y opciones
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.wb_sunny_rounded,
                                    size: 14,
                                    color: Color(0xFFE5B26E),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _getGreeting(),
                                    style: RemansoTheme.labelFont(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.8,
                                      color: const Color(0xFFB4C4DB),
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
                          const SizedBox(height: 12),

                          // Título "Remanso" con Emblema del Sol
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Remanso',
                                style: RemansoTheme.displayFont(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const RemansoLogo(
                                size: 28,
                                variant: RemansoLogoVariant.iconOnly,
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Aguas de reposo para el camino diario',
                            style: RemansoTheme.readingFont(
                              fontSize: 14.5,
                              fontStyle: FontStyle.italic,
                              color: const Color(0xFFB4C4DB),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // B. Filtros Horizontales en Píldoras (Estilo Calm Imagen 1)
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 48,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: _filters.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final filter = _filters[index];
                          final isSelected = filter == _selectedFilter;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedFilter = filter;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOutCubic,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.09),
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.16),
                                  width: 0.8,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.25),
                                          blurRadius: 10,
                                          offset: const Offset(0, 3),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  filter,
                                  style: RemansoTheme.uiFont(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: isSelected
                                        ? const Color(0xFF0F1726)
                                        : Colors.white.withOpacity(0.88),
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // C. Hero Card: "Inspiración de Hoy" (Estilo Expand Imagen 3 & Calm)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                      child: _buildCalmHeroInspiration(course, currentDay),
                    ),
                  ),

                  // D. Encabezado de la Sección Fotográfica
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Meditaciones de Paz',
                            style: RemansoTheme.uiFont(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.2,
                            ),
                          ),
                          Text(
                            '${filteredDays.length} disponibles',
                            style: RemansoTheme.labelFont(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF8DA0BC),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // E. Grid Fotográfico de 2 Columnas (Estilo Calm Imagen 1 - Exacto)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.82,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final day = filteredDays[index];
                          final isCompleted = _repo.isDayCompleted(day.id);

                          return _buildCalmGridPhotoCard(day, isCompleted);
                        },
                        childCount: filteredDays.length,
                      ),
                    ),
                  ),

                  // F. Carrusel Horizontal de Planes y Rutas (Estilo Calm)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Rutas de Acompañamiento',
                            style: RemansoTheme.uiFont(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.2,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => PlanSelectionGuideSheet.show(context),
                            child: Text(
                              'Ver Rutas →',
                              style: RemansoTheme.uiFont(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFE5B26E),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 145,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: _repo.courses.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 14),
                        itemBuilder: (context, index) {
                          final c = _repo.courses[index];
                          final isActive = c.id == _repo.activeCourseId;
                          return _buildCourseCarouselCard(c, isActive);
                        },
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: 56),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // --- 1. HERO INSPIRACIÓN DE HOY (Estilo Expand / Calm) ---
  Widget _buildCalmHeroInspiration(DevotionalCourse course, DevotionalDay day) {
    return TactilePressCard(
      onTap: () => _openDevotional(day),
      child: Container(
        height: 235,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // A. Fotografía viva de la creación
              Image.network(
                day.photo.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFF1E2D44),
                ),
              ),

              // B. Velo degradado suave
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.30),
                      Colors.transparent,
                      Colors.black.withOpacity(0.85),
                    ],
                    stops: const [0.0, 0.35, 1.0],
                  ),
                ),
              ),

              // C. Contenido del Hero
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Badge superior
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.45),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.20),
                              width: 0.6,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.auto_awesome_rounded,
                                size: 12,
                                color: Color(0xFFE5B26E),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'REMANSO DE HOY',
                                style: RemansoTheme.labelFont(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.40),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.access_time_rounded, size: 11, color: Colors.white70),
                              const SizedBox(width: 4),
                              Text(
                                '${day.estimatedMinutes} min',
                                style: RemansoTheme.uiFont(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Bloque Inferior: Título, Versículo y Botón "Meditar"
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          day.scriptureVerse.toUpperCase(),
                          style: RemansoTheme.labelFont(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.4,
                            color: const Color(0xFFE5B26E),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          day.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: RemansoTheme.displayFont(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '«${day.getVerse(_repo.preferredBibleVersion)}»',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: RemansoTheme.readingFont(
                            fontSize: 13.5,
                            fontStyle: FontStyle.italic,
                            color: Colors.white.withOpacity(0.92),
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Botón Pill Blanco / Esmeralda
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.play_arrow_rounded,
                                size: 18,
                                color: Color(0xFF101927),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Meditar ahora',
                                style: RemansoTheme.uiFont(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF101927),
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
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

  // --- 2. TARJETA FOTOGRÁFICA EN GRID DE 2 COLUMNAS (Estilo Calm Imagen 1 - Exacto) ---
  Widget _buildCalmGridPhotoCard(DevotionalDay day, bool isCompleted) {
    return TactilePressCard(
      onTap: () => _openDevotional(day),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // A. Fotografía pura de la creación
              Image.network(
                day.photo.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFF1C273C),
                  child: const Icon(Icons.image_outlined, color: Colors.white38),
                ),
              ),

              // B. Velo degradado inferior para legibilidad cinematográfica
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.18),
                      Colors.transparent,
                      Colors.black.withOpacity(0.55),
                      Colors.black.withOpacity(0.88),
                    ],
                    stops: const [0.0, 0.40, 0.70, 1.0],
                  ),
                ),
              ),

              // C. Badges superiores: Duración y Completado
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.15),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.access_time_rounded, size: 10, color: Colors.white70),
                      const SizedBox(width: 3.5),
                      Text(
                        '${day.estimatedMinutes} min',
                        style: RemansoTheme.uiFont(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (isCompleted)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF2EC4B6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 11,
                      color: Colors.white,
                    ),
                  ),
                ),

              // D. Título y Cita Bíblica al pie de la foto
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      day.scriptureVerse,
                      style: RemansoTheme.labelFont(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: const Color(0xFFE5B26E),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      day.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: RemansoTheme.displayFont(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.25,
                      ),
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

  // --- 3. CARRUSEL DE RUTAS Y PLANES FORMATIVOS (Estilo Calm) ---
  Widget _buildCourseCarouselCard(DevotionalCourse course, bool isActive) {
    return GestureDetector(
      onTap: () {
        _repo.setActiveCourse(course.id);
      },
      child: Container(
        width: 250,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isActive
                ? const Color(0xFFE5B26E).withOpacity(0.7)
                : Colors.white.withOpacity(0.12),
            width: isActive ? 1.5 : 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.20),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                course.coverImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFF1E2D44),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.15),
                      Colors.black.withOpacity(0.85),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
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
                            color: Colors.black.withOpacity(0.50),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${course.days.length} DÍAS',
                            style: RemansoTheme.labelFont(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        if (isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5B26E),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'EN CURSO',
                              style: RemansoTheme.labelFont(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF101927),
                              ),
                            ),
                          ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: RemansoTheme.displayFont(
                            fontSize: 16.5,
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
                            color: const Color(0xFFB4C4DB),
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
