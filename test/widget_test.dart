import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:remanso/data/devotional_repository.dart';
import 'package:remanso/main.dart';
import 'package:remanso/models/devotional_models.dart';
import 'package:remanso/theme/remanso_theme.dart';
import 'package:remanso/widgets/editorial_biblical_widgets.dart';
import 'package:remanso/widgets/remanso_logo.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('DevotionalRepository Tests', () {
    test('Repository initializes with default courses and days', () async {
      final repo = DevotionalRepository();
      await repo.initialize();

      expect(repo.courses.isNotEmpty, true);
      expect(repo.courses.length, greaterThanOrEqualTo(2));

      // Verificar Curso 1: Habitar en la Quietud
      final course1 = repo.courses.firstWhere((c) => c.id == 'habitar-en-la-quietud');
      expect(course1.days.length, 5);
      expect(course1.author.name, contains('Marcos y Sofía'));

      // Verificar Curso 2: Ojos que Ven
      final course2 = repo.courses.firstWhere((c) => c.id == 'ojos-que-ven-fe-fotografia');
      expect(course2.days.length, 4);
      expect(course2.author.name, contains('Mateo V. Valenzuela'));

      // Verificar Curso 3: Caminar sin Prisa
      final course3 = repo.courses.firstWhere((c) => c.id == 'caminar-sin-prisa-eclesiastes');
      expect(course3.days.length, 3);
    });

    test('Saving journal entry updates entries and streak', () async {
      final repo = DevotionalRepository();
      await repo.initialize();

      final initialEntriesCount = repo.journalEntries.length;
      final today = repo.todayDevotional;

      await repo.completeDayAndSaveJournal(
        day: today,
        userReflection: 'Mi oración de paz en la mañana.',
      );

      expect(repo.journalEntries.length, initialEntriesCount + 1);
      expect(repo.journalEntries.first.userReflection, 'Mi oración de paz en la mañana.');
      expect(repo.isDayCompleted(today.id), true);

      // Recompletar el mismo día actualiza la entrada sin duplicar en almacenamiento
      await repo.completeDayAndSaveJournal(
        day: today,
        userReflection: 'Mi oración actualizada.',
      );
      expect(repo.journalEntries.length, initialEntriesCount + 1);
      expect(repo.journalEntries.first.userReflection, 'Mi oración actualizada.');
    });

    test('Search journal finds relevant entries', () async {
      final repo = DevotionalRepository();
      await repo.initialize();

      await repo.completeDayAndSaveJournal(
        day: repo.todayDevotional,
        userReflection: 'Aunque ande en valle de sombras de muerte, no temeré mal alguno.',
      );

      final results = repo.searchJournal('sombras');
      expect(results.isNotEmpty, true);
    });

    test('Bible version can be selected and persists', () async {
      final repo = DevotionalRepository();
      await repo.initialize();

      expect(repo.preferredBibleVersion, BibleVersion.rvr1960);
      await repo.setPreferredBibleVersion(BibleVersion.ntv);
      expect(repo.preferredBibleVersion, BibleVersion.ntv);
      await repo.setPreferredBibleVersion(BibleVersion.vbl);
      expect(repo.preferredBibleVersion, BibleVersion.vbl);

      final day1 = repo.courses.first.days.first;
      expect(day1.getVerse(BibleVersion.vbl).isNotEmpty, true);
      expect(day1.getVerse(BibleVersion.rvr1960).isNotEmpty, true);
      expect(day1.getVerse(BibleVersion.nvi).isNotEmpty, true);
      expect(day1.getVerse(BibleVersion.ntv).isNotEmpty, true);
    });

    test('Theme palettes can be selected, have distinct colors, and persist', () async {
      final repo = DevotionalRepository();
      await repo.initialize();

      expect(repo.currentThemePalette.id, RemansoPaletteId.linoCalido);
      expect(RemansoPalette.all.length, 4);

      // Cambiar a Papiro & Oliva
      await repo.setThemePalette(RemansoPalette.papiroOliva);
      expect(repo.currentThemePalette.id, RemansoPaletteId.papiroOliva);
      expect(RemansoTheme.scaffoldLinen, RemansoPalette.papiroOliva.scaffold);

      // Cambiar a Bruma Nórdica
      await repo.setThemePalette(RemansoPalette.brumaNordica);
      expect(repo.currentThemePalette.id, RemansoPaletteId.brumaNordica);
      expect(RemansoTheme.scaffoldLinen, RemansoPalette.brumaNordica.scaffold);

      // Cambiar a Noche de Reposo (Modo Oscuro Editorial)
      await repo.setThemePalette(RemansoPalette.nocheReposo);
      expect(repo.currentThemePalette.id, RemansoPaletteId.nocheReposo);
      expect(repo.currentThemePalette.isDark, true);
      expect(RemansoTheme.activePalette.isDark, true);

      // Revertir a Lino Cálido
      await repo.setThemePalette(RemansoPalette.linoCalido);
      expect(repo.currentThemePalette.id, RemansoPaletteId.linoCalido);
    });
  });

  group('Models Serialization Tests', () {
    test('PhotoMetadata serialization round-trip', () {
      const meta = PhotoMetadata(
        camera: 'Fujifilm X-T5',
        lens: '35mm f/1.4',
        focalLength: '35mm',
        aperture: 'f/2.0',
        shutterSpeed: '1/250s',
        iso: 'ISO 160',
        location: 'Patagonia',
        timeOfDay: 'Amanecer',
        spiritualBehindTheLens: 'Luz rasante.',
        technicalBehindTheLens: 'Manual.',
        imageUrl: 'https://example.com/photo.jpg',
      );

      final json = meta.toJson();
      final fromJson = PhotoMetadata.fromJson(json);

      expect(fromJson.camera, 'Fujifilm X-T5');
      expect(fromJson.aperture, 'f/2.0');
      expect(fromJson.location, 'Patagonia');
    });

    test('BiblicalRootWord serialization and round-trip', () {
      const root = BiblicalRootWord(
        originalScript: 'מְנוּחָה',
        transliteration: 'Menujáh',
        language: 'Hebreo',
        strongCode: 'H4496',
        literalMeaning: 'Aguas de reposo / Descanso que restaura',
        spiritualInsight: 'Reposo interior que aquieta la fatiga del alma.',
      );

      final json = root.toJson();
      final fromJson = BiblicalRootWord.fromJson(json);

      expect(fromJson.originalScript, 'מְנוּחָה');
      expect(fromJson.transliteration, 'Menujáh');
      expect(fromJson.language, 'Hebreo');
      expect(fromJson.strongCode, 'H4496');
      expect(fromJson.literalMeaning, contains('Aguas de reposo'));
    });

    test('All courses and days have Hebrew or Greek roots and Christological cross-references', () async {
      final repo = DevotionalRepository();
      await repo.initialize();

      for (final course in repo.courses) {
        for (final day in course.days) {
          expect(day.rootWord, isNotNull, reason: '${day.id} should have a rootWord');
          expect(day.rootWord!.originalScript.isNotEmpty, true);
          expect(day.rootWord!.transliteration.isNotEmpty, true);
          expect(day.rootWord!.strongCode.isNotEmpty, true);
          expect(day.crossReference, isNotNull, reason: '${day.id} should have a crossReference');
          expect(day.crossReference!.isNotEmpty, true);
        }
      }
    });
  });

  group('Editorial Biblical Widgets Tests', () {
    testWidgets('EditorialDropCapText renders illuminated drop cap', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EditorialDropCapText(
              text: 'La luz nunca es tan elocuente como en el desierto.',
            ),
          ),
        ),
      );

      expect(find.text('L'), findsOneWidget); // Drop cap
      expect(find.text('a luz nunca es tan elocuente como en el desierto.'), findsOneWidget);
    });

    testWidgets('BiblicalRootCard renders and expands to show spiritual insight', (WidgetTester tester) async {
      const root = BiblicalRootWord(
        originalScript: 'רָפָה',
        transliteration: 'Raphah',
        language: 'Hebreo',
        strongCode: 'H7503',
        literalMeaning: 'Soltar las manos / Dejar caer las armas',
        spiritualInsight: 'Soltar las riendas del control que nos desgastan para que Dios sea Dios.',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BiblicalRootCard(rootWord: root),
          ),
        ),
      );

      expect(find.text('רָפָה'), findsOneWidget);
      expect(find.text('«Raphah»'), findsOneWidget);
      expect(find.text('H7503'), findsOneWidget);

      // Tocar para expandir
      await tester.tap(find.byType(BiblicalRootCard));
      await tester.pump(const Duration(milliseconds: 350));

      expect(
        find.text('Soltar las riendas del control que nos desgastan para que Dios sea Dios.'),
        findsOneWidget,
      );
    });

    testWidgets('CanonicalCrossReferenceCard renders biblical connection to Christ', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CanonicalCrossReferenceCard(
              crossReference: 'Juan 10:11 — Jesús es el Buen Pastor.',
            ),
          ),
        ),
      );

      expect(find.text('CONEXIÓN CANÓNICA • EN LA HISTORIA DE DIOS'), findsOneWidget);
      expect(find.text('Juan 10:11 — Jesús es el Buen Pastor.'), findsOneWidget);
    });

    testWidgets('LectioDivinaGuideBar renders all 3 stages', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LectioDivinaGuideBar(activeIndex: 1),
          ),
        ),
      );

      expect(find.text('Mirada'), findsOneWidget);
      expect(find.text('Palabra'), findsOneWidget);
      expect(find.text('Oración'), findsOneWidget);
    });

    testWidgets('RemansoLogo renders in all variants (iconOnly, horizontal, vertical)', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                RemansoLogo(size: 40, variant: RemansoLogoVariant.iconOnly),
                RemansoLogo(size: 50, variant: RemansoLogoVariant.horizontal),
                RemansoLogo(size: 60, variant: RemansoLogoVariant.vertical),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(RemansoLogo), findsNWidgets(3));
      expect(find.text('REMANSO'), findsNWidgets(2));
      expect(find.text('AGUAS DE REPOSO'), findsNWidgets(2));
    });
  });

  group('Widget Smoke Test & App Startup Verification', () {
    testWidgets('Renders Remanso initial wave screen and verifies app opens properly', (WidgetTester tester) async {
      final repo = DevotionalRepository();
      await repo.initialize();

      await tester.pumpWidget(const RemansoApp());
      await tester.pump(const Duration(milliseconds: 100));

      // 1. Verifica elementos de la pantalla de bienvenida / ola contemplativa
      expect(find.text('Entrar al Remanso'), findsOneWidget);
      expect(find.text('REMANSO DEL DÍA'), findsOneWidget);
      expect(find.byType(RemansoLogo), findsWidgets);

      // 2. Tocar para ingresar a la experiencia principal
      await tester.tap(find.text('Entrar al Remanso'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // 3. Verifica que la app abrió exitosamente y está en el Home
      expect(find.text('Remanso'), findsWidgets);
      expect(find.text('Aguas de reposo para el camino diario'), findsOneWidget);
      expect(find.text('Orden Diario'), findsOneWidget); // Pestaña activa con etiqueta
      expect(find.byIcon(Icons.auto_stories_outlined), findsOneWidget); // Icono pestaña Rutas
      expect(find.byIcon(Icons.edit_note_rounded), findsOneWidget); // Icono pestaña Mi Diario
      expect(find.byType(RemansoLogo), findsWidgets); // Logo visible en el header del Home
    });
  });
}
