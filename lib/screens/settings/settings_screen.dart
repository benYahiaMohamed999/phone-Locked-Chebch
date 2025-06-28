import 'package:flutter/material.dart';
import 'package:phone_store_mangment/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          localizations.settings,
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            context,
            title: localizations.appearance,
            children: [
              SwitchListTile(
                title: Text(localizations.darkMode),
                subtitle: Text(localizations.darkModeDescription),
                value: themeProvider.isDarkMode,
                onChanged: (value) => themeProvider.toggleTheme(),
                secondary: Icon(
                  themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            title: localizations.language,
            children: [
              RadioListTile<String>(
                title: Text(localizations.english),
                value: 'en',
                groupValue: localeProvider.locale.languageCode,
                onChanged: (value) {
                  if (value != null) {
                    localeProvider.setLocale(Locale(value));
                  }
                },
              ),
              RadioListTile<String>(
                title: Text(localizations.french),
                value: 'fr',
                groupValue: localeProvider.locale.languageCode,
                onChanged: (value) {
                  if (value != null) {
                    localeProvider.setLocale(Locale(value));
                  }
                },
              ),
              RadioListTile<String>(
                title: Text(localizations.arabic),
                value: 'ar',
                groupValue: localeProvider.locale.languageCode,
                onChanged: (value) {
                  if (value != null) {
                    localeProvider.setLocale(Locale(value));
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            title: localizations.account,
            children: [
              ListTile(
                leading: Icon(
                  Icons.logout,
                  color: theme.colorScheme.error,
                ),
                title: Text(
                  localizations.logoutButton,
                  style: TextStyle(
                    color: theme.colorScheme.error,
                  ),
                ),
                onTap: () => _showLogoutConfirmation(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Card(
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Future<void> _showLogoutConfirmation(BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.logout),
        content: Text(localizations.logoutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              localizations.logoutButton,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signOut(context);
    }
  }
}
