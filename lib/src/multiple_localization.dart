import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
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
  static _MultipleLocalizationLookup? _lookup;

  static _MultipleLocalizationLookup _init(String? fallbackLocale) {
    assert(intl_private.messageLookup is intl_private.UninitializedLocaleData);
    final lookup = _MultipleLocalizationLookup(fallbackLocale: fallbackLocale);
    intl_private.initializeInternalMessageLookup(() => lookup);
    return lookup;
  }

  // only for tests!
  @visibleForTesting
  static void reset() {
    _lookup = null;
    intl_private.messageLookup = intl_private.UninitializedLocaleData(
        'initializeMessages(<locale>)', null);
  }

  /// Load messages for localization and create localization instance.
  ///
  /// Use [setDefaultLocale] to set loaded locale as [Intl.defaultLocale].
  ///
  /// Use [fallbackLocale] to set locale which will be used if some key
  /// not found for current locale. Only first call of [load] will set
  /// fallback locale, make sure that your app's localization delegate
  /// added as a first element of the delegates list.
  /// Also pay attention that if you provide the [fallbackLocale],
  /// than all messages will be uploaded in memory on the start of application
  /// in addition to current locale.
  static Future<T> load<T>(InitializeMessages initializeMessages, Locale locale,
      FutureOr<T> Function(String locale) builder,
      {bool setDefaultLocale = false, String? fallbackLocale}) async {
    final lookup = _lookup ??= _init(fallbackLocale != null
        ? Intl.canonicalizedLocale(fallbackLocale)
        : null);
    final name = locale.toString();
    final localeName = Intl.canonicalizedLocale(name);

    final res = await initializeMessages(localeName).then((_) {
      if (setDefaultLocale) {
        Intl.defaultLocale = localeName;
      }

      return builder(localeName);
    });

    final fallbackLocaleName = lookup.fallbackLocale;
    if (fallbackLocaleName != null && fallbackLocaleName != localeName) {
      // load messages for fallback locale, so it can be used if some key was not found
      await initializeMessages(fallbackLocaleName);
    }

    return res;
  }
}

class _MultipleLocalizationLookup implements intl_private.MessageLookup {
  final Map<Function, CompositeMessageLookup> _lookups = {};
  final String? fallbackLocale;

  _MultipleLocalizationLookup({this.fallbackLocale});

  @override
  void addLocale(String localeName, Function findLocale) {
    final lookup = _lookups.putIfAbsent(
      findLocale,
      () => CompositeMessageLookup(),
    );

    lookup.addLocale(localeName, findLocale);
  }

  @override
  String? lookupMessage(String? messageStr, String? locale, String? name,
      List<Object>? args, String? meaning,
      {MessageIfAbsent? ifAbsent}) {
    for (final lookup in _lookups.values) {
      var isAbsent = false;
      final res = lookup.lookupMessage(messageStr, locale, name, args, meaning,
          ifAbsent: (s, a) {
        isAbsent = true;
        return '';
      });

      if (!isAbsent) return res;
    }

    // TODO: может тут Intl.canonicalizedLocale(fallbackLocale)?
    if (locale != fallbackLocale) {
      return lookupMessage(messageStr, fallbackLocale, name, args, meaning,
          ifAbsent: ifAbsent);
    } else {
      return ifAbsent == null ? messageStr : ifAbsent(messageStr, args);
    }
  }
}
