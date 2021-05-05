import 'dart:async';
import 'dart:ui';

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

  static void _init() {
    assert(intl_private.messageLookup is intl_private.UninitializedLocaleData);
    _lookup = _MultipleLocalizationLookup();
    intl_private.initializeInternalMessageLookup(() => _lookup);
  }

  /// Load messages for localization and create localization instance.
  ///
  /// Use [setDefaultLocale] to set loaded locale as [Intl.defaultLocale].
  static Future<T> load<T>(InitializeMessages initializeMessages, Locale locale,
      FutureOr<T> Function(String locale) builder,
      {bool setDefaultLocale = false}) {
    if (_lookup == null) _init();
    final name = locale.toString();
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
  final Map<Function, CompositeMessageLookup> _lookups = {};

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

    return ifAbsent == null ? messageStr : ifAbsent(messageStr, args);
  }
}
