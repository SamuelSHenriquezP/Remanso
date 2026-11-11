import 'package:flutter/material.dart';

import '../data/devotional_repository.dart';
import '../models/devotional_models.dart';
import '../theme/remanso_theme.dart';
import '../widgets/editorial_biblical_widgets.dart';
import '../widgets/editorial_sheets.dart';
import '../widgets/ken_burns_image.dart';
import '../widgets/wave_widgets.dart';
import 'selah_contemplative_screen.dart';

/// Pantalla de Sesión Inmersiva en 3 Pasos Guiados:
/// 1. Contemplación (La Lente): Fotografía con Ken Burns + Historia técnica y espiritual.
/// 2. Medita en la Palabra: Pasaje bíblico destacado con borde terracota + reflexión del autor.
/// 3. Diario & Oración: Oración guiada + campo editorial para escribir + Guardado y completitud local.
class DevotionalSessionScreen extends StatefulWidget {
  final DevotionalDay day;
  final VoidCallback? onCompleted;

  const DevotionalSessionScreen({
    super.key,
    required this.day,
    this.onCompleted,
  });

  @override
  State<DevotionalSessionScreen> createState() =>
      _DevotionalSessionScreenState();
}

class _DevotionalSessionScreenState extends State<DevotionalSessionScreen> {
  int _currentStep = 0; // 0: Contemplación, 1: Palabra, 2: Diario
  final TextEditingController _journalController = TextEditingController();
  final DevotionalRepository _repo = DevotionalRepository();
  bool _isSaving = false;

  final List<String> _stepTitles = [
    '1. Contemplación',
    '2. La Palabra',
    '3. Diario & Oración',
  ];

