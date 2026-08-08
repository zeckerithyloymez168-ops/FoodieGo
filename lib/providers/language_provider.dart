import 'package:flutter/material.dart';
import '../utils/app_translations.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;
  String get languageCode => _locale.languageCode;
  bool get isKhmer => _locale.languageCode == 'km';

  String get currentLanguageName => isKhmer ? 'ភាសាខ្មែរ' : 'English';

  void setLocale(Locale loc) {
    if (_locale.languageCode != loc.languageCode) {
      _locale = loc;
      notifyListeners();
    }
  }

  void setLanguageCode(String code) {
    setLocale(Locale(code));
  }

  void toggleLanguage() {
    if (isKhmer) {
      _locale = const Locale('en');
    } else {
      _locale = const Locale('km');
    }
    notifyListeners();
  }

  String tr(String key) {
    return AppTranslations.get(key, _locale.languageCode);
  }
}
