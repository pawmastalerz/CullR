import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/app_localizations.dart';

import 'core/di/app_composition.dart';
import 'core/l10n/locale_controller.dart';
import 'features/swipe/application/state/swipe_session.dart';
import 'features/swipe/presentation/pages/swipe_home_page.dart';
import 'styles/colors.dart';
import 'styles/typography.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final Locale savedLocale = await LocaleController.resolveInitialLocale(
    AppLocalizations.supportedLocales,
  );
  final AppComposition composition = AppComposition();
  final SwipeSession swipeSession = composition.buildSwipeSession();
  runApp(MyApp(initialLocale: savedLocale, swipeSession: swipeSession));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.initialLocale, required this.swipeSession});

  final Locale initialLocale;
  final SwipeSession swipeSession;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final LocaleController _localeController = LocaleController(
    initial: widget.initialLocale,
  );

  @override
  void dispose() {
    widget.swipeSession.dispose();
    _localeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _localeController,
      builder: (context, _) {
        return MaterialApp(
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          locale: _localeController.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            if (locale == null) {
              return supportedLocales.first;
            }
            for (final supported in supportedLocales) {
              if (supported.languageCode == locale.languageCode &&
                  (supported.countryCode == null ||
                      supported.countryCode == locale.countryCode)) {
                return supported;
              }
            }
            return supportedLocales.first;
          },
          theme: ThemeData.dark(useMaterial3: true).copyWith(
            scaffoldBackgroundColor: AppColors.bgCanvas,
            colorScheme: const ColorScheme.dark(
              primary: AppColors.textPrimary,
              onPrimary: AppColors.bgCanvas,
              secondary: AppColors.accentGreen,
              onSecondary: AppColors.accentGreenOn,
              tertiary: AppColors.accentAmber,
              onTertiary: AppColors.accentAmberOn,
              error: AppColors.accentRed,
              onError: AppColors.accentRedOn,
              surface: AppColors.bgSurface,
              onSurface: AppColors.textPrimary,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: AppColors.bgSurface,
              foregroundColor: AppColors.textPrimary,
              elevation: 0,
            ),
            textTheme: AppTypography.textTheme,
            iconTheme: const IconThemeData(color: AppColors.textPrimary),
            dividerColor: AppColors.borderSubtle,
          ),
          home: SwipeHomePage(
            localeController: _localeController,
            session: widget.swipeSession,
          ),
        );
      },
    );
  }
}
