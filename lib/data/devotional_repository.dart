import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/devotional_models.dart';
import '../theme/remanso_theme.dart';

/// Repositorio local central de Remanso.
/// Maneja cursos, devocionales diarios, persistencia del diario,
/// preferencia de versión bíblica, sistema de temas y estado de completitud.
class DevotionalRepository extends ChangeNotifier {
  static final DevotionalRepository _instance =
      DevotionalRepository._internal();
  factory DevotionalRepository() => _instance;
  DevotionalRepository._internal();

  // Claves de persistencia SharedPreferences
  static const String _prefActiveCourseId = 'remanso_active_course_id';
  static const String _prefCompletedDays = 'remanso_completed_days_set';
  static const String _prefJournalEntries = 'remanso_journal_entries_json';
  static const String _prefStreakCount = 'remanso_streak_count';
  static const String _prefLastCompletedDate = 'remanso_last_completed_date';
  static const String _prefPreferredBibleVersion =
      'remanso_preferred_bible_version';
  static const String _prefActiveThemePalette = 'remanso_active_theme_palette';

  List<DevotionalCourse> _courses = [];
  String _activeCourseId = 'habitar-en-la-quietud';
  int _activeDayIndex = 0; // Índice de día actualmente seleccionado
  final Set<String> _completedDayIds = {};
  final List<JournalEntry> _journalEntries = [];
  int _streakCount =
      0; // Comienza en 0 para un usuario que recién instala la app
  DateTime? _lastCompletedDate;
  BibleVersion _preferredBibleVersion = BibleVersion.rvr1960;
  RemansoPalette _currentThemePalette = RemansoPalette.linoCalido;
  bool _isInitialized = false;

  // Getters
  bool get isInitialized => _isInitialized;
  List<DevotionalCourse> get courses => List.unmodifiable(_courses);
  String get activeCourseId => _activeCourseId;
  int get activeDayIndex => _activeDayIndex;
  Set<String> get completedDayIds => Set.unmodifiable(_completedDayIds);
  List<JournalEntry> get journalEntries => List.unmodifiable(_journalEntries);
  int get streakCount => _streakCount;
  BibleVersion get preferredBibleVersion => _preferredBibleVersion;
  RemansoPalette get currentThemePalette => _currentThemePalette;

  DevotionalCourse get activeCourse {
    return _courses.firstWhere(
      (c) => c.id == _activeCourseId,
      orElse: () =>
          _courses.isNotEmpty ? _courses.first : _defaultFallbackCourse,
    );
  }

  DevotionalDay get todayDevotional {
    final course = activeCourse;
    if (course.days.isEmpty) {
      return _defaultFallbackDay;
    }
    final safeIndex = _activeDayIndex.clamp(0, course.days.length - 1);
    return course.days[safeIndex];
  }

  /// Inicializa los datos y carga la persistencia local
  Future<void> initialize() async {
    if (_isInitialized) return;

    // 1. Cargar catálogo base de cursos ricos en contenido multi-versión
    _courses = _buildDefaultCourses();

    // 2. Cargar estado de persistencia local
    try {
      final prefs = await SharedPreferences.getInstance();

      final savedCourseId = prefs.getString(_prefActiveCourseId);
      if (savedCourseId != null && _courses.any((c) => c.id == savedCourseId)) {
        _activeCourseId = savedCourseId;
      }

      final savedBibleCode = prefs.getString(_prefPreferredBibleVersion);
      if (savedBibleCode != null) {
        _preferredBibleVersion = BibleVersion.fromCode(savedBibleCode);
      }

      final savedPaletteId = prefs.getString(_prefActiveThemePalette);
      if (savedPaletteId != null) {
        _currentThemePalette = RemansoPalette.fromId(savedPaletteId);
        RemansoTheme.activePalette = _currentThemePalette;
      }

      final savedCompletedDays = prefs.getStringList(_prefCompletedDays);
      if (savedCompletedDays != null) {
        _completedDayIds.addAll(savedCompletedDays);
      } else {
        // Nueva instalación limpia: ningún día pre-completado, el usuario comienza fresco en el Día 1
        _completedDayIds.clear();
      }

      final savedStreak = prefs.getInt(_prefStreakCount);
      if (savedStreak != null) {
        _streakCount = savedStreak;
      } else {
        _streakCount = 0;
      }

      final lastDateStr = prefs.getString(_prefLastCompletedDate);
      if (lastDateStr != null) {
        _lastCompletedDate = DateTime.tryParse(lastDateStr);
        if (_lastCompletedDate != null) {
          final now = DateTime.now();
          final todayMidnight = DateTime(now.year, now.month, now.day);
          final lastMidnight = DateTime(
            _lastCompletedDate!.year,
            _lastCompletedDate!.month,
            _lastCompletedDate!.day,
          );
          final diff = todayMidnight.difference(lastMidnight).inDays;
          // Si pasaron más de 1 día (no ayer ni hoy), la racha se reinicia
          if (diff > 1) {
            _streakCount = 0;
          }
        }
      }

      final savedJournalJson = prefs.getString(_prefJournalEntries);
      if (savedJournalJson != null) {
        final List<dynamic> decoded =
            jsonDecode(savedJournalJson) as List<dynamic>;
        _journalEntries.clear();
        for (final item in decoded) {
          _journalEntries.add(
            JournalEntry.fromJson(item as Map<String, dynamic>),
          );
        }
      } else {
        _journalEntries.clear();
      }

      _calculateActiveDayIndex();
    } catch (e) {
      debugPrint('Remanso Repo - Advertencia de carga local: $e');
    }

    _isInitialized = true;
    notifyListeners();
  }

  void _calculateActiveDayIndex() {
    final days = activeCourse.days;
    for (int i = 0; i < days.length; i++) {
      if (!_completedDayIds.contains(days[i].id)) {
        _activeDayIndex = i;
        return;
      }
    }
    _activeDayIndex = days.isEmpty ? 0 : days.length - 1;
  }

