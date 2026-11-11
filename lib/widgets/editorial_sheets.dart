import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/devotional_repository.dart';
import '../models/devotional_models.dart';
import '../theme/remanso_theme.dart';
import 'remanso_logo.dart';
import 'wave_widgets.dart';

/// Modal Editorial para Selección y Comparación de Versiones Bíblicas:
/// Permite alternar la traducción global en tiempo real (RVR1960, NVI, NTV, VBL),
/// previsualizar cómo se lee el versículo activo con AnimatedSwitcher y
/// consultar la nota legal de atribución (Fair Use / Creative Commons).
class BibleVersionSelectorSheet extends StatefulWidget {
  final DevotionalDay day;

  const BibleVersionSelectorSheet({
    super.key,
    required this.day,
  });

  static Future<void> show(BuildContext context, DevotionalDay day) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BibleVersionSelectorSheet(day: day),
    );
  }

  @override
  State<BibleVersionSelectorSheet> createState() => _BibleVersionSelectorSheetState();
}

class _BibleVersionSelectorSheetState extends State<BibleVersionSelectorSheet> {
  final DevotionalRepository _repo = DevotionalRepository();
  late BibleVersion _tempSelectedVersion;

  @override
  void initState() {
    super.initState();
    _tempSelectedVersion = _repo.preferredBibleVersion;
  }

