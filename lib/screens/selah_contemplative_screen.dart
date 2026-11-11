import 'dart:async';
import 'package:flutter/material.dart';
import '../models/devotional_models.dart';
import '../theme/remanso_theme.dart';
import '../widgets/wave_widgets.dart';

/// Modo "Selah" (Pausa y Contemplación Absoluta):
/// Un santuario visual sin distracciones para rumiar el versículo bíblico
/// con fotografía en respiración continua, tipografía lírica y temporizador de quietud.
class SelahContemplativeScreen extends StatefulWidget {
  final DevotionalDay day;
  final BibleVersion version;

  const SelahContemplativeScreen({
    super.key,
    required this.day,
    required this.version,
  });

  static Future<void> open(BuildContext context, DevotionalDay day, BibleVersion version) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        transitionDuration: const Duration(milliseconds: 500),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) {
          return SelahContemplativeScreen(day: day, version: version);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  State<SelahContemplativeScreen> createState() => _SelahContemplativeScreenState();
}

class _SelahContemplativeScreenState extends State<SelahContemplativeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _photoBreathingController;
  late final AnimationController _textPulseController;
  late final Animation<double> _photoScaleAnimation;
  late final Animation<double> _textPulseAnimation;

  Timer? _quietTimer;
  int _secondsRemaining = 0;
  int _selectedMinutes = 2; // Minutos de pausa contemplativa
  bool _isTimerActive = false;

  @override
  void initState() {
    super.initState();

    // 1. Respiración visual lenta de 20 segundos (1.0 a 1.12)
    _photoBreathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);

    _photoScaleAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(
        parent: _photoBreathingController,
        curve: Curves.easeInOutSine,
      ),
    );

    // 2. Pulso sutil de luz y presencia de 6 segundos
    _textPulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _textPulseAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _textPulseController,
        curve: Curves.easeInOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _quietTimer?.cancel();
    _photoBreathingController.dispose();
    _textPulseController.dispose();
    super.dispose();
  }

  void _startQuietTimer(int minutes) {
    _quietTimer?.cancel();
    setState(() {
      _selectedMinutes = minutes;
      _secondsRemaining = minutes * 60;
      _isTimerActive = true;
    });

    _quietTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
        setState(() => _isTimerActive = false);
      }
    });
  }

  String _formatTimer() {
    final m = _secondsRemaining ~/ 60;
    final s = _secondsRemaining % 60;
    final sStr = s < 10 ? '0$s' : '$s';
    return '$m:$sStr';
  }

  @override
  Widget build(BuildContext context) {
    final verse = widget.day.getVerse(widget.version);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Fotografía inmersiva con respiración Ken Burns de 20s
          AnimatedBuilder(
            animation: _photoScaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _photoScaleAnimation.value,
                child: Image.network(
                  widget.day.photo.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFF161815),
                  ),
                ),
              );
            },
          ),

          // 2. Velo y gradiente de penumbra contemplativa
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.55),
                    Colors.black.withOpacity(0.72),
                    Colors.black.withOpacity(0.92),
                  ],
                ),
              ),
            ),
          ),

          // 3. Contenido Central Lírico
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Barra superior con botón salir y sello Selah
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.18), width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: RemansoTheme.accentSand,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'MODO SELAH • PAUSA SAGRADA',
                              style: RemansoTheme.labelFont(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.8,
                                color: RemansoTheme.accentSand,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 40), // Balance
                    ],
                  ),

                  // Cita y Versículo Bíblico Grande en Cormorant Garamond
                  AnimatedBuilder(
                    animation: _textPulseAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _textPulseAnimation.value,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.day.scriptureVerse.toUpperCase(),
                              style: RemansoTheme.labelFont(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2.4,
                                color: RemansoTheme.accentSand,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              '«$verse»',
                              textAlign: TextAlign.center,
                              style: RemansoTheme.displayFont(
                                fontSize: 26,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                                height: 1.55,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              widget.version.title,
                              style: RemansoTheme.uiFont(
                                fontSize: 11,
                                color: Colors.white60,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  // Barra de temporizador de quietud
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isTimerActive) ...[
                        Text(
                          _formatTimer(),
                          style: RemansoTheme.displayFont(
                            fontSize: 36,
                            fontWeight: FontWeight.w300,
                            color: RemansoTheme.accentSand,
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Guarda silencio ante el Señor y espera en Él',
                          style: RemansoTheme.readingFont(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 14),
                      ] else ...[
                        Text(
                          'Elegir minutos de silencio contemplativo:',
                          style: RemansoTheme.uiFont(
                            fontSize: 11.5,
                            color: Colors.white60,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [1, 2, 5].map((mins) {
                            final isSelected = mins == _selectedMinutes;
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: TactilePressCard(
                                onTap: () => _startQuietTimer(mins),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? RemansoTheme.accentForest.withOpacity(0.85)
                                        : Colors.white.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected
                                          ? RemansoTheme.accentSand.withOpacity(0.6)
                                          : Colors.white.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    '$mins min',
                                    style: RemansoTheme.uiFont(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected ? RemansoTheme.accentSand : Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Botón salir con paz
                      TactilePressCard(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: double.infinity,
                          height: 48,
                          decoration: BoxDecoration(
                            color: RemansoTheme.accentForest,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: RemansoTheme.darkGlowShadow,
                          ),
                          child: Center(
                            child: Text(
                              'Volver a la Reflexión',
                              style: RemansoTheme.uiFont(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
