import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/language_service.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageService>(
      builder: (context, languageService, child) {
        return PopupMenuButton<String>(
          icon: const Icon(Icons.language),
          onSelected: (String languageCode) {
            languageService.changeLanguage(languageCode);
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem<String>(
              value: 'en',
              child: Text('English'),
            ),
            const PopupMenuItem<String>(
              value: 'fr',
              child: Text('Français'),
            ),
            const PopupMenuItem<String>(
              value: 'ar',
              child: Text('العربية'),
            ),
          ],
        );
      },
    );
  }
}
