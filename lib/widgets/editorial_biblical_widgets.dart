import 'package:flutter/material.dart';
import '../models/devotional_models.dart';
import '../theme/remanso_theme.dart';
import 'wave_widgets.dart';

/// Párrafo editorial con Letra Capital Iluminada (Drop Cap):
/// Emula la tradición clásica de manuscritos bíblicos y publicaciones editoriales de alta gama.
class EditorialDropCapText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Color? dropCapColor;

  const EditorialDropCapText({
    super.key,
    required this.text,
    this.style,
    this.dropCapColor,
  });

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) return const SizedBox.shrink();

    final cleanText = text.trim();
    final firstChar = cleanText.substring(0, 1);
    final restOfText = cleanText.substring(1);

    final baseStyle = style ??
        RemansoTheme.readingFont(
          fontSize: 16.5,
          fontWeight: FontWeight.w400,
          color: RemansoTheme.textCharcoal,
          height: 1.72,
        );

    final initialColor = dropCapColor ?? RemansoTheme.accentTerracotta;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Letra Capital Iluminada
        Container(
          margin: const EdgeInsets.only(right: 12, top: 4),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          decoration: BoxDecoration(
            color: initialColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: initialColor.withOpacity(0.25),
              width: 1,
            ),
          ),
          child: Text(
            firstChar,
            style: RemansoTheme.displayFont(
              fontSize: 42,
              fontWeight: FontWeight.w600,
              color: initialColor,
              height: 1.0,
            ),
          ),
        ),
        // Cuerpo del texto
        Expanded(
          child: Text(
            restOfText,
            style: baseStyle,
          ),
        ),
      ],
    );
  }
}

/// Tarjeta contemplativa de Raíz Bíblica en Hebreo / Griego
class BiblicalRootCard extends StatefulWidget {
  final BiblicalRootWord rootWord;

  const BiblicalRootCard({
    super.key,
    required this.rootWord,
  });

  @override
  State<BiblicalRootCard> createState() => _BiblicalRootCardState();
}

class _BiblicalRootCardState extends State<BiblicalRootCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final root = widget.rootWord;

    return TactilePressCard(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: RemansoTheme.surfaceStone.withOpacity(0.55),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: RemansoTheme.borderSubtle,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado con código Strong y lengua original
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.translate_rounded,
                      size: 15,
                      color: RemansoTheme.accentForest,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'LENGUA ORIGINAL • ${root.language.toUpperCase()}',
                      style: RemansoTheme.labelFont(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.6,
                        color: RemansoTheme.accentForest,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: RemansoTheme.accentSageLight.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    root.strongCode,
                    style: RemansoTheme.labelFont(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: RemansoTheme.accentForest,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Palabra en grafía original grande y transliteración
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  root.originalScript,
                  style: RemansoTheme.displayFont(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: RemansoTheme.textCharcoal,
                    height: 1.1,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '«${root.transliteration}»',
                  style: RemansoTheme.readingFont(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: RemansoTheme.accentTerracotta,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Significado literal
            Text(
              root.literalMeaning,
              style: RemansoTheme.uiFont(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: RemansoTheme.textCharcoal,
                height: 1.4,
              ),
            ),

            // Explicación espiritual expandible
            if (_isExpanded && root.spiritualInsight.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Text(
                root.spiritualInsight,
                style: RemansoTheme.readingFont(
                  fontSize: 14.5,
                  color: RemansoTheme.textMuted,
                  height: 1.6,
                ),
              ),
            ],

            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  _isExpanded ? 'Mostrar menos' : 'Tocar para profundizar en la raíz',
                  style: RemansoTheme.uiFont(
                    fontSize: 11,
                    color: RemansoTheme.textSubtle,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: RemansoTheme.textSubtle,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Tarjeta de Conexión Canónica (Enlace Antiguo / Nuevo Testamento y Cristo)
class CanonicalCrossReferenceCard extends StatelessWidget {
  final String crossReference;

  const CanonicalCrossReferenceCard({
    super.key,
    required this.crossReference,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RemansoTheme.surfaceStone.withOpacity(0.5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: RemansoTheme.borderSubtle,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: RemansoTheme.accentTerracottaLight.withOpacity(0.7),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_stories_rounded,
              size: 16,
              color: RemansoTheme.accentTerracotta,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CONEXIÓN CANÓNICA • EN LA HISTORIA DE DIOS',
                  style: RemansoTheme.labelFont(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                    color: RemansoTheme.accentTerracotta,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  crossReference,
                  style: RemansoTheme.readingFont(
                    fontSize: 14.5,
                    fontStyle: FontStyle.italic,
                    color: RemansoTheme.textCharcoal,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Guía visual de 4 pasos de Lectio Divina (Lectio, Meditatio, Oratio, Contemplatio)
class LectioDivinaGuideBar extends StatelessWidget {
  final int activeIndex; // 0: Contemplación/Lente, 1: Lectio & Meditatio, 2: Oratio

  const LectioDivinaGuideBar({
    super.key,
    required this.activeIndex,
  });

  @override
  Widget build(BuildContext context) {
    final stages = [
      {'name': 'Mirada', 'latin': 'La Lente'},
      {'name': 'Palabra', 'latin': 'Lectio & Meditatio'},
      {'name': 'Oración', 'latin': 'Oratio & Diario'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: RemansoTheme.surfaceStone.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(stages.length, (index) {
          final isCurrent = index == activeIndex;
          final isPast = index < activeIndex;

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCurrent
                      ? RemansoTheme.accentForest
                      : (isPast
                          ? RemansoTheme.accentSageLight
                          : Colors.transparent),
                  border: Border.all(
                    color: isCurrent
                        ? RemansoTheme.accentForest
                        : (isPast
                            ? RemansoTheme.accentSage
                            : RemansoTheme.borderSubtle),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: isPast
                      ? Icon(Icons.check, size: 12, color: RemansoTheme.accentForest)
                      : Text(
                          '${index + 1}',
                          style: RemansoTheme.uiFont(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isCurrent ? Colors.white : RemansoTheme.textSubtle,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                stages[index]['name']!,
                style: RemansoTheme.labelFont(
                  fontSize: 10,
                  fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                  color: isCurrent ? RemansoTheme.accentForest : RemansoTheme.textSubtle,
                  letterSpacing: 0.5,
                ),
              ),
              if (index < stages.length - 1) ...[
                const SizedBox(width: 8),
                Container(
                  width: 12,
                  height: 1,
                  color: RemansoTheme.borderSubtle,
                ),
                const SizedBox(width: 8),
              ],
            ],
          );
        }),
      ),
    );
  }
}
