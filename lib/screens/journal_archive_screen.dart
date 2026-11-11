import 'package:flutter/material.dart';
import '../data/devotional_repository.dart';
import '../models/devotional_models.dart';
import '../theme/remanso_theme.dart';
import '../widgets/ken_burns_image.dart';
import '../widgets/wave_widgets.dart';

/// Módulo 4: Mi Diario & Archivo Fotográfico
/// Vista dual editorial dividida por pestañas limpias:
/// - Pestaña 1: Mis Oraciones (Buscador, historial cronológico de notas, miniaturas).
/// - Pestaña 2: Archivo "Detrás de la Lente" (Galería contemplativa de fotos con fichas técnicas).
class JournalArchiveScreen extends StatefulWidget {
  const JournalArchiveScreen({super.key});

  @override
  State<JournalArchiveScreen> createState() => _JournalArchiveScreenState();
}

class _JournalArchiveScreenState extends State<JournalArchiveScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final DevotionalRepository _repo = DevotionalRepository();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _openPhotoInspector(PhotoMetadata photo, String title, String scripture) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PhotoInspectorSheet(
        photo: photo,
        title: title,
        scripture: scripture,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _repo,
      builder: (context, child) {
        final journalEntries = _repo.searchJournal(_searchQuery);

        return Scaffold(
          backgroundColor: RemansoTheme.scaffoldLinen,
          appBar: AppBar(
            title: Text(
              'Diario & Fotografía',
              style: RemansoTheme.displayFont(
                fontSize: 22,
                fontWeight: FontWeight.w500,
              ),
            ),
            automaticallyImplyLeading: false,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(54),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: RemansoTheme.surfaceStone,
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(color: RemansoTheme.borderSubtle),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: RemansoTheme.textCharcoal,
                  unselectedLabelColor: RemansoTheme.textMuted,
                  labelStyle: RemansoTheme.uiFont(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'Mis Oraciones'),
                    Tab(text: 'Detrás de la Lente'),
                  ],
                ),
              ),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildPrayersTab(journalEntries),
              _buildPhotoArchiveTab(),
            ],
          ),
        );
      },
    );
  }

  // --- PESTAÑA 1: MIS ORACIONES ---
  Widget _buildPrayersTab(List<JournalEntry> entries) {
    return Column(
      children: [
        // Buscador editorial
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
          child: Container(
            decoration: BoxDecoration(
              color: RemansoTheme.surfacePure,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: RemansoTheme.borderSubtle, width: 1),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              style: RemansoTheme.uiFont(
                fontSize: 13.5,
                color: RemansoTheme.textCharcoal,
              ),
              decoration: InputDecoration(
                hintText: 'Buscar por oración, día o pasaje bíblico...',
                hintStyle: RemansoTheme.uiFont(
                  fontSize: 13,
                  color: RemansoTheme.textSubtle,
                ),
                prefixIcon: Icon(Icons.search_rounded, size: 20, color: RemansoTheme.textSubtle),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
        ),

        // Lista de entradas o estado vacío
        Expanded(
          child: entries.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  itemCount: entries.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return TactilePressCard(
                      child: _buildJournalCard(entry),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildJournalCard(JournalEntry entry) {
    final dateFormatted =
        '${entry.timestamp.day}/${entry.timestamp.month}/${entry.timestamp.year} • ${_formatTime(entry.timestamp)}';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: RemansoTheme.surfacePure,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: RemansoTheme.borderSubtle, width: 1),
        boxShadow: RemansoTheme.subtleShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera de la nota
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  entry.photoThumbnailUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 50,
                    height: 50,
                    color: RemansoTheme.surfaceStone,
                    child: Icon(Icons.spa, color: RemansoTheme.accentForest, size: 20),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateFormatted,
                      style: RemansoTheme.labelFont(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: RemansoTheme.accentTerracotta,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Día ${entry.dayNumber}: ${entry.dayTitle}',
                      style: RemansoTheme.displayFont(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: RemansoTheme.textCharcoal,
                      ),
                    ),
                    Text(
                      entry.scriptureReference,
                      style: RemansoTheme.uiFont(
                        fontSize: 11.5,
                        color: RemansoTheme.textSubtle,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert_rounded, size: 18, color: RemansoTheme.textSubtle),
                onSelected: (val) async {
                  if (val == 'delete') {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: RemansoTheme.surfacePure,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        title: Text(
                          '¿Eliminar esta oración?',
                          style: RemansoTheme.displayFont(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: RemansoTheme.textCharcoal,
                          ),
                        ),
                        content: Text(
                          'Esta reflexión se borrará de forma permanente de tu diario privado local.',
                          style: RemansoTheme.uiFont(
                            fontSize: 13,
                            color: RemansoTheme.textMuted,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: Text(
                              'Cancelar',
                              style: RemansoTheme.uiFont(
                                color: RemansoTheme.textSubtle,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: const Text(
                              'Eliminar',
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      _repo.deleteJournalEntry(entry.id);
                    }
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                        SizedBox(width: 8),
                        Text('Eliminar Oración', style: TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Texto de la oración personal en Newsreader
          Text(
            entry.userReflection,
            style: RemansoTheme.readingFont(
              fontSize: 15.5,
              color: RemansoTheme.textCharcoal,
              height: 1.62,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: RemansoTheme.surfaceStone,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.menu_book_rounded,
                  color: RemansoTheme.accentForest, size: 30),
            ),
            const SizedBox(height: 18),
            Text(
              'Tu diario está en espera',
              style: RemansoTheme.displayFont(
                fontSize: 22,
                color: RemansoTheme.textCharcoal,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Al completar tu devocional del día, tus oraciones y reflexiones se guardarán de forma 100% privada aquí.',
              textAlign: TextAlign.center,
              style: RemansoTheme.uiFont(
                fontSize: 13,
                color: RemansoTheme.textMuted,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final minuteStr = dt.minute < 10 ? '0${dt.minute}' : '${dt.minute}';
    final hourStr = dt.hour < 10 ? '0${dt.hour}' : '${dt.hour}';
    return '$hourStr:$minuteStr';
  }

  // --- PESTAÑA 2: ARCHIVO "DETRÁS DE LA LENTE" ---
  Widget _buildPhotoArchiveTab() {
    final List<_PhotoArchiveItem> items = [];
    for (final course in _repo.courses) {
      for (final day in course.days) {
        items.add(_PhotoArchiveItem(
          photo: day.photo,
          courseTitle: course.title,
          dayTitle: day.title,
          scripture: day.scriptureVerse,
          dayNumber: day.dayNumber,
        ));
      }
    }

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 16,
        childAspectRatio: 0.72,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return TactilePressCard(
          onTap: () => _openPhotoInspector(item.photo, item.dayTitle, item.scripture),
          child: Container(
            decoration: BoxDecoration(
              color: RemansoTheme.surfacePure,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: RemansoTheme.borderSubtle, width: 1),
              boxShadow: RemansoTheme.subtleShadow,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          item.photo.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: RemansoTheme.surfaceStone,
                            child: Icon(Icons.image, color: RemansoTheme.textSubtle),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.55),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              item.photo.focalLength,
                              style: RemansoTheme.labelFont(
                                fontSize: 9,
                                color: RemansoTheme.accentSand,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.dayTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: RemansoTheme.displayFont(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: RemansoTheme.textCharcoal,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.photo.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: RemansoTheme.uiFont(
                            fontSize: 10.5,
                            color: RemansoTheme.textSubtle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PhotoArchiveItem {
  final PhotoMetadata photo;
  final String courseTitle;
  final String dayTitle;
  final String scripture;
  final int dayNumber;

  _PhotoArchiveItem({
    required this.photo,
    required this.courseTitle,
    required this.dayTitle,
    required this.scripture,
    required this.dayNumber,
  });
}

/// Sheet modal para apreciar la fotografía con Ken Burns y ficha técnica completa
class _PhotoInspectorSheet extends StatelessWidget {
  final PhotoMetadata photo;
  final String title;
  final String scripture;

  const _PhotoInspectorSheet({
    required this.photo,
    required this.title,
    required this.scripture,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: RemansoTheme.scaffoldLinen,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          // Barra de agarre
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: RemansoTheme.borderSubtle,
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: KenBurnsPhoto(
                      imageUrl: photo.imageUrl,
                      heroTag: 'archive_${photo.imageUrl}',
                      height: 280,
                      width: double.infinity,
                      captionTitle: title,
                      captionSubtitle: photo.location,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    scripture,
                    style: RemansoTheme.labelFont(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: RemansoTheme.accentTerracotta,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: RemansoTheme.displayFont(
                      fontSize: 25,
                      fontWeight: FontWeight.w400,
                      color: RemansoTheme.textCharcoal,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Ficha técnica en caja editorial
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: RemansoTheme.surfacePure,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: RemansoTheme.borderSubtle, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.tune_rounded, size: 15, color: RemansoTheme.accentForest),
                            const SizedBox(width: 8),
                            Text(
                              'PARÁMETROS DE CAPTURA',
                              style: RemansoTheme.labelFont(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                                color: RemansoTheme.accentForest,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _buildRow('Cámara', photo.camera),
                        _buildRow('Lente', photo.lens),
                        _buildRow('Parámetros', '${photo.aperture} • ${photo.shutterSpeed} • ${photo.iso}'),
                        _buildRow('Lugar', photo.location),
                        _buildRow('Luz', photo.timeOfDay),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Historia espiritual
                  Text(
                    'DETRÁS DE LA LENTE (HISTORIA ESPIRITUAL)',
                    style: RemansoTheme.labelFont(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: RemansoTheme.accentForest,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    photo.spiritualBehindTheLens,
                    style: RemansoTheme.readingFont(
                      fontSize: 15.5,
                      color: RemansoTheme.textCharcoal,
                      height: 1.68,
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: RemansoTheme.uiFont(
                fontSize: 11.5,
                color: RemansoTheme.textMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: RemansoTheme.uiFont(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: RemansoTheme.textCharcoal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
