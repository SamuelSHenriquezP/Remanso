import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'data/devotional_repository.dart';
import 'screens/main_navigation_shell.dart';
import 'theme/remanso_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar barra de estado y navegación del sistema con tonos cálidos y orgánicos
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: RemansoTheme.surfacePure,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Inicializar repositorio local y cargar persistencia
  final repository = DevotionalRepository();
  await repository.initialize();

  runApp(const RemansoApp());
}

/// Remanso: Aplicación de devocionales diarios y fotografía contemplativa.
/// Experiencia 100% offline-first, privada y editorial con temas dinámicos.
class RemansoApp extends StatelessWidget {
  const RemansoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = DevotionalRepository();

    return ListenableBuilder(
      listenable: repo,
      builder: (context, _) {
        final isDark = repo.currentThemePalette.isDark;

        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
            systemNavigationBarColor: RemansoTheme.surfacePure,
            systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          ),
        );

        return MaterialApp(
          title: 'Remanso',
          debugShowCheckedModeBanner: false,
          theme: RemansoTheme.themeData,
          home: const MainNavigationShell(),
        );
      },
    );
  }
}

// Alias para retrocompatibilidad
typedef SelahApp = RemansoApp;
