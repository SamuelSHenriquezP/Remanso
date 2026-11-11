import 'package:flutter/material.dart';
import '../theme/remanso_theme.dart';
import 'home_screen.dart';
import 'courses_screen.dart';
import 'journal_archive_screen.dart';
import 'splash_wave_screen.dart';

/// Shell principal de navegación para Remanso.
/// Hospeda las 3 secciones principales mediante una barra de navegación refinada,
/// limpia y simétrica sobre fondo blanco puro con indicador lírico sutil.
class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;
  bool _showingWaveSplash = true; // Comienza con la experiencia de ola reveladora

  void _onWaveSplashCompleted() {
    setState(() {
      _showingWaveSplash = false;
    });
  }

  void _triggerWaveSplashManually() {
    setState(() {
      _showingWaveSplash = true;
    });
  }

  void _navigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(
        onTriggerWaveSplash: _triggerWaveSplashManually,
        onExploreCourses: () => _navigateToTab(1),
      ),
      const CoursesScreen(),
      const JournalArchiveScreen(),
    ];

    final bottomNav = Container(
      decoration: BoxDecoration(
        color: const Color(0xF00D1524),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.08),
            width: 0.8,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: _buildNavItem(
                  index: 0,
                  icon: Icons.spa_outlined,
                  activeIcon: Icons.spa_rounded,
                  label: 'Orden Diario',
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  index: 1,
                  icon: Icons.auto_stories_outlined,
                  activeIcon: Icons.auto_stories_rounded,
                  label: 'Planes',
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  index: 2,
                  icon: Icons.edit_note_rounded,
                  activeIcon: Icons.edit_note_rounded,
                  label: 'Mi Diario',
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: RemansoTheme.scaffoldLinen,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Interfaz principal lista y posicionada en el lienzo
          Scaffold(
            backgroundColor: RemansoTheme.scaffoldLinen,
            body: AnimatedSwitcher(
              duration: const Duration(milliseconds: 320),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: screens[_currentIndex],
            ),
            bottomNavigationBar: bottomNav,
          ),

          // 2. Capa de bienvenida lírica que asciende de forma directa
          if (_showingWaveSplash)
            SplashWaveScreen(
              onComplete: _onWaveSplashCompleted,
            ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    IconData? activeIcon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => _navigateToTab(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF2EC4B6).withOpacity(0.20)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                isSelected && activeIcon != null ? activeIcon : icon,
                size: 20,
                color: isSelected
                    ? const Color(0xFF2EC4B6)
                    : const Color(0xFF7E92B0),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: RemansoTheme.uiFont(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : const Color(0xFF7E92B0),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
