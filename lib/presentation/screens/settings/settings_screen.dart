import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../state/app_settings_scope.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settingsController = AppSettingsScope.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.settingsDescription,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.language_outlined),
            title: Text(l10n.languageSetting),
            subtitle: Text(l10n.languageSettingSubtitle),
            trailing: DropdownButton<Locale>(
              value: settingsController.locale,
              items: AppLocalizations.supportedLocales
                  .map(
                    (locale) => DropdownMenuItem<Locale>(
                      value: locale,
                      child: Text(
                        locale.languageCode == 'es'
                            ? l10n.languageSpanish
                            : l10n.languageEnglish,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (Locale? locale) {
                if (locale != null) {
                  settingsController.updateLocale(locale);
                }
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.fingerprint),
            title: Text(l10n.authenticationTitle),
            subtitle: Text(l10n.authenticationMessage),
          ),
        ],
      ),
    );
  }
}
