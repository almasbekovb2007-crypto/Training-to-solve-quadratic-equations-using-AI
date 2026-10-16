import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

/// Виджет для выбора языка
class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLanguageButton(
            context,
            'RU',
            const Locale('ru'),
            'Русский',
          ),
          _buildDivider(),
          _buildLanguageButton(
            context,
            'EN',
            const Locale('en'),
            'English',
          ),
          _buildDivider(),
          _buildLanguageButton(
            context,
            'KG',
            const Locale('ky'),
            'Кыргызча',
          ),
        ],
      ),
    );
  }

  /// Построение кнопки языка
  Widget _buildLanguageButton(
    BuildContext context,
    String shortCode,
    Locale locale,
    String fullName,
  ) {
    final isSelected = context.locale == locale;
    
    return InkWell(
      onTap: () => _changeLanguage(context, locale),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              shortCode,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.blue : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              fullName,
              style: TextStyle(
                fontSize: 8,
                color: isSelected ? Colors.blue : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Разделитель между кнопками
  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 24,
      color: Colors.grey[300],
    );
  }

  /// Изменение языка
  void _changeLanguage(BuildContext context, Locale locale) {
    context.setLocale(locale);
    // Force immediate rebuild of the entire app
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        (context as Element).markNeedsBuild();
      }
    });
  }
}