  void _selectVersion(BibleVersion version) {
    setState(() {
      _tempSelectedVersion = version;
    });
    _repo.setPreferredBibleVersion(version);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: RemansoTheme.scaffoldLinen,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        top: 14,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Barra de agarre
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: RemansoTheme.borderSubtle,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Título y Cita
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TRADUCCIONES BÍBLICAS',
                    style: RemansoTheme.labelFont(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.8,
                      color: RemansoTheme.accentForest,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Comparar & Elegir Versión',
                    style: RemansoTheme.displayFont(
                      fontSize: 23,
                      fontWeight: FontWeight.w500,
                      color: RemansoTheme.textCharcoal,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: RemansoTheme.accentTerracottaLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.day.scriptureVerse,
                  style: RemansoTheme.uiFont(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: RemansoTheme.accentTerracotta,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Cuadro de Previsualización en Vivo del Versículo
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: RemansoTheme.surfacePure,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: RemansoTheme.accentSand.withOpacity(0.4), width: 1),
              boxShadow: RemansoTheme.subtleShadow,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: Column(
                key: ValueKey(_tempSelectedVersion),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _tempSelectedVersion.title.toUpperCase(),
                        style: RemansoTheme.labelFont(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.4,
                          color: RemansoTheme.accentTerracotta,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: RemansoTheme.accentForest.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Activa',
                          style: RemansoTheme.labelFont(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: RemansoTheme.accentForest,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '«${widget.day.getVerse(_tempSelectedVersion)}»',
                    style: RemansoTheme.displayFont(
                      fontSize: 18,
                      color: RemansoTheme.textCharcoal,
                      height: 1.55,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Opciones de Versiones Bíblicas (Selector interactivo)
          Text(
            'SELECCIONA TU VERSIÓN PREFERIDA',
            style: RemansoTheme.labelFont(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: RemansoTheme.textSubtle,
            ),
          ),
          const SizedBox(height: 10),

          Column(
            children: BibleVersion.values.map((version) {
              final isSelected = _tempSelectedVersion == version;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TactilePressCard(
                  onTap: () => _selectVersion(version),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? RemansoTheme.surfaceStone
                          : RemansoTheme.surfacePure,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? RemansoTheme.accentForest
                            : RemansoTheme.borderSubtle,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? RemansoTheme.accentForest
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? RemansoTheme.accentForest
                                  : RemansoTheme.textSubtle,
                              width: 1.5,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, size: 12, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? RemansoTheme.accentForest
                                : RemansoTheme.surfaceStone,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            version.code,
                            style: RemansoTheme.labelFont(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? Colors.white : RemansoTheme.textCharcoal,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            version.title,
                            style: RemansoTheme.uiFont(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: RemansoTheme.textCharcoal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // Nota de atribución legal Fair Use
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: RemansoTheme.surfaceStone.withOpacity(0.5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, size: 13, color: RemansoTheme.textSubtle),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _tempSelectedVersion.attribution,
                    style: RemansoTheme.uiFont(
                      fontSize: 10,
                      color: RemansoTheme.textSubtle,
                      height: 1.45,
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
}

/// Píldora interactiva minimalista para cambiar la versión bíblica en cualquier pantalla
class BibleVersionPill extends StatelessWidget {
  final DevotionalDay day;
  final bool darkTheme;

  const BibleVersionPill({
    super.key,
    required this.day,
    this.darkTheme = false,
  });

  @override
  Widget build(BuildContext context) {
    final repo = DevotionalRepository();

    return ListenableBuilder(
      listenable: repo,
      builder: (context, child) {
        final currentVersion = repo.preferredBibleVersion;

        return TactilePressCard(
          onTap: () => BibleVersionSelectorSheet.show(context, day),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: darkTheme
                  ? Colors.white.withOpacity(0.12)
                  : RemansoTheme.surfaceStone,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: darkTheme
                    ? Colors.white.withOpacity(0.2)
                    : RemansoTheme.borderSubtle,
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  currentVersion.code,
                  style: RemansoTheme.labelFont(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: darkTheme
                        ? RemansoTheme.accentSand
                        : RemansoTheme.accentForest,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.unfold_more_rounded,
                  size: 13,
                  color: darkTheme ? Colors.white70 : RemansoTheme.accentForest,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Modal Editorial de Visión y Siembra:
/// Filosofía "Gratis recibido, gratis dado" (Mateo 10:8),
/// Hoja de ruta transparente para Remanso Web y Muro Comunitario de Oración.
class RemansoVisionSheet extends StatelessWidget {
  const RemansoVisionSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const RemansoVisionSheet(),
    );
  }

  Future<void> _openSupportLink(BuildContext context) async {
    // Enlace preparado para Ko-fi, Buy Me A Coffee o donaciones ministeriales
    final uri = Uri.parse('https://buymeacoffee.com/remanso');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          _showSupportDialog(context);
        }
      }
    } catch (_) {
      if (context.mounted) {
        _showSupportDialog(context);
      }
    }
  }

  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: RemansoTheme.scaffoldLinen,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Sembrar en Remanso',
          style: RemansoTheme.displayFont(fontSize: 22, fontWeight: FontWeight.w500),
        ),
        content: Text(
          'Gracias por tu deseo de bendecir este proyecto. Si deseas apoyar el sostenimiento de los servidores y la expansión comunitaria, puedes contactarnos directamente o visitar el repositorio oficial.',
          style: RemansoTheme.readingFont(fontSize: 14.5, color: RemansoTheme.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Aceptar con Paz',
              style: RemansoTheme.uiFont(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: RemansoTheme.accentForest,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: RemansoTheme.scaffoldLinen,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        top: 14,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barra de agarre
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: RemansoTheme.borderSubtle,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Encabezado con Logo Oficial
            Row(
              children: [
                const RemansoLogo(
                  size: 44,
                  variant: RemansoLogoVariant.iconOnly,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FILOSOFÍA & VISIÓN',
                        style: RemansoTheme.labelFont(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.0,
                          color: RemansoTheme.accentForest,
                        ),
                      ),
                      Text(
                        'Gratis recibido, gratis dado',
                        style: RemansoTheme.displayFont(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          color: RemansoTheme.textCharcoal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Manifiesto de Transparencia
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: RemansoTheme.surfacePure,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: RemansoTheme.borderSubtle),
                boxShadow: RemansoTheme.subtleShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '«De gracia recibisteis, dad de gracia.» — Mateo 10:8',
                    style: RemansoTheme.displayFont(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: RemansoTheme.accentTerracotta,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Remanso nació como un santuario digital para el alma: 100% privado, sin anuncios invasivos, sin suscripciones obligatorias ni muros de pago. Creemos que la Palabra y la contemplación deben permanecer abiertas para cualquier persona que busque paz.',
                    style: RemansoTheme.readingFont(
                      fontSize: 14,
                      color: RemansoTheme.textCharcoal,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Tarjeta de Meta Transparente (Roadmap Comunitario)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: RemansoTheme.surfaceStone,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: RemansoTheme.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'PRÓXIMA META DEL PROYECTO',
                        style: RemansoTheme.labelFont(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: RemansoTheme.accentForest,
                        ),
                      ),
                      Text(
                        '68% alcanzado',
                        style: RemansoTheme.uiFont(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: RemansoTheme.accentForest,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Remanso Web & Muro Comunitario de Oración',
                    style: RemansoTheme.displayFont(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: RemansoTheme.textCharcoal,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Queremos llevar Remanso al navegador y habilitar un muro seguro y anónimo donde creyentes de distintos lugares puedan orar los unos por los otros.',
                    style: RemansoTheme.uiFont(
                      fontSize: 12.5,
                      color: RemansoTheme.textMuted,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Barra de progreso
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: 0.68,
                      minHeight: 6,
                      backgroundColor: Colors.white,
                      valueColor: AlwaysStoppedAnimation<Color>(RemansoTheme.accentForest),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Hitos
                  _buildMilestone(
                    number: '1',
                    title: 'Motor móvil offline y diseño editorial',
                    isDone: true,
                  ),
                  _buildMilestone(
                    number: '2',
                    title: 'Dominio web, hosting y CDN para fotografías HD',
                    isDone: false,
                    isCurrent: true,
                  ),
                  _buildMilestone(
                    number: '3',
                    title: 'Muro Comunitario de Oración y Grupos',
                    isDone: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Botón de Apoyo Voluntario
            TactilePressCard(
              onTap: () => _openSupportLink(context),
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  color: RemansoTheme.accentForest,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: RemansoTheme.darkGlowShadow,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.favorite_rounded, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Sembrar Voluntariamente en el Proyecto',
                      style: RemansoTheme.uiFont(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Nota de destino transparente de fondos
            Center(
              child: Text(
                'El 100% de las aportaciones se destina al mantenimiento de servidores e infraestructura comunitaria.',
                textAlign: TextAlign.center,
                style: RemansoTheme.uiFont(
                  fontSize: 10.5,
                  color: RemansoTheme.textSubtle,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestone({
    required String number,
    required String title,
    bool isDone = false,
    bool isCurrent = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDone
                  ? RemansoTheme.accentForest
                  : (isCurrent ? RemansoTheme.accentSand : Colors.white),
              border: Border.all(
                color: isDone
                    ? RemansoTheme.accentForest
                    : (isCurrent ? RemansoTheme.accentTerracotta : RemansoTheme.borderSubtle),
                width: 1,
              ),
            ),
            child: Center(
              child: isDone
                  ? const Icon(Icons.check, size: 11, color: Colors.white)
                  : Text(
                      number,
                      style: RemansoTheme.uiFont(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: isCurrent ? RemansoTheme.textCharcoal : RemansoTheme.textSubtle,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: RemansoTheme.uiFont(
                fontSize: 11.5,
                fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                color: isDone
                    ? RemansoTheme.textMuted
                    : (isCurrent ? RemansoTheme.textCharcoal : RemansoTheme.textSubtle),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Hoja Modal Editorial para Selección de Paletas Temáticas Reales
class ThemeSelectorSheet extends StatefulWidget {
  const ThemeSelectorSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ThemeSelectorSheet(),
    );
  }

  @override
  State<ThemeSelectorSheet> createState() => _ThemeSelectorSheetState();
}

class _ThemeSelectorSheetState extends State<ThemeSelectorSheet> {
  final DevotionalRepository _repo = DevotionalRepository();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _repo,
      builder: (context, _) {
        final currentPalette = _repo.currentThemePalette;

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: RemansoTheme.scaffoldLinen,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 32,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              // Píldora de arrastre superior
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: RemansoTheme.textSubtle.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Encabezado editorial
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: RemansoTheme.surfaceStone,
                        shape: BoxShape.circle,
                        border: Border.all(color: RemansoTheme.borderSubtle, width: 1),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.palette_outlined,
                          color: RemansoTheme.accentForest,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SISTEMA DE AMBIENTES • TEMAS REALES',
                            style: RemansoTheme.labelFont(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.6,
                              color: RemansoTheme.accentForest,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Elige tu Remanso',
                            style: RemansoTheme.displayFont(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              color: RemansoTheme.textCharcoal,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Cada paleta coordina el papel, los bordes y la luz para acompañar tu estudio según la hora y tu sensibilidad visual.',
                            style: RemansoTheme.uiFont(
                              fontSize: 12,
                              color: RemansoTheme.textMuted,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Divider(height: 1),

              // Lista de paletas temáticas
              Flexible(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shrinkWrap: true,
                  itemCount: RemansoPalette.all.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final palette = RemansoPalette.all[index];
                    final isSelected = currentPalette.id == palette.id;

                    return TactilePressCard(
                      onTap: () {
                        _repo.setThemePalette(palette);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? RemansoTheme.surfacePure
                              : RemansoTheme.surfaceStone.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? RemansoTheme.accentForest
                                : RemansoTheme.borderSubtle,
                            width: isSelected ? 1.6 : 1,
                          ),
                          boxShadow: isSelected
                              ? RemansoTheme.subtleShadow
                              : null,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Muestra cromática (Swatch cuadrante)
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: RemansoTheme.borderSubtle.withOpacity(0.5),
                                  width: 1.5,
                                ),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Expanded(child: Container(color: palette.scaffold)),
                                        Expanded(child: Container(color: palette.surfaceStone)),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Expanded(child: Container(color: palette.accentPrimary)),
                                        Expanded(child: Container(color: palette.accentSecondary)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Textos descriptivos
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        palette.name,
                                        style: RemansoTheme.displayFont(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                          color: RemansoTheme.textCharcoal,
                                        ),
                                      ),
                                      if (palette.isDark) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                          decoration: BoxDecoration(
                                            color: RemansoTheme.accentForest.withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            'NOCHE',
                                            style: RemansoTheme.labelFont(
                                              fontSize: 8.5,
                                              fontWeight: FontWeight.w700,
                                              color: RemansoTheme.accentForest,
                                              letterSpacing: 0.8,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    palette.subtitle,
                                    style: RemansoTheme.uiFont(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w500,
                                      color: RemansoTheme.accentTerracotta,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    palette.description,
                                    style: RemansoTheme.uiFont(
                                      fontSize: 11,
                                      color: RemansoTheme.textMuted,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Indicador de selección
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? RemansoTheme.accentForest
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? RemansoTheme.accentForest
                                      : RemansoTheme.textSubtle.withOpacity(0.4),
                                  width: 1.5,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 13,
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Botón de cierre
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
                child: TactilePressCard(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      color: RemansoTheme.surfaceStone,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: RemansoTheme.borderSubtle, width: 1),
                    ),
                    child: Center(
                      child: Text(
                        'Confirmar y Continuar',
                        style: RemansoTheme.uiFont(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: RemansoTheme.textCharcoal,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Píldora interactiva para abrir el selector de temas
class ThemeSelectorPill extends StatelessWidget {
  const ThemeSelectorPill({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = DevotionalRepository();

    return ListenableBuilder(
      listenable: repo,
      builder: (context, _) {
        final palette = repo.currentThemePalette;

        return TactilePressCard(
          onTap: () => ThemeSelectorSheet.show(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: RemansoTheme.surfaceStone,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: RemansoTheme.borderSubtle, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.palette_outlined,
                  size: 13,
                  color: RemansoTheme.accentForest,
                ),
                const SizedBox(width: 4),
                Text(
                  palette.name,
                  style: RemansoTheme.labelFont(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: RemansoTheme.accentForest,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Modal Editorial de Selección y Guía de Planes Devocionales
class PlanSelectionGuideSheet extends StatelessWidget {
  const PlanSelectionGuideSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PlanSelectionGuideSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = DevotionalRepository();

    return ListenableBuilder(
      listenable: repo,
      builder: (context, _) {
        final courses = repo.courses;
        final activeId = repo.activeCourseId;

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.88,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          padding: EdgeInsets.only(
            top: 14,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).padding.bottom + 20,
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Manilla de arrastre
                Center(
                  child: Container(
                    width: 36,
                    height: 3,
                    decoration: BoxDecoration(
                      color: RemansoTheme.borderSubtle,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GUÍA DE RUTAS',
                          style: RemansoTheme.labelFont(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.0,
                            color: RemansoTheme.textMuted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Elige tu Plan de Reposo',
                          style: RemansoTheme.displayFont(
                            fontSize: 24,
                            fontWeight: FontWeight.w400,
                            color: RemansoTheme.textCharcoal,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Cada plan une el estudio bíblico sosegado con fotografías originales que ilustran la pedagogía de Dios en la creación.',
                  style: RemansoTheme.readingFont(
                    fontSize: 13.5,
                    fontStyle: FontStyle.italic,
                    color: RemansoTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 20),

                // Lista vertical de planes disponibles
                ...courses.map((course) {
                  final isActive = course.id == activeId;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: isActive ? RemansoTheme.surfaceStone : Colors.white,
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(
                        color: isActive
                            ? RemansoTheme.textCharcoal
                            : RemansoTheme.borderSubtle,
                        width: 1.0,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Portada panorámica
                          Stack(
                            children: [
                              Image.network(
                                course.coverImageUrl,
                                height: 130,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  height: 130,
                                  color: RemansoTheme.surfaceStone,
                                ),
                              ),
                              Positioned(
                                top: 10,
                                left: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.75),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: Text(
                                    '${course.category.toUpperCase()} • ${course.days.length} DÍAS',
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
                                  top: 10,
                                  right: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: RemansoTheme.textCharcoal,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.check,
                                          size: 11,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'ACTIVO',
                                          style: RemansoTheme.labelFont(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  course.title,
                                  style: RemansoTheme.displayFont(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: RemansoTheme.textCharcoal,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Por ${course.author.name} • ${course.author.role}',
                                  style: RemansoTheme.uiFont(
                                    fontSize: 11.5,
                                    color: RemansoTheme.textMuted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  course.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: RemansoTheme.readingFont(
                                    fontSize: 13,
                                    color: RemansoTheme.textMuted,
                                    height: 1.45,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                SizedBox(
                                  width: double.infinity,
                                  child: isActive
                                      ? Center(
                                          child: Text(
                                            '✓ Este es tu plan activo en la Hoja de Ruta',
                                            style: RemansoTheme.uiFont(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: RemansoTheme.textCharcoal,
                                            ),
                                          ),
                                        )
                                      : ElevatedButton(
                                          onPressed: () async {
                                            await repo.setActiveCourse(course.id);
                                            if (context.mounted) {
                                              Navigator.of(context).pop();
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                RemansoTheme.textCharcoal,
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 10,
                                            ),
                                          ),
                                          child: Text(
                                            'Elegir este Plan de Reposo',
                                            style: RemansoTheme.uiFont(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                              letterSpacing: 0.4,
                                            ),
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
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}


