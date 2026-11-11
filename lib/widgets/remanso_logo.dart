import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/remanso_theme.dart';

/// Modo de visualización del logo
enum RemansoLogoVariant {
  iconOnly,
  vertical,
  horizontal,
}

/// Logo Oficial de Remanso:
/// Síntesis geométrica y poética de las aguas de reposo (Salmo 23:2)
/// y la mirada contemplativa (la luz del alba / sol sobre el horizonte calmo).
class RemansoLogo extends StatelessWidget {
  final double size;
  final RemansoLogoVariant variant;
  final Color? surfaceColor;
  final Color? waveColor;
  final Color? sunColor;
  final Color? textColor;
  final bool showSubtitle;

  const RemansoLogo({
    super.key,
    this.size = 56,
    this.variant = RemansoLogoVariant.iconOnly,
    this.surfaceColor,
    this.waveColor,
    this.sunColor,
    this.textColor,
    this.showSubtitle = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSurface = surfaceColor ?? RemansoTheme.surfaceStone;
    final effectiveWave = waveColor ?? RemansoTheme.accentForest;
    final effectiveSun = sunColor ?? RemansoTheme.accentTerracotta;
    final effectiveText = textColor ?? RemansoTheme.textCharcoal;

    final emblem = SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RemansoEmblemPainter(
          surfaceColor: effectiveSurface,
          waveColor: effectiveWave,
          sunColor: effectiveSun,
        ),
      ),
    );

    switch (variant) {
      case RemansoLogoVariant.iconOnly:
        return emblem;

      case RemansoLogoVariant.horizontal:
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            emblem,
            const SizedBox(width: 14),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'REMANSO',
                  style: RemansoTheme.displayFont(
                    fontSize: size * 0.44,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 3.5,
                    color: effectiveText,
                  ),
                ),
                if (showSubtitle) ...[
                  const SizedBox(height: 2),
                  Text(
                    'AGUAS DE REPOSO',
                    style: RemansoTheme.labelFont(
                      fontSize: (size * 0.17).clamp(9.0, 12.0),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2.2,
                      color: RemansoTheme.accentTerracotta,
                    ),
                  ),
                ],
              ],
            ),
          ],
        );

      case RemansoLogoVariant.vertical:
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            emblem,
            SizedBox(height: size * 0.2),
            Text(
              'REMANSO',
              style: RemansoTheme.displayFont(
                fontSize: size * 0.38,
                fontWeight: FontWeight.w500,
                letterSpacing: 4.0,
                color: effectiveText,
              ),
            ),
            if (showSubtitle) ...[
              const SizedBox(height: 4),
              Text(
                'AGUAS DE REPOSO',
                style: RemansoTheme.labelFont(
                  fontSize: (size * 0.16).clamp(9.0, 13.0),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.5,
                  color: RemansoTheme.accentTerracotta,
                ),
              ),
            ],
          ],
        );
    }
  }
}

/// Pintor vectorial de alta precisión del emblema de Remanso
class _RemansoEmblemPainter extends CustomPainter {
  final Color surfaceColor;
  final Color waveColor;
  final Color sunColor;

  _RemansoEmblemPainter({
    required this.surfaceColor,
    required this.waveColor,
    required this.sunColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    if (w <= 0 || h <= 0) return;

    final center = Offset(w / 2, h / 2);
    final radius = math.min(w, h) / 2;

    // 1. Superficie de fondo orgánica (círculo lino suave o piedra)
    final bgPaint = Paint()
      ..color = surfaceColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // Borde muy sutil
    final borderPaint = Paint()
      ..color = waveColor.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.0, w * 0.02);
    canvas.drawCircle(center, radius - borderPaint.strokeWidth / 2, borderPaint);

    // 2. Sol del alba / Luz de contemplación (círculo terracota suspendido)
    final sunRadius = radius * 0.22;
    final sunCenter = Offset(w * 0.52, h * 0.35);
    final sunPaint = Paint()
      ..color = sunColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(sunCenter, sunRadius, sunPaint);

    // 3. Onda armónica serena superior (Aguas de reposo)
    final waveStroke = math.max(1.8, w * 0.055);
    final wave1Paint = Paint()
      ..color = waveColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = waveStroke;

    final path1 = Path();
    final startX = w * 0.24;
    final endX = w * 0.76;
    final yBase1 = h * 0.58;

    path1.moveTo(startX, yBase1);
    path1.cubicTo(
      w * 0.38,
      yBase1 - h * 0.12,
      w * 0.58,
      yBase1 + h * 0.10,
      endX,
      yBase1 - h * 0.04,
    );
    canvas.drawPath(path1, wave1Paint);

    // 4. Onda armónica inferior secundaria (Profundidad en calma)
    final wave2Paint = Paint()
      ..color = waveColor.withOpacity(0.45)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = waveStroke * 0.8;

    final path2 = Path();
    final startX2 = w * 0.30;
    final endX2 = w * 0.70;
    final yBase2 = h * 0.70;

    path2.moveTo(startX2, yBase2);
    path2.cubicTo(
      w * 0.42,
      yBase2 - h * 0.07,
      w * 0.58,
      yBase2 + h * 0.06,
      endX2,
      yBase2 - h * 0.02,
    );
    canvas.drawPath(path2, wave2Paint);
  }

  @override
  bool shouldRepaint(covariant _RemansoEmblemPainter oldDelegate) {
    return oldDelegate.surfaceColor != surfaceColor ||
        oldDelegate.waveColor != waveColor ||
        oldDelegate.sunColor != sunColor;
  }
}
