import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:multiple_localization/multiple_localization.dart';

import 'l10n/messages_all.dart';
import 'package:intl/intl.dart';

class _PackageLocalizationsDelegate
    extends LocalizationsDelegate<PackageLocalizations> {
  const _PackageLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en'].contains(locale.languageCode);

  @override
  Future<PackageLocalizations> load(Locale locale) {
    return MultipleLocalizations.load(
        initializeMessages, locale, (l) => PackageLocalizations(l));
  }

  @override
  bool shouldReload(LocalizationsDelegate<PackageLocalizations> old) => false;
}

/// Package localization.
class PackageLocalizations {
  /// Delegate.
  static const LocalizationsDelegate<PackageLocalizations> delegate =
      _PackageLocalizationsDelegate();

  static PackageLocalizations of(BuildContext context) {
    return Localizations.of<PackageLocalizations>(
        context, PackageLocalizations);
  }

  final String locale;

  PackageLocalizations(this.locale) : assert(locale != null);

  String get messageFromPackage =>
      Intl.message('Default Message from Package', name: 'messageFromPackage');

  String get messageFromPackageForOverride =>
      Intl.message('Default Message from Package for override',
          name: 'messageFromPackageForOverride');
}
