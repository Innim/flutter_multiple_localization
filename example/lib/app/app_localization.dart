import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:multiple_localization/multiple_localization.dart';

import 'l10n/messages_all.dart';
import 'package:intl/intl.dart';

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return MultipleLocalizations.load(
        initializeMessages, locale, (l) => AppLocalizations(l),
        setDefaultLocale: true);
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => false;
}

/// App localization.
class AppLocalizations {
  /// Delegate.
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  final String locale;

  AppLocalizations(this.locale) : assert(locale != null);

  String get title => Intl.message('Multiple localization', name: 'title');

  String get messageFromApp =>
      Intl.message('Default Message from App', name: 'messageFromApp');

  String get messageFromPackageForOverride =>
      Intl.message('Default overrided message from Package',
          name: 'messageFromPackageForOverride');
}
