// Modelos de datos limpios e inmutables para Remanso.
// Diseñados para una arquitectura 100% offline-first.

/// Versiones de la Biblia soportadas para estudio reflexivo comparativo.
/// Cada versión incluye su atribución legal (Fair Use / Dominio Público / Creative Commons).
enum BibleVersion {
  rvr1960(
    code: 'RVR1960',
    title: 'Reina-Valera 1960',
    attribution:
        'Reina-Valera 1960 ® © Sociedades Bíblicas Unidas, 1960. Cita ministerial con fines reflexivos sin fines comerciales (Fair Use).',
  ),
  nvi(
    code: 'NVI',
    title: 'Nueva Versión Internacional',
    attribution:
        'Santa Biblia, NUEVA VERSIÓN INTERNACIONAL® NVI® © 1999, 2015 por Bíblica, Inc.® Utilizado con fines reflexivos sin fines comerciales.',
  ),
  ntv(
    code: 'NTV',
    title: 'Nueva Traducción Viviente',
    attribution:
        'Santa Biblia, Nueva Traducción Viviente, © Tyndale House Foundation, 2010. Usado con fines devocionales y educativos (Fair Use).',
  ),
  vbl(
    code: 'VBL',
    title: 'Versión Biblia Libre',
    attribution:
        'Versión Biblia Libre (VBL) © 2014-2024 Dr. Jonathan Gallagher. Licencia abierta Creative Commons Atribución-CompartirIgual 4.0 Internacional (CC BY-SA 4.0).',
  );

  final String code;
  final String title;
  final String attribution;

  const BibleVersion({
    required this.code,
    required this.title,
    required this.attribution,
  });

  static BibleVersion fromCode(String code) {
    return BibleVersion.values.firstWhere(
      (v) => v.code.toUpperCase() == code.toUpperCase(),
      orElse: () => BibleVersion.rvr1960,
    );
  }
}

/// Metadatos técnicos y contemplativos de la fotografía de autor.
class PhotoMetadata {
  final String camera;
  final String lens;
  final String focalLength;
  final String aperture;
  final String shutterSpeed;
  final String iso;
  final String location;
  final String timeOfDay;
  final String spiritualBehindTheLens;
  final String technicalBehindTheLens;
  final String imageUrl;

  const PhotoMetadata({
    required this.camera,
    required this.lens,
    required this.focalLength,
    required this.aperture,
    required this.shutterSpeed,
    required this.iso,
    required this.location,
    required this.timeOfDay,
    required this.spiritualBehindTheLens,
    required this.technicalBehindTheLens,
    required this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
        'camera': camera,
        'lens': lens,
        'focalLength': focalLength,
        'aperture': aperture,
        'shutterSpeed': shutterSpeed,
        'iso': iso,
        'location': location,
        'timeOfDay': timeOfDay,
        'spiritualBehindTheLens': spiritualBehindTheLens,
        'technicalBehindTheLens': technicalBehindTheLens,
        'imageUrl': imageUrl,
      };

  factory PhotoMetadata.fromJson(Map<String, dynamic> json) => PhotoMetadata(
        camera: json['camera'] as String? ?? 'Cámara Desconocida',
        lens: json['lens'] as String? ?? 'Lente Prime',
        focalLength: json['focalLength'] as String? ?? '35mm',
        aperture: json['aperture'] as String? ?? 'f/2.8',
        shutterSpeed: json['shutterSpeed'] as String? ?? '1/250s',
        iso: json['iso'] as String? ?? 'ISO 100',
        location: json['location'] as String? ?? 'Lugar de Quietud',
        timeOfDay: json['timeOfDay'] as String? ?? 'Amanecer',
        spiritualBehindTheLens: json['spiritualBehindTheLens'] as String? ?? '',
        technicalBehindTheLens: json['technicalBehindTheLens'] as String? ?? '',
        imageUrl: json['imageUrl'] as String? ?? '',
      );
}

class AuthorProfile {
  final String id;
  final String name;
  final String role;
  final String bio;
  final String avatarUrl;

