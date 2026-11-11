import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Identificadores de las paletas temáticas reales de Remanso
enum RemansoPaletteId {
  linoCalido, // Lino Cálido (Papel Crema & Bosque - Predeterminado)
  papiroOliva, // Papiro & Oliva (Sepia / Biblioteca Clásica)
  brumaNordica, // Bruma Nórdica (Niebla mineral, Rocío & Ciprés)
  nocheReposo, // Noche de Reposo (Carbón orgánico para vísperas y lectura nocturna)
}

/// Modelo de paleta temática de diseño editorial
class RemansoPalette {
  final RemansoPaletteId id;
  final String name;
  final String subtitle;
  final String description;
  final Brightness brightness;

  // Superficies
  final Color scaffold;
  final Color surfaceStone;
  final Color surfacePure;
  final Color surfaceElevated;

  // Acentos orgánicos
  final Color accentPrimary;
  final Color accentSage;
  final Color accentSageLight;
  final Color accentSecondary;
  final Color accentSecondaryLight;
  final Color accentLight;
  final Color accentLightSubtle;

  // Textos y bordes
  final Color textPrimary;
  final Color textMuted;
  final Color textSubtle;
  final Color borderSubtle;

  // Elementos de contraste coordinados
  final Color matteObsidian;
  final Color matteStoneDark;

  const RemansoPalette({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.description,
    required this.brightness,
    required this.scaffold,
    required this.surfaceStone,
    required this.surfacePure,
    required this.surfaceElevated,
    required this.accentPrimary,
    required this.accentSage,
    required this.accentSageLight,
    required this.accentSecondary,
    required this.accentSecondaryLight,
    required this.accentLight,
    required this.accentLightSubtle,
    required this.textPrimary,
    required this.textMuted,
    required this.textSubtle,
    required this.borderSubtle,
    required this.matteObsidian,
    required this.matteStoneDark,
  });

  bool get isDark => brightness == Brightness.dark;

  // --- PALETAS REALES CURADAS ---

  /// 1. Expand Obsidiana (Inspirado en el diseño minimalista y sereno de Expand: obsidiana profunda, acero azul y blanco puro)
  static const RemansoPalette linoCalido = RemansoPalette(
    id: RemansoPaletteId.linoCalido,
    name: 'Expand Obsidiana',
    subtitle: 'Obsidiana profunda, quietud y acero azul',
    description: 'Estética visual sobria, moderna y consistente. Un solo tono nocturno sosegado, tipografía geométrica limpia y reverencia ante Dios.',
    brightness: Brightness.dark,
    scaffold: Color(0xFF0D0F14), // Obsidiana profunda pura
    surfaceStone: Color(0xFF141820),
    surfacePure: Color(0xFF181D26), // Superficie de tarjeta limpia
    surfaceElevated: Color(0xFF1E2430),
    accentPrimary: Color(0xFF3B6882), // Acero azul sobrio estilo Expand
    accentSage: Color(0xFF3B6882),
    accentSageLight: Color(0xFF1E2C36),
    accentSecondary: Color(0xFF8E9BAE), // Plata serena
    accentSecondaryLight: Color(0xFF222B36),
    accentLight: Color(0xFF3B6882),
    accentLightSubtle: Color(0xFF18202A),
    textPrimary: Color(0xFFFFFFFF), // Blanco puro nítido
    textMuted: Color(0xFF9AA8BA), // Gris plata suave
    textSubtle: Color(0xFF63738A), // Gris atenuado
    borderSubtle: Color(0x1AFFFFFF), // Línea sutil arquitectónica
    matteObsidian: Color(0xFF0A0C10),
    matteStoneDark: Color(0xFF141820),
  );

  /// 2. Papiro & Oliva (Manuscrito y abadía con olivo silvestre)
  static const RemansoPalette papiroOliva = RemansoPalette(
    id: RemansoPaletteId.papiroOliva,
    name: 'Papiro & Oliva',
    subtitle: 'Pergamino sosegado, olivo y estudio bíblico',
    description: 'Tonalidades cálidas de manuscrito antiguo, madera pulida y hojas de olivo silvestre. Ideal para lectura prolongada y reflexiva.',
    brightness: Brightness.light,
    scaffold: Color(0xFFF4EFE6),
    surfaceStone: Color(0xFFEAE1D2),
    surfacePure: Color(0xFFFCFAF7),
    surfaceElevated: Color(0xFFF1E9DC),
    accentPrimary: Color(0xFF4C583E),
    accentSage: Color(0xFF6B785C),
    accentSageLight: Color(0xFFE2E7DB),
    accentSecondary: Color(0xFFB56A45),
    accentSecondaryLight: Color(0xFFF6ECE5),
    accentLight: Color(0xFFDFC59E),
    accentLightSubtle: Color(0xFFF7EFE3),
    textPrimary: Color(0xFF262019),
    textMuted: Color(0xFF675F53),
    textSubtle: Color(0xFF968D80),
    borderSubtle: Color(0x14262019),
    matteObsidian: Color(0xFF262019),
    matteStoneDark: Color(0xFFDFD5C4),
  );

