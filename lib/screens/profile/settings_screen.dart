import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/accessibility/a11y.dart';
import '../../core/constants/enums.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = context.tr;
    final themeMode = ref.watch(themeModeProvider);
    final highContrast = ref.watch(highContrastProvider);
    final colorInversion = ref.watch(colorInversionProvider);
    final fontScale = ref.watch(fontScaleProvider);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(tr('settings'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Language ──
          _SectionHeader(title: tr('language'), icon: Icons.language),
          Card(
            child: Column(
              children: AppLanguage.values.map((lang) {
                final isSelected = locale.languageCode == lang.code;
                return A11y.touchTarget(
                  child: RadioListTile<AppLanguage>(
                    value: lang,
                    groupValue: AppLanguage.values.firstWhere(
                        (l) => l.code == locale.languageCode,
                        orElse: () => AppLanguage.fr),
                    title: Text(lang.nativeName),
                    subtitle: Text(lang.name),
                    secondary: isSelected
                        ? const Icon(Icons.check, color: AppColors.primary)
                        : null,
                    onChanged: (v) {
                      if (v != null) {
                        ref.read(localeProvider.notifier).setLocale(v.code);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // ── Theme ──
          _SectionHeader(title: tr('theme'), icon: Icons.palette),
          Card(
            child: Column(
              children: [
                A11y.touchTarget(
                  child: RadioListTile<ThemeMode>(
                    value: ThemeMode.system,
                    groupValue: themeMode,
                    title: Text(tr('system_theme')),
                    secondary: const Icon(Icons.settings_suggest),
                    onChanged: (v) => ref
                        .read(themeModeProvider.notifier)
                        .setThemeMode(v!),
                  ),
                ),
                A11y.touchTarget(
                  child: RadioListTile<ThemeMode>(
                    value: ThemeMode.light,
                    groupValue: themeMode,
                    title: Text(tr('light_theme')),
                    secondary: const Icon(Icons.light_mode),
                    onChanged: (v) => ref
                        .read(themeModeProvider.notifier)
                        .setThemeMode(v!),
                  ),
                ),
                A11y.touchTarget(
                  child: RadioListTile<ThemeMode>(
                    value: ThemeMode.dark,
                    groupValue: themeMode,
                    title: Text(tr('dark_theme')),
                    secondary: const Icon(Icons.dark_mode),
                    onChanged: (v) => ref
                        .read(themeModeProvider.notifier)
                        .setThemeMode(v!),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Accessibility ──
          _SectionHeader(
              title: tr('accessibility'), icon: Icons.accessibility_new),
          Card(
            child: Column(
              children: [
                A11y.touchTarget(
                  child: SwitchListTile(
                    title: Text(tr('high_contrast')),
                    subtitle: Text(tr('high_contrast_desc')),
                    secondary: const Icon(Icons.contrast),
                    value: highContrast,
                    onChanged: (v) =>
                        ref.read(highContrastProvider.notifier).toggle(),
                  ),
                ),
                A11y.touchTarget(
                  child: SwitchListTile(
                    title: Text(tr('color_inversion')),
                    subtitle: Text(tr('color_inversion_desc')),
                    secondary: const Icon(Icons.invert_colors),
                    value: colorInversion,
                    onChanged: (v) =>
                        ref.read(colorInversionProvider.notifier).toggle(),
                  ),
                ),
                const Divider(indent: 16, endIndent: 16),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.text_fields, color: AppColors.primary),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tr('font_size'),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall),
                            Text('${(fontScale * 100).round()}%',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Semantics(
                  label: tr('font_size'),
                  value: '${(fontScale * 100).round()}%',
                  child: Slider(
                    value: fontScale,
                    min: 0.8,
                    max: 1.6,
                    divisions: 8,
                    label: '${(fontScale * 100).round()}%',
                    onChanged: (v) =>
                        ref.read(fontScaleProvider.notifier).setScale(v),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── App Info ──
          _SectionHeader(title: tr('about'), icon: Icons.info_outline),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Running Club Tunis',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Version 1.0.0',
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 8),
                  Text(tr('app_description'),
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
          ),
        ],
      ),
    );
  }
}
