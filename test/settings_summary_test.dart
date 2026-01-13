import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cullr/l10n/app_localizations.dart';
import 'package:cullr/features/swipe/widgets/settings_summary.dart';

void main() {
  testWidgets('SettingsSummary renders localized labels and values', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SettingsSummary(
            swipes: 12,
            deleted: 3,
            deleteBytes: 1048576,
            formatBytes: (bytes) => '${bytes ~/ 1024} KB',
          ),
        ),
      ),
    );

    final BuildContext context = tester.element(find.byType(SettingsSummary));
    final AppLocalizations strings = AppLocalizations.of(context)!;

    expect(find.text(strings.settingsSummaryTitle), findsOneWidget);
    expect(find.text(strings.settingsSummarySwipes), findsOneWidget);
    expect(find.text(strings.settingsSummaryDeleted), findsOneWidget);
    expect(find.text(strings.settingsSummaryDeleteSize), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('1024 KB'), findsOneWidget);
  });
}
