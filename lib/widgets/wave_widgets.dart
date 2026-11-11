import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/remanso_theme.dart';

/// Pintor de onda única, sencilla y tranquila.
/// Diseñado para una animación directa que asciende con suavidad y serenidad,
/// sin capas dobles ni oscilaciones toscas.
class TranquilSingleWavePainter extends CustomPainter {
  final double wavePhase;
  final double waveHeight;
  final Color waveColor;
  final Color? crestColor;

  TranquilSingleWavePainter({
    required this.wavePhase,
    this.waveHeight = 22.0,
    Color? waveColor,
    this.crestColor,
  }) : waveColor = waveColor ?? RemansoTheme.scaffoldLinen;

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;
    if (width <= 0 || height <= 0) return;

    final paint = Paint()
      ..color = waveColor
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, height);
    path.lineTo(0, waveHeight);

    final k = 2 * math.pi / width;
    for (double x = 0; x <= width; x += 2.0) {
      final y = math.sin((k * x) + wavePhase) * waveHeight + waveHeight;
      path.lineTo(x, y);
    }
    path.lineTo(width, height);
    path.close();

    canvas.drawPath(path, paint);

    if (crestColor != null) {
      final crestPaint = Paint()
        ..color = crestColor!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;

      final crestPath = Path();
      crestPath.moveTo(0, math.sin(wavePhase) * waveHeight + waveHeight);
      for (double x = 0; x <= width; x += 2.0) {
        final y = math.sin((k * x) + wavePhase) * waveHeight + waveHeight;
        crestPath.lineTo(x, y);
      }
      canvas.drawPath(crestPath, crestPaint);
    }
  }

  @override
  bool shouldRepaint(covariant TranquilSingleWavePainter oldDelegate) {
    return oldDelegate.wavePhase != wavePhase ||
        oldDelegate.waveColor != waveColor ||
        oldDelegate.crestColor != crestColor;
  }
}

/// Pintor de ondas fluidas multi-armónicas.
/// Basado en la superposición de armónicos de Fourier para simular el
/// movimiento real y orgánico del agua en un remanso natural.
class HarmonicFluidWavePainter extends CustomPainter {
  final double wavePhase; // Fase principal (0.0 a 2*pi)
  final double waveHeight; // Amplitud máxima
  final Color primaryColor;
  final Color secondaryColor;
  final Color crestRimColor;
  final bool inverted;

  HarmonicFluidWavePainter({
    required this.wavePhase,
    this.waveHeight = 28.0,
    Color? primaryColor,
    Color? secondaryColor,
    Color? crestRimColor,
    this.inverted = false,
  })  : primaryColor = primaryColor ?? RemansoTheme.scaffoldLinen,
        secondaryColor = secondaryColor ?? RemansoTheme.surfaceStone.withOpacity(0.5),
        crestRimColor = crestRimColor ?? RemansoTheme.borderSubtle.withOpacity(0.35);

