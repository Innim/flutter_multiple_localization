import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

// this helper if not for direct use,
// it's internal, but I haven't find any good way
// to implement desired behavior
// ignore: implementation_imports
import 'package:intl/src/intl_helpers.dart' as intl_private;

// ignore: implementation_imports
import 'package:intl/src/intl_helpers.dart' show MessageIfAbsent;

/// Function for initialize messages.
/// It's will be `initializeMessages` from generated code.
typedef InitializeMessages = Future<bool> Function(String localeName);

/// Use [MultipleLocalizations.load] to implement load function in your localization delegate,
/// instead of call `initializeMessages` explicitly.
///
/// Example:
/// ```dart
/// class _AppLocalizationsDelegate
///     extends LocalizationsDelegate<AppLocalizations> {
///   const _AppLocalizationsDelegate();
///
///   @override
///   bool isSupported(Locale locale) {
///     return ['en', 'ru'].contains(locale.languageCode);
///   }
///
///   @override
///   Future<AppLocalizations> load(Locale locale) {
///     return MultipleLocalizations.load(
///         initializeMessages, locale, (l) => AppLocalizations(l),
///         setDefaultLocale: true);
///   }
///
///   @override
///   bool shouldReload(LocalizationsDelegate<AppLocalizations> old) {
///     return false;
///   }
/// }
///```
class MultipleLocalizations {
  static _MultipleLocalizationLookup _lookup;
  static bool _pendingReset = false;

  static void _init() {
    assert(intl_private.messageLookup is intl_private.UninitializedLocaleData);
    _lookup = _MultipleLocalizationLookup();
    intl_private.initializeInternalMessageLookup(() => _lookup);
  }

  /// Load messages for localization and create localization instance.
  ///
  /// Use [setDefaultLocale] to set loaded locale as [Intl.defaultLocale].
  static Future<T> load<T>(InitializeMessages initializeMessages, Locale locale,
      T builder(String locale),
      {bool setDefaultLocale = false}) {
    if (_pendingReset) {
      _pendingReset = false;
      _lookup = null;
      intl_private.messageLookup = intl_private.UninitializedLocaleData(
        'initializeMessages(<locale>)',
        null,
      );
    }

    if (_lookup == null) _init();
    final name = (locale.countryCode?.isEmpty ?? true)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);

    return initializeMessages(localeName).then((_) {
      if (setDefaultLocale) {
        Intl.defaultLocale = localeName;
      }

      return builder(localeName);
    });
  }
}

class _MultipleLocalizationLookup implements intl_private.MessageLookup {
  final List<CompositeMessageLookup> _lookups = [];

  @override
  void addLocale(String localeName, Function findLocale) {
    CompositeMessageLookup lookup;
    for (final item in _lookups) {
      if (!item.localeExists(localeName)) {
        lookup = item;
        break;
      }
    }

    if (lookup == null) {
      lookup = CompositeMessageLookup();
      _lookups.add(lookup);
    }

    lookup.addLocale(localeName, findLocale);
  }

  @override
  String lookupMessage(String messageStr, String locale, String name,
      List<Object> args, String meaning,
      {MessageIfAbsent ifAbsent}) {
    for (final lookup in _lookups) {
      final res = lookup.lookupMessage(messageStr, locale, name, args, meaning,
          ifAbsent: (s, a) => null);
      if (res != null) return res;
    }

    return ifAbsent == null ? messageStr : ifAbsent(messageStr, args);
  }
}

/// Must be the last in App's localizationsDelegates list.
class ResetLocalizationsDelegate extends LocalizationsDelegate<Object> {
  static const LocalizationsDelegate<Object> delegate =
  ResetLocalizationsDelegate();

  const ResetLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<Object> load(Locale locale) async {
    MultipleLocalizations._pendingReset = true;
    return Object();
  }

  @override
  bool shouldReload(LocalizationsDelegate<Object> old) => false;
}