  /// 3. Bruma Nórdica (Niebla alpina, piedra mineral y ciprés nórdico)
  static const RemansoPalette brumaNordica = RemansoPalette(
    id: RemansoPaletteId.brumaNordica,
    name: 'Bruma Nórdica',
    subtitle: 'Rocío del alba, pizarra y quietud fresca',
    description: 'Inspirado en la niebla matutina de montaña, piedra mineral y pino ciprés. Ofrece una claridad limpia, sosegada y luminosa.',
    brightness: Brightness.light,
    scaffold: Color(0xFFF3F5F4),
    surfaceStone: Color(0xFFE5EAE7),
    surfacePure: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFEDF2EF),
    accentPrimary: Color(0xFF2D4641),
    accentSage: Color(0xFF4B6963),
    accentSageLight: Color(0xFFD6E3DF),
    accentSecondary: Color(0xFFA86F60),
    accentSecondaryLight: Color(0xFFF5EBE8),
    accentLight: Color(0xFFBDCCC6),
    accentLightSubtle: Color(0xFFEBF1EE),
    textPrimary: Color(0xFF1B2321),
    textMuted: Color(0xFF556360),
    textSubtle: Color(0xFF889693),
    borderSubtle: Color(0x121B2321),
    matteObsidian: Color(0xFF1B2321),
    matteStoneDark: Color(0xFFDAE0DC),
  );

  /// 4. Noche de Reposo (Carbón orgánico para vísperas y oración nocturna)
  static const RemansoPalette nocheReposo = RemansoPalette(
    id: RemansoPaletteId.nocheReposo,
    name: 'Noche de Reposo',
    subtitle: 'Carbón orgánico para vísperas y oración nocturna',
    description: 'Modo oscuro editorial. Carbón lino cálido con tipografía en crema suave y salvia luminoso, diseñado para orar antes de dormir sin fatiga visual.',
    brightness: Brightness.dark,
    scaffold: Color(0xFF161815),
    surfaceStone: Color(0xFF21251F),
    surfacePure: Color(0xFF2B3029),
    surfaceElevated: Color(0xFF242822),
    accentPrimary: Color(0xFF9BB799),
    accentSage: Color(0xFFB1C8AF),
    accentSageLight: Color(0xFF353C33),
    accentSecondary: Color(0xFFDE9E7D),
    accentSecondaryLight: Color(0xFF3E322A),
    accentLight: Color(0xFFD8C2A0),
    accentLightSubtle: Color(0xFF2F2B24),
    textPrimary: Color(0xFFEDE8DD),
    textMuted: Color(0xFFA8ADA3),
    textSubtle: Color(0xFF757A71),
    borderSubtle: Color(0x24FFFFFF),
    matteObsidian: Color(0xFF0F110E),
    matteStoneDark: Color(0xFF2B3029),
  );

  static List<RemansoPalette> get all => [
    linoCalido,
    papiroOliva,
    brumaNordica,
    nocheReposo,
  ];

  static RemansoPalette fromId(String? idName) {
    if (idName == null) return linoCalido;
    return all.firstWhere((p) => p.id.name == idName, orElse: () => linoCalido);
  }
}

/// Remanso Design System & Dynamic Theme Manager
/// Conecta la paleta activa en tiempo real con todas las pantallas de la app.
class RemansoTheme {
  /// Paleta activa global
  static RemansoPalette activePalette = RemansoPalette.linoCalido;

  // --- Getters Dinámicos de Color ---
  static Color get scaffoldLinen => activePalette.scaffold;
  static Color get surfaceStone => activePalette.surfaceStone;
  static Color get surfacePure => activePalette.surfacePure;
  static Color get surfaceElevated => activePalette.surfaceElevated;

  static Color get accentForest => activePalette.accentPrimary;
  static Color get accentSage => activePalette.accentSage;
  static Color get accentSageLight => activePalette.accentSageLight;
  static Color get accentTerracotta => activePalette.accentSecondary;
  static Color get accentTerracottaLight => activePalette.accentSecondaryLight;
  static Color get accentSecondaryLight => activePalette.accentSecondaryLight;
  static Color get accentSand => activePalette.accentLight;
  static Color get accentSandLight => activePalette.accentLightSubtle;

  static Color get textCharcoal => activePalette.textPrimary;
  static Color get textMuted => activePalette.textMuted;
  static Color get textSubtle => activePalette.textSubtle;
  static Color get borderSubtle => activePalette.borderSubtle;