  /// Cambia la versión de la Biblia preferida de forma reactiva en toda la app
  Future<void> setPreferredBibleVersion(BibleVersion version) async {
    if (_preferredBibleVersion == version) return;
    _preferredBibleVersion = version;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefPreferredBibleVersion, version.code);
    } catch (e) {
      debugPrint('Remanso Repo - Error guardando versión bíblica: $e');
    }
  }

  /// Cambia la paleta temática editorial de forma reactiva en toda la app
  Future<void> setThemePalette(RemansoPalette palette) async {
    if (_currentThemePalette.id == palette.id) return;
    _currentThemePalette = palette;
    RemansoTheme.activePalette = palette;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefActiveThemePalette, palette.id.name);
    } catch (e) {
      debugPrint('Remanso Repo - Error guardando paleta temática: $e');
    }
  }

  /// Cambia el curso activo
  Future<void> setActiveCourse(String courseId) async {
    if (_activeCourseId == courseId) return;
    _activeCourseId = courseId;
    _calculateActiveDayIndex();
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefActiveCourseId, courseId);
    } catch (_) {}
  }

  /// Selecciona un día específico para visualizar
  void setActiveDayIndex(int index) {
    if (_activeDayIndex != index &&
        index >= 0 &&
        index < activeCourse.days.length) {
      _activeDayIndex = index;
      notifyListeners();
    }
  }

  /// Verifica si un día específico está completado
  bool isDayCompleted(String dayId) {
    return _completedDayIds.contains(dayId);
  }

  /// Calcula el progreso (0.0 a 1.0) de un curso dado
  double getCourseProgress(String courseId) {
    final course = _courses.firstWhere(
      (c) => c.id == courseId,
      orElse: () => _defaultFallbackCourse,
    );
    if (course.days.isEmpty) return 0.0;
    int completedCount = 0;
    for (final day in course.days) {
      if (_completedDayIds.contains(day.id)) {
        completedCount++;
      }
    }
    return completedCount / course.days.length;
  }

  /// Completa un día devocional y guarda/actualiza la nota en el diario local
  Future<void> completeDayAndSaveJournal({
    required DevotionalDay day,
    required String userReflection,
  }) async {
    final dayId = day.id;
    _completedDayIds.add(dayId);

    final reflection = userReflection.trim().isEmpty
        ? 'Completé este devocional en silencio y meditación personal.'
        : userReflection.trim();

    // Comprobar si ya existía una entrada para este día y curso (evita duplicados)
    final existingIndex = _journalEntries.indexWhere(
      (e) => e.courseId == day.courseId && e.dayNumber == day.dayNumber,
    );

    if (existingIndex >= 0) {
      final old = _journalEntries[existingIndex];
      _journalEntries[existingIndex] = JournalEntry(
        id: old.id,
        courseId: old.courseId,
        courseTitle: old.courseTitle,
        dayNumber: old.dayNumber,
        dayTitle: old.dayTitle,
        scriptureReference:
            '${day.scriptureVerse} (${_preferredBibleVersion.code})',
        photoThumbnailUrl: day.photo.imageUrl,
        userReflection: reflection,
        timestamp: DateTime.now(),
      );
    } else {
      final entry = JournalEntry(
        id: 'journal-${DateTime.now().millisecondsSinceEpoch}',
        courseId: day.courseId,
        courseTitle: activeCourse.title,
        dayNumber: day.dayNumber,
        dayTitle: day.title,
        scriptureReference:
            '${day.scriptureVerse} (${_preferredBibleVersion.code})',
        photoThumbnailUrl: day.photo.imageUrl,
        userReflection: reflection,
        timestamp: DateTime.now(),
      );
      _journalEntries.insert(0, entry);
    }

    // Actualización lógica precisa de racha por días calendario
    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);

    if (_lastCompletedDate == null) {
      _streakCount = 1;
      _lastCompletedDate = now;
    } else {
      final lastMidnight = DateTime(
        _lastCompletedDate!.year,
        _lastCompletedDate!.month,
        _lastCompletedDate!.day,
      );
      final differenceInDays = todayMidnight.difference(lastMidnight).inDays;

      if (differenceInDays == 1) {
        // Completó ayer: racha continua
        _streakCount += 1;
        _lastCompletedDate = now;
      } else if (differenceInDays > 1) {
        // Rompió la racha al saltarse uno o más días: reiniciar racha en 1
        _streakCount = 1;
        _lastCompletedDate = now;
      } else if (differenceInDays == 0 && _streakCount == 0) {
        _streakCount = 1;
        _lastCompletedDate = now;
      }
    }

    notifyListeners();

    // Persistir
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefCompletedDays, _completedDayIds.toList());
      await prefs.setInt(_prefStreakCount, _streakCount);
      await prefs.setString(_prefLastCompletedDate, now.toIso8601String());

      final encodedJournal = jsonEncode(
        _journalEntries.map((e) => e.toJson()).toList(),
      );
      await prefs.setString(_prefJournalEntries, encodedJournal);
    } catch (e) {
      debugPrint('Remanso Repo - Error persistiendo devocional: $e');
    }
  }

  /// Eliminar una entrada de diario
  Future<void> deleteJournalEntry(String entryId) async {
    _journalEntries.removeWhere((e) => e.id == entryId);
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(
        _journalEntries.map((e) => e.toJson()).toList(),
      );
      await prefs.setString(_prefJournalEntries, encoded);
    } catch (_) {}
  }

  /// Buscar entradas de diario por texto o pasaje
  List<JournalEntry> searchJournal(String query) {
    if (query.trim().isEmpty) return _journalEntries;
    final clean = query.toLowerCase().trim();
    return _journalEntries.where((e) {
      return e.userReflection.toLowerCase().contains(clean) ||
          e.dayTitle.toLowerCase().contains(clean) ||
          e.scriptureReference.toLowerCase().contains(clean) ||
          e.courseTitle.toLowerCase().contains(clean);
    }).toList();
  }

  /// Facilidad de extensión: Inyectar un curso nuevo desde JSON
  void importCourseFromJson(String jsonString) {
    try {
      final Map<String, dynamic> decoded =
          jsonDecode(jsonString) as Map<String, dynamic>;
      final newCourse = DevotionalCourse.fromJson(decoded);
      _courses.add(newCourse);
      notifyListeners();
    } catch (e) {
      debugPrint('Remanso Repo - Error importando curso JSON: $e');
    }
  }

  // --- Datos Base Curados de Alta Calidad Editorial (4 Versiones Bíblicas Reales) ---
  static List<DevotionalCourse> _buildDefaultCourses() {
    return [
      // CURSO 1: Habitar en la Quietud
      const DevotionalCourse(
        id: 'habitar-en-la-quietud',
        title: 'Habitar en la Quietud',
        subtitle: '5 días en los Salmos del Desierto',
        category: 'Salmos & Quietud',
        description: 'Una travesía contemplativa de 5 días por la poesía hebrea de los Salmos, descubriendo cómo Dios se revela no en la prisa ni en el ruido ensordecedor del mundo moderno, sino en la calma que aquieta los pensamientos y abre los ojos del corazón.',
        coverImageUrl: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=1200&q=80',
        totalDays: 5,
        author: AuthorProfile(
          id: 'author-marcos-sofia',
          name: 'Pr. Marcos y Sofía Benítez',
          role: 'Mentores de Vida Contemplativa & Pastores',
          bio: 'Marcos y Sofía llevan más de 18 años acompañando comunidades en retiros de silencio y formación espiritual en las sierras. Su pasión es redescubrir las disciplinas espirituales clásicas y la poesía bíblica para el creyente contemporáneo.',
          avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80',
        ),
        days: [
          // Día 1
          DevotionalDay(
            id: 'habitar-dia-1',
            courseId: 'habitar-en-la-quietud',
            dayNumber: 1,
            title: 'El valle de sombras y la luz rasante',
            scriptureVerse: 'Salmo 23:1-4',
            verseTranslations: {
              BibleVersion.rvr1960: 'Jehová es mi pastor; nada me faltará. En lugares de delicados pastos me hará descansar; junto a aguas de reposo me pastoreará. Confortará mi alma; me guiará por sendas de justicia por amor de su nombre. Aunque ande en valle de sombra de muerte, no temeré mal alguno, porque tú estarás conmigo; tu vara y tu cayado me infundirán aliento.',
              BibleVersion.nvi: 'El Señor es mi pastor; nada me falta. En verdes praderas me hace descansar, a las aguas tranquilas me conduce, me infunde nuevas fuerzas. Me guía por sendas de justicia por amor a su nombre. Aun si voy por valles tenebrosos, no temo peligro alguno porque tú estás a mi lado; tu vara de pastor me reconforta.',
              BibleVersion.ntv: 'El Señor es mi pastor; tengo todo lo que necesito. En verdes praderas me hace descansar; me conduce junto a arroyos tranquilos. Él renueva mis fuerzas. Me guía por sendas correctas, y así da honra a su nombre. Incluso cuando cruce el valle más oscuro, no temeré, porque tú estás a mi lado. Tu vara y tu cayado me protegen y me consuelan.',
              BibleVersion.vbl: 'El Señor es mi pastor; tengo todo lo que necesito. Me hace descansar en verdes prados; me guía junto a arroyos serenos. Renueva mi vida. Me conduce por caminos rectos por amor a su nombre. Aunque camine por el valle más oscuro y peligroso, no tendré miedo, porque tú estás conmigo; tu vara y tu bastón me dan seguridad.',
            },
            reflectionText: 'La luz nunca es tan elocuente como cuando atraviesa una quebrada oscura. En fotografía, una escena completamente iluminada por el sol cenital del mediodía resulta plana y carente de emoción; en cambio, es la luz rasante de la primera hora —aquella que tiene que abrirse paso entre la bruma y los riscos escarpados— la que revela las texturas ocultas del paisaje.\n\nDe la misma manera, David no escribe el Salmo 23 desde la comodidad de un palacio de marfil, sino desde la aspereza del pastoreo en terrenos áridos. El valle no es una señal del abandono de Dios, sino el escenario donde Su compañía se vuelve tangible. La sombra solo puede existir si hay una fuente de luz detrás de ti.',
            reflectionPrompt: '¿Qué valle o incertidumbre estás cruzando hoy? Nómbralo con sencillez delante de Dios y pídele ver Su luz rasante guiando tu siguiente paso.',
            estimatedMinutes: 6,
            rootWord: BiblicalRootWord(
              originalScript: 'מְנוּחָה',
              transliteration: 'Menujáh',
              language: 'Hebreo',
              strongCode: 'H4496',
              literalMeaning: 'Aguas de reposo / Descanso que restaura',
              spiritualInsight: 'No describe una simple pausa física, sino un reposo del alma donde cesa la fatiga y el pánico bajo la mirada vigilante del Pastor.',
            ),
            crossReference: 'Juan 10:11, 27-28 — Jesús se presenta como el Buen Pastor que da su vida por las ovejas, conduciéndolas no a un descanso temporal, sino a la vida eterna en Su presencia.',
            photo: PhotoMetadata(
              camera: 'Fujifilm X-T5',
              lens: 'Fujinon XF 35mm f/1.4 R',
              focalLength: '35mm (eq. 53mm)',
              aperture: 'f/2.0',
              shutterSpeed: '1/250s',
              iso: 'ISO 160',
              location: 'Valle de Cochamó, Cordillera Austral',
              timeOfDay: '06:14 AM • Primera luz dorada entre la niebla',
              spiritualBehindTheLens: 'Esperé dos horas en silencio en el borde del desfiladero mientras la neblina cubría los alerces milenarios. Justo cuando parecía que el frío disiparía el día, un rayo oblicuo de sol perforó la niebla como una espada cálida. Recordé que Dios no disipa siempre el valle, pero siempre envía Su luz.',
              technicalBehindTheLens: 'Exposición medida para las altas luces (highlight weighted metering) para conservar la riqueza dorada del haz de luz sin quemar el blanco de la bruma.',
              imageUrl: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=1200&q=80',
            ),
          ),
          // Día 2
          DevotionalDay(
            id: 'habitar-dia-2',
            courseId: 'habitar-en-la-quietud',
            dayNumber: 2,
            title: 'Manantiales en el sequedal',
            scriptureVerse: 'Salmo 63:1-3',
            verseTranslations: {
              BibleVersion.rvr1960: 'Dios, Dios mío eres tú; de madrugada te buscaré; mi alma tiene sed de ti, mi carne te anhela, en tierra seca y árida donde no hay aguas, para ver tu poder y tu gloria, así como te he mirado en el santuario. Porque mejor es tu misericordia que la vida; mis labios te alabarán.',
              BibleVersion.nvi: 'Dios, Dios mío eres tú; de madrugada te busco. Mi alma tiene sed de ti; todo mi ser te anhela en una tierra seca, estéril y sin agua. Quiero verte en tu santuario y contemplar tu poder y tu gloria. Tu amor es mejor que la vida; por eso mis labios te alabarán.',
              BibleVersion.ntv: 'Oh Dios, tú eres mi Dios; de todo corazón te busco. Mi alma tiene sed de ti; todo mi cuerpo te anhela en esta tierra reseca y agotada donde no hay agua. Te he visto en tu santuario y he contemplado tu poder y tu gloria. Tu amor inagotable es mejor que la vida misma; ¡cuánto te alaban mis labios!',
              BibleVersion.vbl: 'Oh Dios, tú eres mi Dios; con anhelo te busco. Mi ser tiene sed de ti; todo mi cuerpo te desea en una tierra seca, exhausta y sin agua. Te contemplé en el santuario para ver tu poder y tu gloria. Como tu amor constante es mejor que la vida, mis labios cantarán tus alabanzas.',
            },
            reflectionText: 'La sed es una bendición incómoda: nos avisa que fuimos diseñados para recibir vida de una fuente que no somos nosotros mismos. En el desierto de Judá, donde David compuso este canto mientras huía de Saúl, el agua no es una metáfora ligera; es la diferencia entre el aliento y el polvo.\n\nEl alma moderna a menudo busca saciar su sed en pozos rotos: el aplauso digital, la productividad incesante o la evasión constante. Pero cuando aceptamos la sequedad del desierto sin desesperar, descubrimos que la sed misma nos conduce a Cristo, la roca herida de donde brota agua viva inagotable.',
            reflectionPrompt: 'Reconoce tu sed interior sin intentar adormecerla con pantallas o prisa. ¿Qué anhela verdaderamente tu espíritu en este momento?',
            estimatedMinutes: 7,
            rootWord: BiblicalRootWord(
              originalScript: 'עָרַג',
              transliteration: 'Arag',
              language: 'Hebreo',
              strongCode: 'H6165',
              literalMeaning: 'Bramar con sed ardiente / Clamar por vida',
              spiritualInsight: 'Describe el gemido de un ciervo exhausto en el desierto cuando huele la humedad del agua a lo lejos. La sed espiritual es la evidencia de que fuimos hechos para Dios.',
            ),
            crossReference: 'Juan 7:37-38 — En el último y gran día de la fiesta, Jesús se puso en pie y alzó la voz, diciendo: «Si alguno tiene sed, venga a mí y beba».',
            photo: PhotoMetadata(
              camera: 'Sony Alpha 7 IV',
              lens: 'Sony FE 50mm f/1.8',
              focalLength: '50mm',
              aperture: 'f/2.8',
              shutterSpeed: '1/500s',
              iso: 'ISO 200',
              location: 'Quebrada de Jerez, Atacama',
              timeOfDay: '07:35 AM • Luz limpia de altitud',
              spiritualBehindTheLens: 'Entre kilómetros de sal y roca volcánica inerte, este delgado curso de agua transparente corre cantando entre las piedras. Donde hay agua, brotan higueras y hierba verde. El Espíritu Santo obra exactamente así en los corazones que parecen secos.',
              technicalBehindTheLens: 'Polarizador circular CPL para eliminar el reflejo cegador de la superficie del agua y permitir ver los guijarros ocres y dorados del lecho.',
              imageUrl: 'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?auto=format&fit=crop&w=1200&q=80',
            ),
          ),
          // Día 3
          DevotionalDay(
            id: 'habitar-dia-3',
            courseId: 'habitar-en-la-quietud',
            dayNumber: 3,
            title: 'Quietud ante el estruendo',
            scriptureVerse: 'Salmo 46:10',
            verseTranslations: {
              BibleVersion.rvr1960: 'Estad quietos, y conoced que yo soy Dios; seré exaltado entre las naciones, enaltecido seré en la tierra.',
              BibleVersion.nvi: '«Quédense quietos, reconozcan que yo soy Dios. ¡Yo seré exaltado entre las naciones! ¡Yo seré enaltecido en la tierra!»',
              BibleVersion.ntv: '«¡Quédense quietos y sepan que yo soy Dios! Toda nación me honrará. Seré alabado por todo el mundo».',
              BibleVersion.vbl: '«Deténganse y reconozcan que yo soy Dios. Seré exaltado entre las naciones; seré honrado en toda la tierra».',
            },
            reflectionText: 'El verbo hebreo traducido como «estad quietos» es Raphah, que significa literalmente «soltar las manos», «dejar caer las armas» o «aflojar el control». No es una invitación a la pereza pasiva, sino una orden amorosa para dejar de intentar sostener el universo sobre nuestros propios hombros.\n\nPara que la superficie de un lago de montaña se convierta en un espejo perfecto que refleje el cielo y los picos nevados, el viento debe calmarse por completo. Si el agua sigue agitada por nuestros propios forcejeos, la imagen de Dios se distorsiona. Cuando soltamos las manos, Su soberanía se refleja con nitidez en nuestra vida.',
            reflectionPrompt: '¿Qué situación o persona estás intentando manipular o controlar con tus fuerzas? Haz un gesto físico abriendo tus manos y entrégalo en oración.',
            estimatedMinutes: 8,
            rootWord: BiblicalRootWord(
              originalScript: 'רָפָה',
              transliteration: 'Raphah',
              language: 'Hebreo',
              strongCode: 'H7503',
              literalMeaning: 'Soltar las manos / Dejar caer las armas',
              spiritualInsight: '«Estad quietos» no es pasividad; es la orden de soltar el timón que pretendemos controlar y rendir las defensas ante la soberanía de Dios.',
            ),
            crossReference: 'Mateo 11:28-29 — «Venid a mí todos los que estáis trabajados y cargados, y yo os haré descansar. Llevad mi yugo sobre vosotros y aprended de mí».',
            photo: PhotoMetadata(
              camera: 'Leica Q2',
              lens: 'Summilux 28mm f/1.7 ASPH',
              focalLength: '28mm',
              aperture: 'f/5.6',
              shutterSpeed: '1/125s',
              iso: 'ISO 100',
              location: 'Lago Nahuel Huapi, Patagonia',
              timeOfDay: '06:50 AM • Aire en calma absoluta',
              spiritualBehindTheLens: 'Por diez minutos no hubo una sola brisa. La superficie del lago era tan quieta que era imposible distinguir entre el pico real del monte y su reflejo invertido en el agua. La quietud no es vacío; es el espejo donde Dios se hace evidente.',
              technicalBehindTheLens: 'Apertura f/5.6 para conseguir nitidez de esquina a esquina en el sensor de 47MP, composición simétrica con la línea del horizonte dividiendo sutilmente el encuadre.',
              imageUrl: 'https://images.unsplash.com/photo-1518495973542-4542c06a5843?auto=format&fit=crop&w=1200&q=80',
            ),
          ),
          // Día 4
          DevotionalDay(
            id: 'habitar-dia-4',
            courseId: 'habitar-en-la-quietud',
            dayNumber: 4,
            title: 'Bajo la sombra del Omnipotente',
            scriptureVerse: 'Salmo 91:1-2',
            verseTranslations: {
              BibleVersion.rvr1960: 'El que habita al abrigo del Altísimo morará bajo la sombra del Omnipotente. Diré yo a Jehová: Esperanza mía, y castillo mío; mi Dios, en quien confiaré.',
              BibleVersion.nvi: 'El que habita al abrigo del Altísimo se acoge a la sombra del Todopoderoso. Yo le digo al Señor: «Tú eres mi refugio, mi fortaleza, el Dios en quien confío».',
              BibleVersion.ntv: 'Los que viven al amparo del Altísimo encontrarán descanso a la sombra del Todopoderoso. Declaro lo siguiente acerca del Señor: solo él es mi refugio, mi lugar seguro; él es mi Dios y en él confío.',
              BibleVersion.vbl: 'El que vive en el lugar secreto del Altísimo reposará bajo la sombra del Todopoderoso. Le diré al Señor: «Tú eres mi refugio y mi fortaleza, mi Dios en quien pongo mi confianza».',
            },
            reflectionText: 'La sombra, en el pensamiento bíblico del Cercano Oriente, no representa tinieblas amenazantes sino el alivio más codiciado: el refugio fresco frente al sol abrasador del mediodía. Estar bajo la sombra de alguien exige proximidad; no puedes estar a la sombra de un árbol si estás a cien metros de él.\n\nHabitar en el abrigo de Dios significa aprender a vivir tan cerca de Su presencia que Su estatura espiritual proyecte un manto de paz sobre nuestros temores. La sombra de Dios es el único lugar donde el cansancio acumulado puede transformarse en descanso restaurador.',
            reflectionPrompt: 'Visualiza la sombra protectora de Dios sobre tu hogar, tu familia y tu mente. Escribe una breve oración de descanso.',
            estimatedMinutes: 6,
            rootWord: BiblicalRootWord(
              originalScript: 'סֵתֶר',
              transliteration: 'Seter',
              language: 'Hebreo',
              strongCode: 'H5643',
              literalMeaning:
                  'Lugar secreto / Escondite sagrado / Velo protector',
              spiritualInsight: 'El término alude al santísimo interior donde nadie entra sin invitación. Habitar allí es vivir en la intimidad inquebrantable del Altísimo.',
            ),
            crossReference: 'Colosenses 3:3 — «Porque habéis muerto, y vuestra vida está escondida con Cristo en Dios».',
            photo: PhotoMetadata(
              camera: 'Canon EOS R5',
              lens: 'Canon RF 85mm f/1.2L USM',
              focalLength: '85mm',
              aperture: 'f/2.0',
              shutterSpeed: '1/400s',
              iso: 'ISO 160',
              location: 'Bosque de Arrayanes y Coihues',
              timeOfDay: '11:15 AM • Sombras geométricas naturales',
              spiritualBehindTheLens: 'Mirando hacia arriba, las ramas de los viejos robles formaban una cúpula viva que filtraba el sol ardiente en pequeños destellos amables. Recordé que Dios no quita todo el calor de la vida, pero extiende Su dosel para que no nos queme.',
              technicalBehindTheLens: 'Enfoque selectivo en el entramado de las hojas superiores, permitiendo que el suelo en primer plano se difumine suavemente.',
              imageUrl: 'https://images.unsplash.com/photo-1448375240586-882707db888b?auto=format&fit=crop&w=1200&q=80',
            ),
          ),
          // Día 5
          DevotionalDay(
            id: 'habitar-dia-5',
            courseId: 'habitar-en-la-quietud',
            dayNumber: 5,
            title: 'El despertar del alba con alabanza',
            scriptureVerse: 'Salmo 108:1-3',
            verseTranslations: {
              BibleVersion.rvr1960: 'Mi corazón está dispuesto, oh Dios; cantaré y entonaré salmos; esta es mi gloria. ¡Despiértense, salterio y arpa! ¡Despertaré al alba! Te alabaré, oh Jehová, entre los pueblos; a ti cantaré salmos entre las naciones.',
              BibleVersion.nvi: 'Firme está, oh Dios, mi corazón; voy a cantarte salmos, gloria mía. ¡Despiértense, arpa y lira! ¡Haré despertar al nuevo día! Te alabaré, Señor, entre los pueblos; te cantaré salmos entre las naciones.',
              BibleVersion.ntv: 'Mi corazón está confiado en ti, oh Dios; por eso te canto alabanzas con toda el alma. ¡Despiértense, lira y arpa! Con mi canto despertaré al amanecer. Te daré gracias, Señor, en medio de la gente; cantaré tus alabanzas entre las naciones.',
              BibleVersion.vbl: 'Mi corazón está listo y confiado, oh Dios; cantaré alabanzas con todo mi espíritu. ¡Despierten, arpa y salterio! Despertaré a la aurora con mi canción. Te alabaré entre los pueblos, Señor; cantaré himnos a ti entre las naciones.',
            },
            reflectionText: 'Hay una audacia santa en las palabras de David: «Despertaré al alba». No espera que el sol aparezca para decidir si tendrá un corazón agradecido; decide adorar antes de que la primera luz toque la tierra.\n\nLa gratitud previa a los acontecimientos es el acto supremo de fe. Cuando iniciamos el día celebrando la fidelidad de Dios antes de revisar las noticias o las urgencias laborales, establecemos los cimientos del corazón sobre la roca. La alabanza es el lente que enfoca la realidad tal como Dios la ve.',
            reflectionPrompt: 'Antes de entrar en las exigencias del día, da gracias por tres misericordias específicas que no merecías pero que Dios te ha concedido hoy.',
            estimatedMinutes: 7,
            rootWord: BiblicalRootWord(
              originalScript: 'כּוּן',
              transliteration: 'Kun',
              language: 'Hebreo',
              strongCode: 'H3559',
              literalMeaning: 'Estar firme / Dispuesto / Cimentado sólidamente',
              spiritualInsight: 'Un corazón «firme» no es aquel que carece de emociones, sino el que ha anclado su voluntad en la fidelidad divina antes de que comiencen las presiones del día.',
            ),
            crossReference: 'Hebreos 13:8-9 — «Jesucristo es el mismo ayer, y hoy, y por los siglos. Buena cosa es afirmar el corazón con la gracia».',
            photo: PhotoMetadata(
              camera: 'Nikon Z7 II',
              lens: 'NIKKOR Z 70-200mm f/2.8 VR S',
              focalLength: '120mm',
              aperture: 'f/4.0',
              shutterSpeed: '1/1000s',
              iso: 'ISO 100',
              location: 'Mirador de los Cóndores, Cordillera Central',
              timeOfDay: '05:58 AM • Primer resplandor carmesí',
              spiritualBehindTheLens: 'El termómetro marcaba -2°C. Mis dedos estaban casi entumecidos en el trípode. De repente, una línea delgada color ámbar encendió el filo de las cumbres. Fue como presenciar el primer día de la creación. Valió cada minuto de vigilia.',
              technicalBehindTheLens: 'Disparo en ráfaga silenciosa electrónica con medición puntual en el horizonte para registrar el gradiente del cielo sin trepidación.',
              imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=1200&q=80',
            ),
          ),
        ],
      ),

      // CURSO 2: Ojos que Ven - Fe, Asombro y la Lente
      const DevotionalCourse(
        id: 'ojos-que-ven-fe-fotografia',
        title: 'Ojos que Ven',
        subtitle: 'Fe, Asombro y la Lente Contemplativa',
        category: 'Fotografía & Fe',
        description: 'Un curso formativo para fotógrafos, artistas y buscadores espirituales. Aprende a desacelerar la mirada, encuadrar la belleza de lo cotidiano y entender cómo la técnica fotográfica (la luz, la apertura, la espera) es una parábola viviente de la vida de fe.',
        coverImageUrl: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=1200&q=80',
        totalDays: 4,
        author: AuthorProfile(
          id: 'author-mateo-valenzuela',
          name: 'Mateo V. Valenzuela',
          role: 'Fotógrafo Documental & Ensayista',
          bio: 'Mateo es fotógrafo documental y creador visual. Ha recorrido comunidades rurales de América Latina capturando historias de dignidad y esperanza. Cree firmemente que la contemplación estética es una puerta de entrada a la adoración genuina.',
          avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=300&q=80',
        ),
        days: [
          // Día 1
          DevotionalDay(
            id: 'ojos-dia-1',
            courseId: 'ojos-que-ven-fe-fotografia',
            dayNumber: 1,
            title: 'La geometría de la Gracia',
            scriptureVerse: 'Génesis 1:31',
            verseTranslations: {
              BibleVersion.rvr1960: 'Y vio Dios todo lo que había hecho, y he aquí que era bueno en gran manera. Y fue la tarde y la mañana el día sexto.',
              BibleVersion.nvi: 'Dios miró todo lo que había hecho, y vio que era muy bueno. Y vino la noche, y llegó la mañana: ése fue el sexto día.',
              BibleVersion.ntv: 'Entonces Dios miró todo lo que había hecho, ¡y vio que era muy bueno! Y pasó la tarde y llegó la mañana, así se cumplió el sexto día.',
              BibleVersion.vbl: 'Dios vio todo lo que había creado, ¡y era verdaderamente excelente! Y cayó la tarde y llegó la mañana: el sexto día.',
            },
            reflectionText: 'La palabra hebrea para «vio» en Génesis no alude a una mirada superficial ni a un escaneo apresurado; implica deleite, contemplación y reconocimiento de la armonía. Dios se detuvo a contemplar Su obra antes de descansar.\n\nEn la fotografía arquitectónica aprendemos que las líneas, los arcos y la luz revelan el propósito del diseñador. Cuando nos tomamos el tiempo para mirar con detenimiento las formas del mundo creado, descubrimos que nada es producto del azar. Hay un orden benevolente sustentando todas las cosas.',
            reflectionPrompt: 'Detén tu mirada en algún objeto o rincón cotidiano de tu entorno. Encuentra una línea o textura y medita en el Creador que sostiene el orden de tu día.',
            estimatedMinutes: 6,
            rootWord: BiblicalRootWord(
              originalScript: 'רָאָה',
              transliteration: 'Ra’ah',
              language: 'Hebreo',
              strongCode: 'H7200',
              literalMeaning:
                  'Contemplar con deleite / Percibir la armonía profunda',
              spiritualInsight: 'Dios no se limitó a crear; se detuvo a contemplar y a gozarse en Su obra. La fotografía y el arte nacen de imitar esta mirada atenta del Creador.',
            ),
            crossReference: 'Juan 1:1-3 — Todas las cosas por medio del Verbo fueron hechas; en la creación material resplandece la belleza del Hijo.',
            photo: PhotoMetadata(
              camera: 'Hasselblad X2D 100C',
              lens: 'XCD 38mm f/2.5 V',
              focalLength: '38mm (eq. 30mm)',
              aperture: 'f/4.0',
              shutterSpeed: '1/125s',
              iso: 'ISO 100',
              location: 'Monasterio de la Transfiguración',
              timeOfDay: '09:20 AM • Luz cenital tamizada por muros de piedra',
              spiritualBehindTheLens: 'La austeridad de los muros de piedra caliza del siglo XVI y el silencio del claustro hacían que cada sombra pareciera una oración esculpida. Dios no necesita adornos ruidosos para manifestar Su santidad.',
              technicalBehindTheLens: 'Corrección de perspectiva arquitectónica con trípode nivelado con burbuja electrónica para mantener verticales estrictas y evitar fuga de líneas.',
              imageUrl: 'https://images.unsplash.com/photo-1513694203232-719a280e022f?auto=format&fit=crop&w=1200&q=80',
            ),
          ),
          // Día 2
          DevotionalDay(
            id: 'ojos-dia-2',
            courseId: 'ojos-que-ven-fe-fotografia',
            dayNumber: 2,
            title: 'La belleza de lo inadvertido',
            scriptureVerse: 'Mateo 6:28-29',
            verseTranslations: {
              BibleVersion.rvr1960: 'Y por el vestido, ¿por qué os congojáis? Considerad los lirios del campo, cómo crecen: no trabajan ni hilan; pero os digo, que ni aun Salomón con toda su gloria se vistió así como uno de ellos.',
              BibleVersion.nvi: '¿Y por qué se preocupan por la ropa? Observen cómo crecen los lirios del campo. No trabajan ni hilan; sin embargo, les digo que ni siquiera Salomón, con todo su esplendor, se vestía como uno de ellos.',
              BibleVersion.ntv: '¿Y por qué preocuparse por la ropa? Miren cómo crecen los lirios del campo: no trabajan ni cosen su ropa, y sin embargo, ni Salomón con toda su gloria se vistió tan bellamente como uno de ellos.',
              BibleVersion.vbl: '¿Y por qué se angustian por el vestido? Miren cómo florecen los lirios salvajes del campo: no se afanan ni tejen; pero les aseguro que ni el rey Salomón en todo su esplendor se vistió jamás con tanta belleza como uno solo de ellos.',
            },
            reflectionText: 'Jesús utiliza el verbo griego katamanthano, que significa «examinar de cerca», «estudiar minuciosamente con la mente y el corazón». Nos pide que nos agachemos en el pasto a observar las diminutas flores silvestres que la mayoría de los caminantes pisan sin mirar.\n\nEl lente macro en fotografía nos revela un cosmos entero en una gota de rocío o en la nervadura de un pétalo. Lo que el mundo cataloga como insignificante es custodiado por Dios con un detalle sobrecogedor. Si Dios pinta con tal esmero lo que vive solo una tarde, ¿cuánto más cuidará de ti?',
            reflectionPrompt: '¿En qué aspecto de tu vida te has sentido desatendido o invisible? Escribe una oración recordando que el Padre conoce cada detalle tuyo.',
            estimatedMinutes: 7,
            rootWord: BiblicalRootWord(
              originalScript: 'καταμανθάνω',
              transliteration: 'Katamanthano',
              language: 'Griego',
              strongCode: 'G2648',
              literalMeaning:
                  'Observar minuciosamente / Aprender con atención detenida',
              spiritualInsight: 'Jesús nos invita a una observación de cerca, como quien usa una lente macro. En cada detalle inadvertido de la flor silvestre, el Padre firma su providencia.',
            ),
            crossReference: 'Lucas 12:32 — «No temáis, manada pequeña, porque a vuestro Padre le ha placido daros el reino».',
            photo: PhotoMetadata(
              camera: 'Fujifilm X-T5',
              lens: 'Fujinon XF 80mm f/2.8 LM OIS Macro',
              focalLength: '80mm (eq. 120mm)',
              aperture: 'f/3.2',
              shutterSpeed: '1/320s',
              iso: 'ISO 125',
              location: 'Calles empedradas de Antigua',
              timeOfDay: '08:15 AM • Rocío matinal',
              spiritualBehindTheLens: 'Entre la grieta áspera del pavimento de piedra crecía una flor silvestre amarilla de apenas un centímetro de diámetro, cargada con una gota de rocío que actuaba como lupa natural. La vida de Dios florece aún en las grietas más duras.',
              technicalBehindTheLens: 'Distancia mínima de enfoque a escala 1:1, utilizando luz natural rebotada con una tarjeta blanca pequeña para aclarar las sombras del pétalo inferior.',
              imageUrl: 'https://images.unsplash.com/photo-1490750967868-88aa4486c946?auto=format&fit=crop&w=1200&q=80',
            ),
          ),
          // Día 3
          DevotionalDay(
            id: 'ojos-dia-3',
            courseId: 'ojos-que-ven-fe-fotografia',
            dayNumber: 3,
            title: 'Tiempo de exposición y paciencia',
            scriptureVerse: 'Santiago 5:7-8',
            verseTranslations: {
              BibleVersion.rvr1960: 'Por tanto, hermanos, tened paciencia hasta la venida del Señor. Mirad cómo el labrador espera el precioso fruto de la tierra, aguardando con paciencia hasta que reciba la lluvia temprana y la tardía. Tened también vosotros paciencia, y afirmad vuestros corazones; porque la venida del Señor se acerca.',
              BibleVersion.nvi: 'Por tanto, hermanos, tengan paciencia hasta la venida del Señor. Miren cómo espera el agricultor a que la tierra dé su precioso fruto y con qué paciencia aguarda las temporadas de lluvia. Así también ustedes, manténganse firmes y aguarden con paciencia, porque la venida del Señor está cerca.',
              BibleVersion.ntv: 'Amados hermanos, tengan paciencia mientras esperan el regreso del Señor. Piensen en los agricultores, que con paciencia esperan las lluvias en el otoño y en la primavera. Con qué satisfacción esperan que maduren los preciosos cultivos. Ustedes también deben ser pacientes. Cobren ánimo, porque la venida del Señor está cerca.',
              BibleVersion.vbl: 'Tengan paciencia, entonces, hermanos y hermanas, mientras esperan la venida del Señor. Observen cómo el campesino espera con paciencia el valioso fruto de la tierra hasta recibir las lluvias de otoño y primavera. Ustedes también deben tener paciencia. Fortalezcan sus corazones, porque el regreso del Señor está cerca.',
            },
            reflectionText: 'En la era digital, estamos condicionados a la inmediatez: queremos resultados al instante con un solo toque. Sin embargo, en la fotografía de larga exposición, la belleza surge precisamente de mantener el obturador abierto mientras el tiempo transcurre en quietud.\n\nDurante esos 20 o 30 segundos, el sensor acumula fotones invisibles a simple vista; las olas agitadas del mar se transforman en una seda etérea y las nubes dibujan senderos de luz en el cielo. La paciencia cristiana no es resignación vacía; es mantener el alma abierta ante Dios mientras Su gracia obra aquello que la prisa nunca podrá producir.',
            reflectionPrompt: '¿En qué situación estás sintiendo desesperación por falta de respuestas rápidas? Pídele a Dios la templanza de una larga exposición.',
            estimatedMinutes: 8,
            rootWord: BiblicalRootWord(
              originalScript: 'μακροθυμία',
              transliteration: 'Makrothumia',
              language: 'Griego',
              strongCode: 'G3115',
              literalMeaning: 'Paciencia constante / Aguante con longanimidad',
              spiritualInsight: 'Como una larga exposición que acumula fotones en la oscuridad, la paciencia del creyente permite que la gracia madure lo que la prisa arruinaría.',
            ),
            crossReference: 'Romanos 8:25 — «Pero si esperamos lo que no vemos, con paciencia lo aguardamos».',
            photo: PhotoMetadata(
              camera: 'Sony Alpha 7R V',
              lens: 'Sony FE 24mm f/1.4 GM',
              focalLength: '24mm',
              aperture: 'f/5.6',
              shutterSpeed: '25 segundos',
              iso: 'ISO 100',
              location: 'Faro de Cabo Raper, Costa Salvaje',
              timeOfDay: '21:40 PM • Noche cerrada y olas marinas',
              spiritualBehindTheLens: 'El viento costero era implacable. Tuve que colgar mi mochila pesada del gancho del trípode para evitar cualquier vibración. El haz del faro giraba en la oscuridad cada 12 segundos. Lo que parecía un caos de olas oscuras se transformó en una niebla luminosa de paz.',
              technicalBehindTheLens: 'Filtro ND de 6 pasos acoplado para permitir una exposición de 25 segundos sin sobreexponer las luces del faro, enfoque manual bloqueado al infinito.',
              imageUrl: 'https://images.unsplash.com/photo-1509316975850-ff9c5deb0cd9?auto=format&fit=crop&w=1200&q=80',
            ),
          ),
          // Día 4
          DevotionalDay(
            id: 'ojos-dia-4',
            courseId: 'ojos-que-ven-fe-fotografia',
            dayNumber: 4,
            title: 'El grano y la imperfección redimida',
            scriptureVerse: '2 Corintios 12:9',
            verseTranslations: {
              BibleVersion.rvr1960: 'Y me ha dicho: Bástate mi gracia; porque mi poder se perfecciona en la debilidad. Por tanto, de buena gana me gloriaré más bien en mis debilidades, para que repose sobre mí el poder de Cristo.',
              BibleVersion.nvi: 'pero él me dijo: «Te basta con mi gracia, pues mi poder se perfecciona en la debilidad». Por lo tanto, gustosamente haré más bien alarde de mis debilidades, para que permanezca sobre mí el poder de Cristo.',
              BibleVersion.ntv: 'Cada vez él me dijo: «Mi gracia es todo lo que necesitas; mi poder actúa mejor en la debilidad». Así que ahora me alegra jactarme de mis debilidades, para que el poder de Cristo pueda actuar a través de mí.',
              BibleVersion.vbl: 'Pero él me respondió: «Mi gracia es suficiente para ti, pues mi poder se demuestra plenamente en tu debilidad». Así que con gusto me gloriaré en mis flaquezas, para que el poder de Cristo habite en mí.',
            },
            reflectionText: 'Vivimos bajo la tiranía de la perfección algorítmica: filtros que borran cada arruga, colores saturados artificialmente y texturas hiper-limpias. Pero los amantes de la película tradicional saben que el grano de plata de un rollo fotográfico le confiere calor humano, alma y verdad a la imagen.\n\nDios no busca instrumentos impecables ni vidas sin fisuras; busca vasijas de barro que reconozcan su fragilidad. Tus cicatrices, tus errores redimidos y tus limitaciones son precisamente la textura donde el evangelio resplandece con mayor veracidad.',
            reflectionPrompt: 'Acepta con gratitud tu humanidad delante del Señor. Entrega esa debilidad que tanto te avergüenza y dile: «Bástate tu gracia en mí».',
            estimatedMinutes: 7,
            rootWord: BiblicalRootWord(
              originalScript: 'ἀρκέω',
              transliteration: 'Arkeo',
              language: 'Griego',
              strongCode: 'G714',
              literalMeaning:
                  'Ser enteramente suficiente / Proteger como barrera',
              spiritualInsight: 'La gracia no es un complemento a nuestra fuerza; es suficiente por sí misma. En el grano e imperfección de nuestra vida de barro, Su poder se perfecciona.',
            ),
            crossReference: '2 Corintios 4:7 — «Pero tenemos este tesoro en vasos de barro, para que la excelencia del poder sea de Dios, y no de nosotros».',
            photo: PhotoMetadata(
              camera: 'Leica M11',
              lens: 'Leica Summicron-M 50mm f/2',
              focalLength: '50mm',
              aperture: 'f/2.0',
              shutterSpeed: '1/800s',
              iso: 'ISO 400',
              location: 'Taller de alfarería en Pomaire',
              timeOfDay: '16:30 PM • Luz lateral dorada',
              spiritualBehindTheLens: 'Las manos de don Pedro estaban cubiertas de arcilla húmeda y arrugas profundas tras 45 años de torno. Mientras modelaba una vasija de greda, me dijo: «El barro no discute con las manos que le dan forma». Fue el sermón más profundo del año.',
              technicalBehindTheLens: 'Luz natural que entraba por una ventana de madera lateral. Apertura f/2 para difuminar el fondo del taller y centrar la mirada en el barro y las líneas de las manos.',
              imageUrl: 'https://images.unsplash.com/photo-1565193566173-7a0ee3dbe261?auto=format&fit=crop&w=1200&q=80',
            ),
          ),
        ],
      ),

      // CURSO 3: Caminar sin Prisa - Eclesiastés para el Alma Moderna
      const DevotionalCourse(
        id: 'caminar-sin-prisa-eclesiastes',
        title: 'Caminar sin Prisa',
        subtitle: 'Sabiduría de Eclesiastés para el Alma Moderna',
        category: 'Paz & Sabiduría',
        description: 'Un bálsamo contra el agotamiento contemporáneo. Redescubre el valor sagrado del descanso, los ritmos naturales de la creación y la alegría de recibir la vida como un don gratuito de Dios en lugar de un trofeo que hay que conquistar.',
        coverImageUrl: 'https://images.unsplash.com/photo-1447752875215-b2761acb3c5d?auto=format&fit=crop&w=1200&q=80',
        totalDays: 3,
        author: AuthorProfile(
          id: 'author-claudia-morales',
          name: 'Dra. Claudia de Morales',
          role: 'Consejera Familiar & Escritora',
          bio: 'Claudia es médica de familia y consejera de salud integral. Autora de ensayos sobre descanso, shabbat y ritmos de gracia frente al estrés y la ansiedad en la cultura moderna.',
          avatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=300&q=80',
        ),
        days: [
          // Día 1
          DevotionalDay(
            id: 'prisa-dia-1',
            courseId: 'caminar-sin-prisa-eclesiastes',
            dayNumber: 1,
            title: 'Todo tiene su tiempo señalado',
            scriptureVerse: 'Eclesiastés 3:1',
            verseTranslations: {
              BibleVersion.rvr1960: 'Todo tiene su tiempo, y todo lo que se quiere debajo del cielo tiene su hora.',
              BibleVersion.nvi: 'Todo tiene su momento oportuno; hay un tiempo para todo lo que se hace bajo el cielo.',
              BibleVersion.ntv: 'Hay una temporada para todo, un tiempo para cada actividad bajo el cielo.',
              BibleVersion.vbl: 'Hay un tiempo señalado para cada cosa, y un momento para todo propósito debajo del cielo.',
            },
            reflectionText: 'Intentar acelerar los ciclos de Dios es como tirar de los brotes de una planta para que crezca más rápido: solo logramos arrancarla de raíz. Las estaciones existen por una razón biológica y espiritual. El invierno de reposo es tan necesario como el verano de cosecha.',
            reflectionPrompt: '¿En qué estación espiritual sientes que estás hoy: siembra, invierno silencioso, brote o cosecha? Acepta el tiempo de Dios.',
            estimatedMinutes: 6,
            rootWord: BiblicalRootWord(
              originalScript: 'זְמָן',
              transliteration: 'Zeman',
              language: 'Hebreo',
              strongCode: 'H2165',
              literalMeaning: 'Tiempo fijado / Estación señalada con propósito',
              spiritualInsight: 'Los ritmos de la vida no son un caos fortuito ni una carrera sin meta. Hay un propósito sabio para el invierno y para la primavera.',
            ),
            crossReference: 'Gálatas 4:4-5 — «Pero cuando vino el cumplimiento del tiempo, Dios envió a su Hijo... para que recibiésemos la adopción de hijos».',
            photo: PhotoMetadata(
              camera: 'Fujifilm X-Pro3',
              lens: 'Fujinon XF 23mm f/2',
              focalLength: '23mm (eq. 35mm)',
              aperture: 'f/4.0',
              shutterSpeed: '1/300s',
              iso: 'ISO 200',
              location: 'Bosque de Robles en Otoño',
              timeOfDay: '17:00 PM • Viento suave de otoño',
              spiritualBehindTheLens: 'Las hojas doradas caían una a una, sin dramatismo ni resistencia. El árbol no lucha contra el despojo; confía en que la primavera volverá a su tiempo.',
              technicalBehindTheLens: 'Velocidad de obturación moderada para capturar una ligera sensación de caída en las hojas suspendidas en el aire.',
              imageUrl: 'https://images.unsplash.com/photo-1447752875215-b2761acb3c5d?auto=format&fit=crop&w=1200&q=80',
            ),
          ),
          // Día 2
          DevotionalDay(
            id: 'prisa-dia-2',
            courseId: 'caminar-sin-prisa-eclesiastes',
            dayNumber: 2,
            title: 'El don sagrado de disfrutar lo simple',
            scriptureVerse: 'Eclesiastés 3:12-13',
            verseTranslations: {
              BibleVersion.rvr1960: 'Yo he conocido que no hay para ellos cosa mejor que alegrarse, y hacer bien en su vida; y también que es don de Dios que todo hombre coma y beba, y goce el bien de toda su labor.',
              BibleVersion.nvi: 'Sé que nada hay mejor para el hombre que alegrarse y hacer el bien mientras viva; y sé también que es un don de Dios que el hombre coma o beba y disfrute de todos sus afanes.',
              BibleVersion.ntv: 'Así que llegué a la conclusión de que no hay nada mejor para la gente que ser felices y disfrutar de la vida mientras puedan. Además, la gente debería comer, beber y aprovechar el fruto de su trabajo, porque son regalos de Dios.',
              BibleVersion.vbl: 'Comprendí que no hay nada mejor para las personas que estar alegres y hacer el bien mientras vivan. Y que cada uno pueda comer, beber y disfrutar del fruto de su esfuerzo es un don que proviene de Dios.',
            },
            reflectionText: 'Nos han enseñado a postergar el gozo para cuando alcancemos la meta, compremos la casa o terminemos el proyecto. Pero Salomón nos recuerda que la gloria de Dios a menudo se saborea en una taza de café caliente, en el pan compartido con personas amadas y en la gratitud por la salud de hoy.',
            reflectionPrompt: 'Planifica un momento de deleite consciente hoy: comer sin pantallas, dar un paseo en silencio o escuchar a alguien con plena atención.',
            estimatedMinutes: 6,
            rootWord: BiblicalRootWord(
              originalScript: 'מַתָּת',
              transliteration: 'Mattath',
              language: 'Hebreo',
              strongCode: 'H4991',
              literalMeaning: 'Don generoso / Ofrenda gratuita / Regalo',
              spiritualInsight: 'El trabajo y la comida cotidiana no son cadenas de esclavitud, sino dones que Dios nos entrega con amor para ser disfrutados con alabanza.',
            ),
            crossReference: '1 Timoteo 6:17 — «Dios nos da todas las cosas en abundancia para que las disfrutemos».',
            photo: PhotoMetadata(
              camera: 'Leica Q2',
              lens: 'Summilux 28mm f/1.7',
              focalLength: '28mm',
              aperture: 'f/2.8',
              shutterSpeed: '1/160s',
              iso: 'ISO 250',
              location: 'Mesa de campo rústica',
              timeOfDay: '12:30 PM • Luz cálida de mediodía',
              spiritualBehindTheLens: 'Un pan rústico partido sobre una tabla de madera de olivo y un cuenco de aceite. No hacía falta ningún adorno más para sentir que estábamos en un banquete celestial.',
              technicalBehindTheLens: 'Enfoque selectivo sobre la corteza crujiente del pan artesanal, resaltando las motas de harina blanca con la luz natural.',
              imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=1200&q=80',
            ),
          ),
          // Día 3
          DevotionalDay(
            id: 'prisa-dia-3',
            courseId: 'caminar-sin-prisa-eclesiastes',
            dayNumber: 3,
            title: 'Mejor es el reposo que la fatiga hueca',
            scriptureVerse: 'Eclesiastés 4:6',
            verseTranslations: {
              BibleVersion.rvr1960: 'Más vale un puño lleno con descanso, que ambos puños llenos con trabajo y aflicción de espíritu.',
              BibleVersion.nvi: 'Más vale un puño lleno de descanso que dos puñados de fatiga y de correr tras el viento.',
              BibleVersion.ntv: 'Es mejor tener un puñado con tranquilidad que dos puñados con trabajo pesado y perseguir el viento.',
              BibleVersion.vbl: 'Es mucho mejor un puñado con paz y sosiego que dos puños repletos de trabajo afanoso y persecución del viento.',
            },
            reflectionText: 'Nuestra cultura premia tener «ambos puños llenos», aunque eso signifique perder el alma por estrés crónico. La sabiduría de Dios nos invita a la sobriedad: un puño lleno con paz vale infinitamente más que dos puños repletos de logros vanos acompañados de noches de insomnio.',
            reflectionPrompt: '¿A qué exigencia desmedida puedes renunciar esta semana para ganar paz mental y tiempo con Dios y tu familia?',
            estimatedMinutes: 7,
            rootWord: BiblicalRootWord(
              originalScript: 'נַחַת',
              transliteration: 'Najat',
              language: 'Hebreo',
              strongCode: 'H5183',
              literalMeaning: 'Reposo sosegado / Serenidad profunda / Calma',
              spiritualInsight: 'Un solo puño con najat (sosiego apacible) vale más que dos manos repletas de fatiga y vanidad. Dios honra el descanso y condena el afán.',
            ),
            crossReference: 'Salmo 127:2 — «Por demás es que os levantéis de madrugada, y vayáis tarde a reposar... pues que a su amado dará Dios el sueño».',
            photo: PhotoMetadata(
              camera: 'Canon EOS R6',
              lens: 'RF 50mm f/1.8 STM',
              focalLength: '50mm',
              aperture: 'f/2.2',
              shutterSpeed: '1/200s',
              iso: 'ISO 320',
              location: 'Galería de madera bajo la lluvia',
              timeOfDay: '18:15 PM • Llovizna suave',
              spiritualBehindTheLens: 'Sentado en una mecedora de madera mirando las colinas verdes envueltas en lluvia. El mundo seguía girando, pero en ese rincón reinaba el reposo de Dios.',
              technicalBehindTheLens: 'Tono cálido con balance de blancos manual ajustado a 5600K para contrastar la frialdad de la lluvia exterior con la calidez de la madera.',
              imageUrl: 'https://images.unsplash.com/photo-1519681393784-d120267933ba?auto=format&fit=crop&w=1200&q=80',
            ),
          ),
        ],
      ),
    ];
  }

  static const DevotionalCourse _defaultFallbackCourse = DevotionalCourse(
    id: 'fallback-course',
    title: 'Remanso Contemplativo',
    subtitle: 'Ruta Diaria de Paz',
    description: 'Espacio de oración y meditación.',
    category: 'General',
    author: AuthorProfile(
      id: 'author-default',
      name: 'Mentor Remanso',
      role: 'Guía Espiritual',
      bio: 'Acompañamiento en la fe.',
      avatarUrl: '',
    ),
    coverImageUrl: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=800&q=80',
    totalDays: 1,
    days: [_defaultFallbackDay],
  );

  static const DevotionalDay _defaultFallbackDay = DevotionalDay(
    id: 'fallback-day',
    courseId: 'fallback-course',
    dayNumber: 1,
    title: 'Paz en la Presencia',
    scriptureVerse: 'Salmo 46:10',
    verseTranslations: {
      BibleVersion.rvr1960: 'Estad quietos, y conoced que yo soy Dios.',
      BibleVersion.nvi: 'Quédense quietos, reconozcan que yo soy Dios.',
      BibleVersion.ntv: '¡Quédense quietos y sepan que yo soy Dios!',
      BibleVersion.vbl: 'Deténganse y reconozcan que yo soy Dios.',
    },
    reflectionText: 'Respira profundo y descansa en la fidelidad divina.',
    reflectionPrompt: '¿Qué cargas entregas hoy al Señor?',
    estimatedMinutes: 5,
    rootWord: BiblicalRootWord(
      originalScript: 'רָפָה',
      transliteration: 'Raphah',
      language: 'Hebreo',
      strongCode: 'H7503',
      literalMeaning: 'Soltar las manos / Descansar en Dios',
      spiritualInsight:
          'Soltar el afán para contemplar la soberanía del Padre.',
    ),
    crossReference: 'Mateo 11:28 — «Venid a mí todos los que estáis trabajados y cargados».',
    photo: PhotoMetadata(
      camera: 'Cámara Contemplativa',
      lens: '50mm',
      focalLength: '50mm',
      aperture: 'f/2.8',
      shutterSpeed: '1/250s',
      iso: 'ISO 100',
      location: 'Quietud',
      timeOfDay: 'Amanecer',
      spiritualBehindTheLens: 'Un instante de reposo.',
      technicalBehindTheLens: 'Luz natural.',
      imageUrl: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=800&q=80',
    ),
  );
}
