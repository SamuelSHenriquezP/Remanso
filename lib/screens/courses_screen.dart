import 'package:flutter/material.dart';
import '../data/devotional_repository.dart';
import '../models/devotional_models.dart';
import '../theme/remanso_theme.dart';
import '../widgets/editorial_sheets.dart';
import '../widgets/wave_widgets.dart';
import 'course_detail_screen.dart';

/// Módulo 3: Catálogo Formativo de Cursos y Rutas Devocionales
/// Biblioteca editorial organizada por temas, con tarjetas en AspectRatio 16:9,
/// tipografía editorial Cormorant Garamond / Plus Jakarta Sans y micro-interacciones táctiles.
class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final DevotionalRepository _repo = DevotionalRepository();
  String _selectedCategory = 'Todos';

  final List<String> _categories = [
    'Todos',
    'Salmos & Quietud',
    'Fotografía & Fe',
    'Paz & Sabiduría',
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _repo,
      builder: (context, child) {
        final allCourses = _repo.courses;
        final filteredCourses = _selectedCategory == 'Todos'
            ? allCourses
            : allCourses.where((c) => c.category == _selectedCategory).toList();

        return Scaffold(
          backgroundColor: RemansoTheme.scaffoldLinen,
          appBar: AppBar(
            title: const Text('Planes Devocionales'),
            automaticallyImplyLeading: false,
            actions: [
              const Padding(
                padding: EdgeInsets.only(right: 6),
                child: Center(
                  child: ThemeSelectorPill(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 18),
                child: Center(
                  child: TactilePressCard(
                    onTap: () => RemansoVisionSheet.show(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                      decoration: BoxDecoration(
                        color: RemansoTheme.surfaceStone,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: RemansoTheme.borderSubtle,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.spa_outlined,
                            size: 14,
                            color: RemansoTheme.accentForest,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Sembrar',
                            style: RemansoTheme.labelFont(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                              color: RemansoTheme.accentForest,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Encabezado editorial
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CATÁLOGO FORMATIVO',
                        style: RemansoTheme.labelFont(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.2,
                          color: RemansoTheme.accentForest,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Cursos escritos por personas y mentores reales',
                        style: RemansoTheme.displayFont(
                          fontSize: 26,
                          fontWeight: FontWeight.w400,
                          color: RemansoTheme.textCharcoal,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Cada ruta une el estudio bíblico sosegado con fotografías originales que ilustran la pedagogía de Dios en la creación.',
                        style: RemansoTheme.uiFont(
                          fontSize: 13.5,
                          color: RemansoTheme.textMuted,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Chips de Categorías Temáticas
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 48,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = category == _selectedCategory;

                      return ChoiceChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedCategory = category);
                          }
                        },
                        labelStyle: RemansoTheme.uiFont(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected ? Colors.white : RemansoTheme.textMuted,
                        ),
                        selectedColor: RemansoTheme.accentForest,
                        backgroundColor: RemansoTheme.surfaceStone,
                        side: BorderSide(
                          color: isSelected ? RemansoTheme.accentForest : RemansoTheme.borderSubtle,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        showCheckmark: false,
                      );
                    },
                  ),
                ),
              ),

              // Lista de Cursos
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final course = filteredCourses[index];
                      final isActive = course.id == _repo.activeCourseId;
                      final progress = _repo.getCourseProgress(course.id);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: TactilePressCard(
                          onTap: () {
                            Navigator.of(context).push(
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) {
                                  return CourseDetailScreen(course: course);
                                },
                                transitionsBuilder:
                                    (context, animation, secondaryAnimation, child) {
                                  return FadeTransition(opacity: animation, child: child);
                                },
                              ),
                            );
                          },
                          child: _buildCourseCard(course, isActive, progress),
                        ),
                      );
                    },
                    childCount: filteredCourses.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 30)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCourseCard(DevotionalCourse course, bool isActive, double progress) {
    return Container(
      decoration: BoxDecoration(
        color: RemansoTheme.surfacePure,
        borderRadius: RemansoTheme.cardRadius,
        border: Border.all(
          color: isActive ? RemansoTheme.accentSand : RemansoTheme.borderSubtle,
          width: isActive ? 1.5 : 1,
        ),
        boxShadow: RemansoTheme.organicShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Portada AspectRatio(16/9)
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    course.coverImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: RemansoTheme.surfaceStone,
                      child: Icon(Icons.image, color: RemansoTheme.textSubtle, size: 36),
                    ),
                  ),
                ),
                Positioned(
                  top: 14,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text(
                      course.category.toUpperCase(),
                      style: RemansoTheme.labelFont(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                if (isActive)
                  Positioned(
                    top: 14,
                    right: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: RemansoTheme.textCharcoal,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check, color: Colors.white, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            'RUTA ACTUAL',
                            style: RemansoTheme.labelFont(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Contenido textual de la tarjeta
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${course.totalDays} DÍAS',
                      style: RemansoTheme.labelFont(
                        fontSize: 10.5,
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
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4,
                    backgroundColor: RemansoTheme.surfaceStone,
                    valueColor: AlwaysStoppedAnimation<Color>(RemansoTheme.accentForest),
                  ),
                ),
                const SizedBox(height: 14),

                // Título
                Text(
                  course.title,
                  style: RemansoTheme.displayFont(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: RemansoTheme.textCharcoal,
                  ),
                ),
                const SizedBox(height: 4),

                // Autor real
                Row(
                  children: [
                    Icon(Icons.person_outline_rounded,
                        size: 14, color: RemansoTheme.accentTerracotta),
                    const SizedBox(width: 4),
                    Text(
                      'Por ${course.author.name}',
                      style: RemansoTheme.uiFont(
                        fontSize: 12,
                        color: RemansoTheme.accentTerracotta,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Breve extracto
                Text(
                  course.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: RemansoTheme.readingFont(
                    fontSize: 14,
                    color: RemansoTheme.textMuted,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),

                // Botones de acción
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(color: RemansoTheme.borderSubtle),
                        ),
                        child: Center(
                          child: Text(
                            'Explorar Ruta',
                            style: RemansoTheme.uiFont(
                              fontSize: 12,
                              color: RemansoTheme.textCharcoal,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (!isActive) ...[
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            await _repo.setActiveCourse(course.id);
                            if (!mounted) return;
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('«${course.title}» es ahora tu ruta activa'),
                                backgroundColor: RemansoTheme.textCharcoal,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: RemansoTheme.textCharcoal,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(2),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: Text(
                            'Hacer Activa',
                            style: RemansoTheme.uiFont(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