  @override
  void dispose() {
    _journalController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _completeDay() async {
    setState(() => _isSaving = true);

    await _repo.completeDayAndSaveJournal(
      day: widget.day,
      userReflection: _journalController.text,
    );

    setState(() => _isSaving = false);

    if (!mounted) return;

    // Mostrar diálogo o sheet de paz y confirmación
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CompletionSuccessSheet(
        dayTitle: widget.day.title,
        onDone: () {
          Navigator.of(context).pop(); // Cierra el sheet
          Navigator.of(context).pop(); // Cierra la sesión
          widget.onCompleted?.call();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RemansoTheme.scaffoldLinen,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: _previousStep,
        ),
        title: Text(
          _stepTitles[_currentStep],
          style: RemansoTheme.displayFont(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.self_improvement_rounded,
              size: 22,
              color: RemansoTheme.accentForest,
            ),
            tooltip: 'Santuario Selah (Silencio)',
            onPressed: () {
              SelahContemplativeScreen.open(
                context,
                widget.day,
                _repo.preferredBibleVersion,
              );
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: Row(
            children: List.generate(3, (index) {
              return Expanded(
                child: Container(
                  height: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: index <= _currentStep
                        ? RemansoTheme.accentForest
                        : RemansoTheme.borderSubtle.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 380),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                final slide = Tween<Offset>(
                  begin: const Offset(0.04, 0),
                  end: Offset.zero,
                ).animate(animation);
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(position: slide, child: child),
                );
              },
              child: _buildCurrentStepView(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStepView() {
    switch (_currentStep) {
      case 0:
        return _buildStep1Contemplation();
      case 1:
        return _buildStep2Word();
      case 2:
      default:
        return _buildStep3Journal();
    }
  }

  // --- PASO 1: CONTEMPLACIÓN (LA LENTE) ---
  Widget _buildStep1Contemplation() {
    final photo = widget.day.photo;

    return SingleChildScrollView(
      key: const ValueKey('step_1_contemplation'),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fotografía con Ken Burns y toque para ver limpia
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: [
                KenBurnsPhoto(
                  imageUrl: photo.imageUrl,
                  heroTag: 'photo_${widget.day.id}',
                  height: 330,
                  width: double.infinity,
                  captionTitle: widget.day.title,
                  captionSubtitle: '${photo.location} • ${photo.timeOfDay}',
                ),
                // Banda inferior de ubicación
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: RemansoTheme.accentSand,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            photo.location,
                            style: RemansoTheme.uiFont(
                              fontSize: 12,
                              color: Colors.white,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Título y Cita
          Text(
            'DÍA ${widget.day.dayNumber} • PAUSA VISUAL',
            style: RemansoTheme.labelFont(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.0,
              color: RemansoTheme.accentForest,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.day.title,
            style: RemansoTheme.displayFont(
              fontSize: 28,
              fontWeight: FontWeight.w400,
              color: RemansoTheme.textCharcoal,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 12),

          // Ficha técnica fotográfica en renglón sutil (sin caja pesada)
          Row(
            children: [
              Icon(
                Icons.camera_alt_outlined,
                size: 14,
                color: RemansoTheme.accentTerracotta,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${photo.camera} · ${photo.lens} · ${photo.aperture} · ${photo.iso} · ${photo.timeOfDay}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: RemansoTheme.uiFont(
                    fontSize: 11.5,
                    color: RemansoTheme.textMuted,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Historia espiritual tras la lente (fluye con espacio negativo)
          Text(
            photo.spiritualBehindTheLens,
            style: RemansoTheme.readingFont(
              fontSize: 16.5,
              fontStyle: FontStyle.italic,
              color: RemansoTheme.textCharcoal.withOpacity(0.92),
              height: 1.68,
            ),
          ),
          const SizedBox(height: 36),

          // Botón Continuar
          _buildActionButton(
            label: 'Continuar a la Palabra',
            icon: Icons.menu_book_rounded,
            onPressed: _nextStep,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // --- PASO 2: MEDITA EN LA PALABRA ---
  Widget _buildStep2Word() {
    final course = _repo.activeCourse;

    return ListenableBuilder(
      listenable: _repo,
      builder: (context, _) {
        final currentVersion = _repo.preferredBibleVersion;
        final currentVerseText = widget.day.getVerse(currentVersion);

        return SingleChildScrollView(
          key: const ValueKey('step_2_word'),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pasaje Bíblico Destacado con filete editorial terracota (sin caja pesada)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.only(left: 18, top: 4, bottom: 4),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: RemansoTheme.accentTerracotta,
                      width: 3.5,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            widget.day.scriptureVerse,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: RemansoTheme.labelFont(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.8,
                              color: RemansoTheme.accentTerracotta,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        BibleVersionPill(day: widget.day),
                      ],
                    ),
                    const SizedBox(height: 12),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) =>
                          FadeTransition(opacity: animation, child: child),
                      child: Text(
                        '«$currentVerseText»',
                        key: ValueKey(
                          '${widget.day.id}_${currentVersion.name}',
                        ),
                        style: RemansoTheme.displayFont(
                          fontSize: 22,
                          color: RemansoTheme.textCharcoal,
                          height: 1.5,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentVersion.attribution,
                      style: RemansoTheme.uiFont(
                        fontSize: 11,
                        color: RemansoTheme.textSubtle.withOpacity(0.85),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),

              // Pausa sugerida: Biblia de papel (Línea sutil, sin caja pesada)
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Row(
                  children: [
                    Icon(
                      Icons.auto_stories_outlined,
                      size: 15,
                      color: RemansoTheme.accentForest,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Pausa sugerida: Si tienes tu Biblia física a mano, ábrela en este capítulo para contemplar el contexto completo.',
                        style: RemansoTheme.readingFont(
                          fontSize: 12.5,
                          fontStyle: FontStyle.italic,
                          color: RemansoTheme.textMuted,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Raíz lingüística en Hebreo / Griego (si existe)
              if (widget.day.rootWord != null) ...[
                BiblicalRootCard(rootWord: widget.day.rootWord!),
                const SizedBox(height: 14),
              ],

              // Conexión canónica con Cristo y la historia de salvación (si existe)
              if (widget.day.crossReference != null &&
                  widget.day.crossReference!.isNotEmpty) ...[
                CanonicalCrossReferenceCard(
                  crossReference: widget.day.crossReference!,
                ),
                const SizedBox(height: 22),
              ],

              const SizedBox(height: 26),

              // Autor de la reflexión
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
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
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: RemansoTheme.textCharcoal,
                          ),
                        ),
                        Text(
                          course.author.role,
                          style: RemansoTheme.uiFont(
                            fontSize: 11.5,
                            color: RemansoTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // Reflexión Escrita Editorial con Letra Capital Iluminada
              EditorialDropCapText(
                text: widget.day.reflectionText,
                dropCapColor: RemansoTheme.accentTerracotta,
              ),
              const SizedBox(height: 32),

              // Botón Avanzar a Oración
              _buildActionButton(
                label: 'Avanzar a Oración y Diario',
                icon: Icons.edit_note_rounded,
                onPressed: _nextStep,
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  // --- PASO 3: DIARIO & ORACIÓN GUIADA ---
  Widget _buildStep3Journal() {
    return SingleChildScrollView(
      key: const ValueKey('step_3_journal'),
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).viewInsets.bottom + 40,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pregunta de meditación / Guía de oración (Directa y poética, sin caja pesada)
          Row(
            children: [
              Icon(
                Icons.spa_outlined,
                size: 16,
                color: RemansoTheme.accentForest,
              ),
              const SizedBox(width: 8),
              Text(
                'PREGUNTA DE MEDITACIÓN & ORACIÓN',
                style: RemansoTheme.labelFont(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.8,
                  color: RemansoTheme.accentForest,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '«${widget.day.reflectionPrompt}»',
            style: RemansoTheme.displayFont(
              fontSize: 22,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.italic,
              color: RemansoTheme.textCharcoal,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 28),

          // Campo de texto de diario limpio y editorial
          Text(
            'Tu Oración o Reflexión Personal',
            style: RemansoTheme.displayFont(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: RemansoTheme.textCharcoal,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: RemansoTheme.surfacePure,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: RemansoTheme.borderSubtle, width: 1),
              boxShadow: RemansoTheme.subtleShadow,
            ),
            child: TextField(
              controller: _journalController,
              maxLines: 7,
              minLines: 5,
              style: RemansoTheme.readingFont(
                fontSize: 16,
                color: RemansoTheme.textCharcoal,
                height: 1.6,
              ),
              decoration: InputDecoration(
                hintText: 'Escribe aquí con libertad: tus dudas, tu gratitud o lo que Dios habló hoy a tu corazón...',
                hintStyle: RemansoTheme.uiFont(
                  fontSize: 13.5,
                  color: RemansoTheme.textSubtle.withOpacity(0.8),
                  height: 1.5,
                ),
                contentPadding: const EdgeInsets.all(20),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 12,
                color: RemansoTheme.textSubtle,
              ),
              const SizedBox(width: 4),
              Text(
                'Privado y guardado solo en este dispositivo',
                style: RemansoTheme.uiFont(
                  fontSize: 11,
                  color: RemansoTheme.textSubtle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Botón Completar Día y Guardar
          _buildActionButton(
            label: _isSaving
                ? 'Guardando en tu diario...'
                : 'Completar Día y Guardar',
            icon: Icons.check_circle_outline_rounded,
            onPressed: _isSaving ? null : _completeDay,
            isPrimary: true,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
    bool isPrimary = false,
  }) {
    return TactilePressCard(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          color: isPrimary
              ? const Color(0xFF1B8B62) // Verde esmeralda sereno estilo Bambú
              : Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(30),
          border: isPrimary
              ? null
              : Border.all(color: Colors.white.withOpacity(0.18), width: 0.8),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: const Color(0xFF1B8B62).withOpacity(0.40),
                    blurRadius: 16,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: RemansoTheme.uiFont(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Modal bottom sheet conmemorativo de completitud serena
class _CompletionSuccessSheet extends StatelessWidget {
  final String dayTitle;
  final VoidCallback onDone;

  const _CompletionSuccessSheet({required this.dayTitle, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            color: RemansoTheme.textCharcoal,
            size: 36,
          ),
          const SizedBox(height: 16),

          Text(
            'PAUSA COMPLETADA',
            style: RemansoTheme.labelFont(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.2,
              color: RemansoTheme.textMuted,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            dayTitle,
            textAlign: TextAlign.center,
            style: RemansoTheme.displayFont(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: RemansoTheme.textCharcoal,
            ),
          ),
          const SizedBox(height: 12),

          Text(
            'Tu oración ha quedado resguardada en tu diario privado. Que la paz de Dios guarde tu corazón durante el resto del día.',
            textAlign: TextAlign.center,
            style: RemansoTheme.readingFont(
              fontSize: 14,
              color: RemansoTheme.textMuted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),

          TactilePressCard(
            onTap: onDone,
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: RemansoTheme.textCharcoal,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'Volver al Reposo',
                  style: RemansoTheme.uiFont(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
