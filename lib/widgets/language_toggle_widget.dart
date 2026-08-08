import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/language_provider.dart';
import '../theme/app_theme.dart';

enum LanguageToggleStyle { pill, compact, tile }

class LanguageToggleWidget extends StatelessWidget {
  final LanguageToggleStyle style;

  const LanguageToggleWidget({
    super.key,
    this.style = LanguageToggleStyle.pill,
  });

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    if (style == LanguageToggleStyle.compact) {
      return InkWell(
        onTap: () => lang.toggleLanguage(),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.emerald600.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.emerald600.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                lang.isKhmer ? '🇰🇭' : '🇬🇧',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 6),
              Text(
                lang.isKhmer ? 'KM' : 'EN',
                style: const TextStyle(
                  color: AppColors.emerald700,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (style == LanguageToggleStyle.tile) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.emerald500.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.language_rounded, color: AppColors.emerald600),
          ),
          title: Text(
            lang.tr('language'),
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          subtitle: Text(
            lang.currentLanguageName,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          trailing: _buildPillToggle(context, lang),
        ),
      );
    }

    return _buildPillToggle(context, lang);
  }

  Widget _buildPillToggle(BuildContext context, LanguageProvider lang) {
    return Container(
      height: 40,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SegmentChip(
            label: '🇬🇧 EN',
            active: !lang.isKhmer,
            onTap: () => lang.setLanguageCode('en'),
          ),
          _SegmentChip(
            label: '🇰🇭 ខ្មែរ',
            active: lang.isKhmer,
            onTap: () => lang.setLanguageCode('km'),
          ),
        ],
      ),
    );
  }
}

class _SegmentChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _SegmentChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.emerald600 : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: AppColors.emerald600.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : AppColors.textSecondary,
            fontWeight: active ? FontWeight.w800 : FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