  // Función matemática de onda armónica natural
  double _calculateWaveY(double x, double width, double phase, double amp) {
    final k1 = 2 * math.pi / width;
    final k2 = 4 * math.pi / width;
    final k3 = math.pi / width;

    // Superposición de 3 frecuencias armónicas
    final y1 = math.sin((k1 * x) + phase) * amp;
    final y2 = math.sin((k2 * x) + (phase * 1.3) + 1.2) * (amp * 0.35);
    final y3 = math.cos((k3 * x) + (phase * 0.7) + 2.1) * (amp * 0.2);

    return y1 + y2 + y3;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;

    // Protección matemática contra dimensiones nulas o no renderizadas (evita divisiones por cero y NaNs)
    if (width <= 0 || height <= 0) return;

    // --- CAPA 1: AURA DORADA TRANSLÚCIDA (Desfasada y más lenta) ---
    final secondaryPaint = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.fill;

    final secondaryPath = Path();
    if (!inverted) {
      secondaryPath.moveTo(0, height);
      secondaryPath.lineTo(0, waveHeight);

      for (double x = 0; x <= width; x += 1.5) {
        final y = _calculateWaveY(x, width, (wavePhase * 0.8) + 0.9, waveHeight * 0.9) +
            waveHeight * 0.8;
        secondaryPath.lineTo(x, y);
      }
      secondaryPath.lineTo(width, height);
      secondaryPath.close();
    } else {
      secondaryPath.moveTo(0, 0);
      secondaryPath.lineTo(0, height - waveHeight);

      for (double x = 0; x <= width; x += 1.5) {
        final y = height -
            (_calculateWaveY(x, width, (wavePhase * 0.8) + 0.9, waveHeight * 0.9) +
                waveHeight * 0.8);
        secondaryPath.lineTo(x, y);
      }
      secondaryPath.lineTo(width, 0);
      secondaryPath.close();
    }
    canvas.drawPath(secondaryPath, secondaryPaint);

    // --- CAPA 2: ONDA PRINCIPAL DE LINO CÁLIDO ---
    final primaryPaint = Paint()
      ..shader = LinearGradient(
        begin: inverted ? Alignment.bottomCenter : Alignment.topCenter,
        end: inverted ? Alignment.topCenter : Alignment.bottomCenter,
        colors: [
          primaryColor.withOpacity(0.98),
          primaryColor,
        ],
      ).createShader(Rect.fromLTWH(0, 0, width, height))
      ..style = PaintingStyle.fill;

    final primaryPath = Path();
    final List<Offset> crestPoints = [];

    if (!inverted) {
      primaryPath.moveTo(0, height);
      primaryPath.lineTo(0, waveHeight);

      for (double x = 0; x <= width; x += 1.5) {
        final y = _calculateWaveY(x, width, wavePhase, waveHeight) + waveHeight;
        primaryPath.lineTo(x, y);
        if (x % 3 == 0) crestPoints.add(Offset(x, y));
      }
      primaryPath.lineTo(width, height);
      primaryPath.close();
    } else {
      primaryPath.moveTo(0, 0);
      primaryPath.lineTo(0, height - waveHeight);

      for (double x = 0; x <= width; x += 1.5) {
        final y = height -
            (_calculateWaveY(x, width, wavePhase, waveHeight) + waveHeight);
        primaryPath.lineTo(x, y);
        if (x % 3 == 0) crestPoints.add(Offset(x, y));
      }
      primaryPath.lineTo(width, 0);
      primaryPath.close();
    }
    canvas.drawPath(primaryPath, primaryPaint);

    // --- CAPA 3: DESTELLO DE ESPUMA/LUZ EN LA CRESTA (Línea de 1.2px) ---
    final rimPaint = Paint()
      ..color = crestRimColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    final rimPath = Path();
    if (crestPoints.isNotEmpty) {
      rimPath.moveTo(crestPoints.first.dx, crestPoints.first.dy);
      for (int i = 1; i < crestPoints.length; i++) {
        rimPath.lineTo(crestPoints[i].dx, crestPoints[i].dy);
      }
      canvas.drawPath(rimPath, rimPaint);
    }
  }

  @override
  bool shouldRepaint(covariant HarmonicFluidWavePainter oldDelegate) {
    return oldDelegate.wavePhase != wavePhase ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.waveHeight != waveHeight;
  }
}

// Alias para compatibilidad con DualWavePainter
typedef DualWavePainter = HarmonicFluidWavePainter;

/// Barra decorativa de agua serena animada en loop fluido
class AmbientWaveBar extends StatefulWidget {
  final double height;
  final Color? color;
  final Color? secondaryColor;
  final bool inverted;

  const AmbientWaveBar({
    super.key,
    this.height = 42.0,
    this.color,
    this.secondaryColor,
    this.inverted = false,
  });

  @override
  State<AmbientWaveBar> createState() => _AmbientWaveBarState();
}

class _AmbientWaveBarState extends State<AmbientWaveBar> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Ciclo pausado de ondulación de 7 segundos
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(double.infinity, widget.height),
          painter: HarmonicFluidWavePainter(
            wavePhase: _controller.value * 2 * math.pi,
            waveHeight: widget.height * 0.32,
            primaryColor: widget.color ?? RemansoTheme.scaffoldLinen,
            secondaryColor: widget.secondaryColor ?? RemansoTheme.surfaceStone.withOpacity(0.5),
            inverted: widget.inverted,
          ),
        );
      },
    );
  }
}

/// Contenedor con micro-interacción física al presionar (Sensación háptica y táctil)
class TactilePressCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleFactor;
  final BorderRadius? borderRadius;

  const TactilePressCard({
    super.key,
    required this.child,
    this.onTap,
    this.scaleFactor = 0.982,
    this.borderRadius,
  });

  @override
  State<TactilePressCard> createState() => _TactilePressCardState();
}

class _TactilePressCardState extends State<TactilePressCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
      reverseDuration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.scaleFactor).animate(
      CurvedAnimation(
        parent: _pressController,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeOutBack,
      ),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _pressController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _pressController.reverse();
  }

  void _onTapCancel() {
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            alignment: Alignment.center,
            child: widget.child,
          );
        },
      ),
    );
  }
}
