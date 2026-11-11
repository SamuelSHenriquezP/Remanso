import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../data/devotional_repository.dart';
import '../theme/remanso_theme.dart';
import '../widgets/remanso_logo.dart';
import '../widgets/wave_widgets.dart';

/// Pantalla de Apertura Contemplativa de Remanso:
/// Animación tranquila, sencilla y directa: una ola suave asciende desde el pie
/// de la pantalla elevando la fotografía completa del día y el versículo.
/// La ola termina de subir hacia la parte superior y se completa sin retroceder jamás hacia abajo.
class SplashWaveScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const SplashWaveScreen({
    super.key,
    required this.onComplete,
  });

  @override
  State<SplashWaveScreen> createState() => _SplashWaveScreenState();
}

class _SplashWaveScreenState extends State<SplashWaveScreen>
    with TickerProviderStateMixin {
  late final AnimationController _waveMotionController;
  late final AnimationController _waveAscentController;
  late final Animation<double> _waveAscentAnimation;
  late final Animation<double> _contentFadeAnimation;

  final DevotionalRepository _repo = DevotionalRepository();
  Timer? _autoProgressTimer;
  bool _hasTriggeredComplete = false;

  @override
  void initState() {
    super.initState();

    // 1. Ondulación continua serena y pausada (6 segundos por ciclo)
    _waveMotionController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    // 2. Ascenso tranquilo y directo de la ola subiendo la foto completa
    _waveAscentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _waveAscentAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _waveAscentController,
        curve: Curves.easeInOutCubic,
      ),
    );

    // Revelación suave del texto durante el ascenso
    _contentFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _waveAscentController,
        curve: const Interval(0.20, 0.85, curve: Curves.easeIn),
      ),
    );

    _waveAscentController.forward();

    // Tras leer con calma (3.5s), la ola termina de subir fluidamente hacia arriba
    _autoProgressTimer = Timer(const Duration(milliseconds: 3600), () {
      if (mounted) {
        _finishAscentAndComplete();
      }
    });
  }

  void _finishAscentAndComplete() {
    if (_hasTriggeredComplete) return;
    _autoProgressTimer?.cancel();

    // La animación continúa subiendo de forma directa hasta salir por arriba
    if (_waveAscentController.status != AnimationStatus.completed) {
      _waveAscentController.animateTo(
        1.0,
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeOutCubic,
      ).then((_) => _safeComplete());
    } else {
      _safeComplete();
    }
  }

  void _safeComplete() {
    if (!_hasTriggeredComplete && mounted) {
      _hasTriggeredComplete = true;
      widget.onComplete();
    }
  }

  @override
  void dispose() {
    _autoProgressTimer?.cancel();
    _waveMotionController.dispose();
    _waveAscentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final today = _repo.todayDevotional;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: _finishAscentAndComplete,
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _waveMotionController,
            _waveAscentController,
          ]),
          builder: (context, _) {
            final double ascent = _waveAscentAnimation.value;
            // La ola sube desde el pie (ascent: 0) hasta superar la cima (ascent: 1.0)
            final double waveTopY = size.height * (1.0 - (ascent * 1.08));

            return Stack(
              fit: StackFit.expand,
              children: [
                // 1. Fotografía completa del día que asciende y se asienta con la ola
                Positioned.fill(
                  child: ClipRect(
                    child: Transform.translate(
                      offset: Offset(0, size.height * (1.0 - ascent) * 0.18),
                      child: Image.network(
                        today.photo.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: RemansoTheme.matteObsidian,
                        ),
                      ),
                    ),
                  ),
                ),

                // Gradiente suave de contemplación
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.35),
                          Colors.black.withOpacity(0.20),
                          Colors.black.withOpacity(0.70),
                        ],
                      ),
                    ),
                  ),
                ),

                // 2. Ola única, sencilla y directa (sube tranquila hacia arriba sin capas dobles)
                Positioned(
                  top: waveTopY,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: CustomPaint(
                    painter: TranquilSingleWavePainter(
                      wavePhase: _waveMotionController.value * 2 * math.pi,
                      waveHeight: 20.0,
                      waveColor: RemansoTheme.scaffoldLinen.withOpacity(0.97),
                      crestColor: RemansoTheme.borderSubtle.withOpacity(0.4),
                    ),
                    child: Container(),
                  ),
                ),

                // 3. Tarjeta central lírica con el versículo y emblema
                Positioned(
                  left: 28,
                  right: 28,
                  bottom: size.height * 0.16,
                  child: FadeTransition(
                    opacity: _contentFadeAnimation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
                      decoration: BoxDecoration(
                        color: const Color(0xFF142034).withOpacity(0.92),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.18),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.40),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const RemansoLogo(
                            size: 34,
                            variant: RemansoLogoVariant.iconOnly,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'REMANSO DEL DÍA',
                            style: RemansoTheme.labelFont(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2.2,
                              color: const Color(0xFFE5B26E),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '«${today.getVerse(_repo.preferredBibleVersion)}»',
                            textAlign: TextAlign.center,
                            style: RemansoTheme.displayFont(
                              fontSize: 20.5,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                              height: 1.45,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '— ${today.scriptureVerse}',
                            style: RemansoTheme.uiFont(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFB4C4DB),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 4. Botón de ingreso directo estilo Bambú / Calm
                Positioned(
                  bottom: MediaQuery.of(context).padding.bottom + 22,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: TactilePressCard(
                      onTap: _finishAscentAndComplete,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B8B62),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1B8B62).withOpacity(0.45),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Entrar al Remanso',
                              style: RemansoTheme.uiFont(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 15,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
