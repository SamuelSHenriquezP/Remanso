import 'package:flutter/material.dart';
import '../theme/remanso_theme.dart';

/// Widget de fotografía con efecto Ken Burns (respiración visual continua).
/// Aplica un zoom sutil y pausado (1.0 a 1.12) en ciclos de 16 segundos.
/// Permite mantener presionado o tocar para apreciar la fotografía limpia en pantalla completa.
class KenBurnsPhoto extends StatefulWidget {
  final String imageUrl;
  final String heroTag;
  final double? height;
  final double? width;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final bool enableFullScreenOnTap;
  final String? captionTitle;
  final String? captionSubtitle;

  const KenBurnsPhoto({
    super.key,
    required this.imageUrl,
    required this.heroTag,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.enableFullScreenOnTap = true,
    this.captionTitle,
    this.captionSubtitle,
  });

  @override
  State<KenBurnsPhoto> createState() => _KenBurnsPhotoState();
}

class _KenBurnsPhotoState extends State<KenBurnsPhoto>
    with SingleTickerProviderStateMixin {
  late final AnimationController _kenBurnsController;
  late final Animation<double> _scaleAnimation;
  late final Animation<Alignment> _alignmentAnimation;

  @override
  void initState() {
    super.initState();
    // Ciclo de respiración lenta de 16 segundos
    _kenBurnsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(
        parent: _kenBurnsController,
        curve: Curves.easeInOutSine,
      ),
    );

    _alignmentAnimation = AlignmentTween(
      begin: Alignment.center,
      end: const Alignment(0.08, -0.05),
    ).animate(
      CurvedAnimation(
        parent: _kenBurnsController,
        curve: Curves.easeInOutSine,
      ),
    );
  }

  @override
  void dispose() {
    _kenBurnsController.dispose();
    super.dispose();
  }

  void _openCleanFullScreen(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.94),
        pageBuilder: (context, animation, secondaryAnimation) {
          return _CleanFullScreenView(
            imageUrl: widget.imageUrl,
            heroTag: widget.heroTag,
            title: widget.captionTitle,
            subtitle: widget.captionSubtitle,
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
    Widget imageContent = AnimatedBuilder(
      animation: _kenBurnsController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          alignment: _alignmentAnimation.value,
          child: Image.network(
            widget.imageUrl,
            fit: widget.fit,
            height: widget.height,
            width: widget.width,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: RemansoTheme.surfaceStone,
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        RemansoTheme.accentForest.withOpacity(0.6),
                      ),
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: RemansoTheme.surfaceStone,
                child: Center(
                  child: Icon(
                    Icons.image_outlined,
                    color: RemansoTheme.textSubtle,
                    size: 36,
                  ),
                ),
              );
            },
          ),
        );
      },
    );

    if (widget.borderRadius != null) {
      imageContent = ClipRRect(
        borderRadius: widget.borderRadius!,
        child: imageContent,
      );
    }

    if (widget.enableFullScreenOnTap) {
      imageContent = GestureDetector(
        onTap: () => _openCleanFullScreen(context),
        onLongPress: () => _openCleanFullScreen(context),
        child: Stack(
          children: [
            imageContent,
            Positioned(
              top: 14,
              right: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.2), width: 0.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.crop_free_rounded, color: Colors.white, size: 13),
                    const SizedBox(width: 4),
                    Text(
                      'Toca para limpiar',
                      style: RemansoTheme.uiFont(
                        fontSize: 10,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Hero(
      tag: widget.heroTag,
      child: imageContent,
    );
  }
}

/// Vista modal de fotografía limpia sin distracciones (Pura contemplación)
class _CleanFullScreenView extends StatelessWidget {
  final String imageUrl;
  final String heroTag;
  final String? title;
  final String? subtitle;

  const _CleanFullScreenView({
    required this.imageUrl,
    required this.heroTag,
    this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Imagen interactiva con zoom y paneo
          Center(
            child: InteractiveViewer(
              minScale: 0.8,
              maxScale: 3.5,
              child: Hero(
                tag: '${heroTag}_fullscreen',
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image, color: Colors.white54, size: 48),
                ),
              ),
            ),
          ),

          // Botón cerrar discreto
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 20,
            child: IconButton(
              style: IconButton.styleFrom(
                backgroundColor: Colors.black45,
                shape: const CircleBorder(),
              ),
              icon: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),

          // Pie de foto editorial en la base
          if (title != null || subtitle != null)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 20,
              left: 24,
              right: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white12, width: 0.5),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null)
                      Text(
                        title!,
                        style: RemansoTheme.displayFont(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: RemansoTheme.uiFont(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 12,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
