import 'package:flutter/material.dart';

import '../../../styles/colors.dart';
import '../../../styles/spacing.dart';
import '../../../styles/typography.dart';
import '../../../l10n/app_localizations.dart';

class LanguagePicker extends StatelessWidget {
  const LanguagePicker({
    super.key,
    required this.selectedLocale,
    required this.onChanged,
  });

  final Locale selectedLocale;
  final Future<void> Function(Locale) onChanged;

  @override
  Widget build(BuildContext context) {
    final List<_LanguageOption> options = _LanguageOption.options;

    return Row(
      children: [
        Text(
          AppLocalizations.of(context)!.languageLabel,
          style: AppTypography.textTheme.bodyLarge,
        ),
        const Spacer(),
        _LanguageDropdown(
          options: options,
          selectedLocale: selectedLocale,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _LanguageDropdown extends StatelessWidget {
  const _LanguageDropdown({
    required this.options,
    required this.selectedLocale,
    required this.onChanged,
  });

  final List<_LanguageOption> options;
  final Locale selectedLocale;
  final Future<void> Function(Locale) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.borderStrong),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Locale>(
          value: selectedLocale,
          icon: const Icon(Icons.expand_more, color: AppColors.textSecondary),
          dropdownColor: AppColors.bgSurface,
          onChanged: (value) async {
            if (value == null) {
              return;
            }
            await onChanged(value);
          },
          items: options.map((option) {
            return DropdownMenuItem<Locale>(
              value: option.locale,
              child: Row(
                children: [
                  Text(
                    option.flag,
                    style: AppTypography.textTheme.bodyLarge?.copyWith(
                      fontSize: AppSpacing.flagSize,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(option.label, style: AppTypography.textTheme.bodyMedium),
                ],
              ),
            );
          }).toList(),
          selectedItemBuilder: (context) {
            return options.map((option) {
              return Row(
                children: [
                  Text(
                    option.flag,
                    style: AppTypography.textTheme.bodyLarge?.copyWith(
                      fontSize: AppSpacing.flagSize,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(option.label, style: AppTypography.textTheme.bodyLarge),
                ],
              );
            }).toList();
          },
        ),
      ),
    );
  }
}

class _LanguageOption {
  const _LanguageOption(this.locale, this.flag, this.label);

  final Locale locale;
  final String flag;
  final String label;

  static const List<_LanguageOption> options = [
    _LanguageOption(Locale('ar'), '🇸🇦', 'العربية'),
    _LanguageOption(Locale('de'), '🇩🇪', 'Deutsch'),
    _LanguageOption(Locale('en'), '🇬🇧', 'English'),
    _LanguageOption(Locale('es'), '🇪🇸', 'Español'),
    _LanguageOption(Locale('fi'), '🇫🇮', 'Suomi'),
    _LanguageOption(Locale('fr'), '🇫🇷', 'Français'),
    _LanguageOption(Locale('hi'), '🇮🇳', 'हिन्दी'),
    _LanguageOption(Locale('id'), '🇮🇩', 'Bahasa Indonesia'),
    _LanguageOption(Locale('it'), '🇮🇹', 'Italiano'),
    _LanguageOption(Locale('ja'), '🇯🇵', '日本語'),
    _LanguageOption(Locale('ko'), '🇰🇷', '한국어'),
    _LanguageOption(Locale('nl'), '🇳🇱', 'Nederlands'),
    _LanguageOption(Locale('pl'), '🇵🇱', 'Polski'),
    _LanguageOption(Locale('pt'), '🇵🇹', 'Português'),
    _LanguageOption(Locale('sv'), '🇸🇪', 'Svenska'),
    _LanguageOption(Locale('tr'), '🇹🇷', 'Türkçe'),
    _LanguageOption(Locale('uk'), '🇺🇦', 'Українська'),
  ];
}
