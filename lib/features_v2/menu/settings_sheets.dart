import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trendsoccer/core/providers/language_provider.dart';
import 'package:trendsoccer/core/providers/theme_provider.dart';
import 'package:trendsoccer/design_system/tokens/ts_radius.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';
import 'package:trendsoccer/design_system/widgets/ts_sheet_option_row.dart';
import 'package:trendsoccer/l10n/app_localizations.dart';

Future<void> showLanguageSheet(BuildContext context) {
  final c = Theme.of(context).extension<TsThemeColors>()!;
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: c.scrim,
    isScrollControlled: false,
    useSafeArea: true,
    builder: (_) => const _LanguageSheet(),
  );
}

Future<void> showThemeSheet(BuildContext context) {
  final c = Theme.of(context).extension<TsThemeColors>()!;
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: c.scrim,
    isScrollControlled: false,
    useSafeArea: true,
    builder: (_) => const _ThemeSheet(),
  );
}

class _LanguageSheet extends ConsumerWidget {
  const _LanguageSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(languageProvider);
    final l10n = AppLocalizations.of(context)!;

    return _SettingsSheetShell(
      title: l10n.menuLanguage,
      children: [
        TsSheetOptionRow(
          label: l10n.languageEnglish,
          selected: selected == AppLanguage.en,
          onTap: () => _selectLanguage(context, ref, selected, AppLanguage.en),
        ),
        TsSheetOptionRow(
          label: l10n.languageKorean,
          selected: selected == AppLanguage.ko,
          onTap: () => _selectLanguage(context, ref, selected, AppLanguage.ko),
        ),
      ],
    );
  }

  void _selectLanguage(
    BuildContext context,
    WidgetRef ref,
    AppLanguage current,
    AppLanguage language,
  ) {
    Navigator.pop(context);
    if (current == language) return;
    unawaited(ref.read(languageProvider.notifier).setLanguage(language));
  }
}

class _ThemeSheet extends ConsumerWidget {
  const _ThemeSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(themeModeProvider);
    final l10n = AppLocalizations.of(context)!;

    return _SettingsSheetShell(
      title: l10n.menuTheme,
      children: [
        TsSheetOptionRow(
          label: l10n.menuThemeSystem,
          selected: selected == ThemeMode.system,
          onTap: () => _selectTheme(context, ref, selected, ThemeMode.system),
        ),
        TsSheetOptionRow(
          label: l10n.menuThemeLight,
          selected: selected == ThemeMode.light,
          onTap: () => _selectTheme(context, ref, selected, ThemeMode.light),
        ),
        TsSheetOptionRow(
          label: l10n.menuThemeDark,
          selected: selected == ThemeMode.dark,
          onTap: () => _selectTheme(context, ref, selected, ThemeMode.dark),
        ),
      ],
    );
  }

  void _selectTheme(
    BuildContext context,
    WidgetRef ref,
    ThemeMode current,
    ThemeMode mode,
  ) {
    Navigator.pop(context);
    if (current == mode) return;
    unawaited(ref.read(themeModeProvider.notifier).setThemeMode(mode));
  }
}

class _SettingsSheetShell extends StatelessWidget {
  const _SettingsSheetShell({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: c.canvas,
        borderRadius: TsRadius.topXl,
      ),
      padding: const EdgeInsets.all(TsSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: TsType.h3.copyWith(color: c.textPrimary),
          ),
          const SizedBox(height: TsSpacing.md),
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: TsSpacing.md),
            children[i],
          ],
        ],
      ),
    );
  }
}