  static Color get matteObsidian => activePalette.matteObsidian;
  static Color get matteStoneDark => activePalette.matteStoneDark;
  static Color get goldAccentLight => activePalette.accentLight;

  // --- Sombras Orgánicas y Cálidas ---
  static List<BoxShadow> get organicShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 18,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> get subtleShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.025),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get darkGlowShadow => [];
  static List<BoxShadow> get goldGlowShadow => [];

  // --- Geometría y Bordes Sobrios y Modernos Estilo Expand ---
  static final BorderRadius cardRadius = BorderRadius.circular(14);
  static final BorderRadius stoneRadius = BorderRadius.circular(12);
  static final BorderRadius buttonRadius = BorderRadius.circular(22);
  static final BorderRadius inputRadius = BorderRadius.circular(12);
  static final BorderRadius badgeRadius = BorderRadius.circular(6);

  // --- Tipografía Única y Coherente (Plus Jakarta Sans en toda la app estilo Expand) ---
  static const List<String> sansFallback = [
    'Plus Jakarta Sans',
    'Inter',
    'Segoe UI',
    'Roboto',
    'sans-serif',
  ];

  static TextStyle displayFont({
    double fontSize = 24,
    FontWeight fontWeight = FontWeight.w600,
    Color? color,
    double height = 1.3,
    double letterSpacing = -0.3,
    FontStyle fontStyle = FontStyle.normal,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? textCharcoal,
      height: height,
      letterSpacing: letterSpacing,
      fontStyle: fontStyle,
    ).copyWith(fontFamilyFallback: sansFallback);
  }

  static TextStyle readingFont({
    double fontSize = 15,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
    double height = 1.6,
    double letterSpacing = 0.1,
    FontStyle fontStyle = FontStyle.normal,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? textCharcoal,
      height: height,
      letterSpacing: letterSpacing,
      fontStyle: fontStyle,
    ).copyWith(fontFamilyFallback: sansFallback);
  }

  static TextStyle uiFont({
    double fontSize = 13,
    FontWeight fontWeight = FontWeight.w500,
    Color? color,
    double height = 1.4,
    double letterSpacing = 0.2,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? textMuted,
      height: height,
      letterSpacing: letterSpacing,
    ).copyWith(fontFamilyFallback: sansFallback);
  }

  static TextStyle labelFont({
    double fontSize = 10,
    FontWeight fontWeight = FontWeight.w700,
    Color? color,
    double letterSpacing = 1.6,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? accentForest,
      letterSpacing: letterSpacing,
    ).copyWith(fontFamilyFallback: sansFallback);
  }

  // --- ThemeData Dinámico Material 3 ---
  static ThemeData get themeData {
    final palette = activePalette;
    final isDark = palette.isDark;

    final textTheme = TextTheme(
      displayLarge: displayFont(fontSize: 36, letterSpacing: -0.8),
      displayMedium: displayFont(fontSize: 30, letterSpacing: -0.5),
      displaySmall: displayFont(fontSize: 24),
      headlineMedium: displayFont(fontSize: 21, fontWeight: FontWeight.w600),
      headlineSmall: displayFont(fontSize: 19, fontWeight: FontWeight.w600),
      bodyLarge: readingFont(fontSize: 17, height: 1.7),
      bodyMedium: uiFont(fontSize: 14, color: palette.textMuted, height: 1.55),
      bodySmall: uiFont(fontSize: 12, color: palette.textSubtle),
      labelLarge: labelFont(fontSize: 12, color: palette.accentPrimary),
      labelMedium: labelFont(fontSize: 10.5, color: palette.textSubtle),
      labelSmall: labelFont(fontSize: 9.5, color: palette.textSubtle),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: palette.brightness,
      scaffoldBackgroundColor: palette.scaffold,
      colorScheme: ColorScheme(
        brightness: palette.brightness,
        primary: palette.accentPrimary,
        onPrimary: isDark ? const Color(0xFF161815) : palette.surfacePure,
        secondary: palette.accentSecondary,
        onSecondary: isDark ? const Color(0xFF161815) : palette.surfacePure,
        tertiary: palette.accentLight,
        onTertiary: palette.textPrimary,
        error: const Color(0xFFBA1A1A),
        onError: Colors.white,
        surface: palette.surfacePure,
        onSurface: palette.textPrimary,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: palette.scaffold,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: palette.textPrimary),
        titleTextStyle: displayFont(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: palette.textPrimary,
          letterSpacing: 0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: palette.surfacePure,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: cardRadius,
          side: BorderSide(color: palette.borderSubtle, width: 1),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: palette.borderSubtle,
        thickness: 1,
        space: 24,
      ),
    );
  }

  // Alias para retrocompatibilidad
  static ThemeData get lightTheme => themeData;
}

// Alias para retrocompatibilidad
typedef SelahTheme = RemansoTheme;