  const AuthorProfile({
    required this.id,
    required this.name,
    required this.role,
    required this.bio,
    required this.avatarUrl,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'role': role,
        'bio': bio,
        'avatarUrl': avatarUrl,
      };

  factory AuthorProfile.fromJson(Map<String, dynamic> json) => AuthorProfile(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? 'Autor Invitado',
        role: json['role'] as String? ?? 'Mentor Espiritual',
        bio: json['bio'] as String? ?? '',
        avatarUrl: json['avatarUrl'] as String? ?? '',
      );
}

/// Raíz lingüística y teológica en hebreo o griego para profundización bíblica contemplativa.
class BiblicalRootWord {
  final String originalScript; // e.g. "מְנוּחָה"
  final String transliteration; // e.g. "Menujáh"
  final String language; // "Hebreo" o "Griego"
  final String strongCode; // e.g. "H4496"
  final String literalMeaning; // e.g. "Aguas de reposo / Descanso que restaura"
  final String spiritualInsight; // Reflexión teológica sosegada

  const BiblicalRootWord({
    required this.originalScript,
    required this.transliteration,
    required this.language,
    required this.strongCode,
    required this.literalMeaning,
    required this.spiritualInsight,
  });

  Map<String, dynamic> toJson() => {
        'originalScript': originalScript,
        'transliteration': transliteration,
        'language': language,
        'strongCode': strongCode,
        'literalMeaning': literalMeaning,
        'spiritualInsight': spiritualInsight,
      };

  factory BiblicalRootWord.fromJson(Map<String, dynamic> json) => BiblicalRootWord(
        originalScript: json['originalScript'] as String? ?? '',
        transliteration: json['transliteration'] as String? ?? '',
        language: json['language'] as String? ?? 'Hebreo',
        strongCode: json['strongCode'] as String? ?? '',
        literalMeaning: json['literalMeaning'] as String? ?? '',
        spiritualInsight: json['spiritualInsight'] as String? ?? '',
      );
}

class DevotionalDay {
  final String id;
  final String courseId;
  final int dayNumber;
  final String title;
  final String scriptureVerse;
  final Map<BibleVersion, String> verseTranslations;
  final String reflectionText;
  final String reflectionPrompt;
  final PhotoMetadata photo;
  final int estimatedMinutes;
  final BiblicalRootWord? rootWord;
  final String? crossReference;

  const DevotionalDay({
    required this.id,
    required this.courseId,
    required this.dayNumber,
    required this.title,
    required this.scriptureVerse,
    required this.verseTranslations,
    required this.reflectionText,
    required this.reflectionPrompt,
    required this.photo,
    this.estimatedMinutes = 7,
    this.rootWord,
    this.crossReference,
  });

  /// Helper que obtiene el texto del versículo según la versión solicitada con fallback seguro
  String getVerse(BibleVersion version) {
    if (verseTranslations.containsKey(version) && verseTranslations[version]!.trim().isNotEmpty) {
      return verseTranslations[version]!;
    }
    // Fallback prioritario a RVR1960 o primera disponible
    return verseTranslations[BibleVersion.rvr1960] ??
        verseTranslations.values.firstWhere((t) => t.trim().isNotEmpty, orElse: () => '');
  }

  /// Atributos de compatibilidad
  String get scriptureText => getVerse(BibleVersion.rvr1960);
  String get scriptureTranslation => 'Multi-versión';

  Map<String, dynamic> toJson() => {
        'id': id,
        'courseId': courseId,
        'dayNumber': dayNumber,
        'title': title,
        'scriptureVerse': scriptureVerse,
        'verseTranslations':
            verseTranslations.map((key, value) => MapEntry(key.code, value)),
        'reflectionText': reflectionText,
        'reflectionPrompt': reflectionPrompt,
        'photo': photo.toJson(),
        'estimatedMinutes': estimatedMinutes,
        if (rootWord != null) 'rootWord': rootWord!.toJson(),
        if (crossReference != null) 'crossReference': crossReference,
      };

