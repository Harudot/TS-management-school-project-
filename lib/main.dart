import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ts_management/core/accessibility/accessibility_controller.dart';
import 'package:ts_management/core/firebase/firebase_init.dart';
import 'package:ts_management/core/i18n/locale_controller.dart';
import 'package:ts_management/core/router/app_router.dart';
import 'package:ts_management/core/theme/app_theme.dart';
import 'package:ts_management/core/theme/theme_controller.dart';
import 'package:ts_management/domain/services/notifications_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initFirebase();
  await NotificationsService.instance.init();
  runApp(const ProviderScope(child: SmartCampusApp()));
}

class SmartCampusApp extends ConsumerWidget {
  const SmartCampusApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeControllerProvider);
    final locale = ref.watch(localeControllerProvider);
    final a11y = ref.watch(accessibilityControllerProvider);

    return MaterialApp.router(
      title: 'Smart Campus',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(highContrast: a11y.highContrast),
      darkTheme: AppTheme.dark(highContrast: a11y.highContrast),
      themeMode: themeMode,
      locale: locale,
      supportedLocales: LocaleController.supported,
      routerConfig: router,
      builder: (context, child) {
        if (child == null) return const SizedBox.shrink();
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: TextScaler.linear(a11y.textScale),
            boldText: a11y.boldText,
            disableAnimations: a11y.reduceMotion,
          ),
          child: child,
        );
      },
    );
  }
}