  factory DevotionalDay.fromJson(Map<String, dynamic> json) {
    final Map<BibleVersion, String> translations = {};

    if (json['verseTranslations'] != null && json['verseTranslations'] is Map) {
      final rawMap = json['verseTranslations'] as Map<String, dynamic>;
      for (final entry in rawMap.entries) {
        final version = BibleVersion.fromCode(entry.key);
        translations[version] = entry.value.toString();
      }
    } else if (json['scriptureText'] != null) {
      // Soporte de compatibilidad para JSONs antiguos con un solo texto
      final legacyText = json['scriptureText'].toString();
      for (final version in BibleVersion.values) {
        translations[version] = legacyText;
      }
    }

    return DevotionalDay(
      id: json['id'] as String? ?? '',
      courseId: json['courseId'] as String? ?? '',
      dayNumber: json['dayNumber'] as int? ?? 1,
      title: json['title'] as String? ?? '',
      scriptureVerse: json['scriptureVerse'] as String? ?? '',
      verseTranslations: translations,
      reflectionText: json['reflectionText'] as String? ?? '',
      reflectionPrompt: json['reflectionPrompt'] as String? ?? '',
      photo: PhotoMetadata.fromJson(json['photo'] as Map<String, dynamic>? ?? {}),
      estimatedMinutes: json['estimatedMinutes'] as int? ?? 7,
      rootWord: json['rootWord'] != null
          ? BiblicalRootWord.fromJson(json['rootWord'] as Map<String, dynamic>)
          : null,
      crossReference: json['crossReference'] as String?,
    );
  }
}

class DevotionalCourse {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String category;
  final AuthorProfile author;
  final String coverImageUrl;
  final int totalDays;
  final List<DevotionalDay> days;

  const DevotionalCourse({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.category,
    required this.author,
    required this.coverImageUrl,
    required this.totalDays,
    required this.days,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'description': description,
        'category': category,
        'author': author.toJson(),
        'coverImageUrl': coverImageUrl,
        'totalDays': totalDays,
        'days': days.map((d) => d.toJson()).toList(),
      };

  factory DevotionalCourse.fromJson(Map<String, dynamic> json) => DevotionalCourse(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        subtitle: json['subtitle'] as String? ?? '',
        description: json['description'] as String? ?? '',
        category: json['category'] as String? ?? 'General',
        author: AuthorProfile.fromJson(json['author'] as Map<String, dynamic>? ?? {}),
        coverImageUrl: json['coverImageUrl'] as String? ?? '',
        totalDays: json['totalDays'] as int? ?? 0,
        days: (json['days'] as List<dynamic>?)
                ?.map((d) => DevotionalDay.fromJson(d as Map<String, dynamic>))
                .toList() ??
            [],
      );
}

class JournalEntry {
  final String id;
  final String courseId;
  final String courseTitle;
  final int dayNumber;
  final String dayTitle;
  final String scriptureReference;
  final String photoThumbnailUrl;
  final String userReflection;
  final DateTime timestamp;

  const JournalEntry({
    required this.id,
    required this.courseId,
    required this.courseTitle,
    required this.dayNumber,
    required this.dayTitle,
    required this.scriptureReference,
    required this.photoThumbnailUrl,
    required this.userReflection,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'courseId': courseId,
        'courseTitle': courseTitle,
        'dayNumber': dayNumber,
        'dayTitle': dayTitle,
        'scriptureReference': scriptureReference,
        'photoThumbnailUrl': photoThumbnailUrl,
        'userReflection': userReflection,
        'timestamp': timestamp.toIso8601String(),
      };

  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(
        id: json['id'] as String? ?? '',
        courseId: json['courseId'] as String? ?? '',
        courseTitle: json['courseTitle'] as String? ?? '',
        dayNumber: json['dayNumber'] as int? ?? 1,
        dayTitle: json['dayTitle'] as String? ?? '',
        scriptureReference: json['scriptureReference'] as String? ?? '',
        photoThumbnailUrl: json['photoThumbnailUrl'] as String? ?? '',
        userReflection: json['userReflection'] as String? ?? '',
        timestamp: json['timestamp'] != null
            ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
            : DateTime.now(),
      );
}
