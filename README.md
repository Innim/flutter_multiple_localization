# multiple_localization

[![pub package](https://img.shields.io/pub/v/multiple_localization)](https://pub.dartlang.org/packages/multiple_localization)

Support for multiple abr and messages localization files for [intl](https://pub.dev/packages/intl) package.

## Problem

If you want to have multiple arb files and register separate delegate for each one of them,
then you have a problem. Intl doesn't allow multiple `initializeMessages` calls. Only
first one will be processed and only it's messages will be used. Every calls after the first one
will be ignored.

Also when using `Localizations.override(delegates: [SomeLocalizationsDelegate(), ...])` somewhere in widgets tree, `initializeMessages`are called every time, when that widget rebuilds. And that will lead to adding more and more lookups to `_MultipleLocalizationLookup._lookups`. To solve that use `ResetLocalizationsDelegate`, that marks `MultipleLocalizations`, and lookups list will be cleared before new lookups will be added. Note, that `ResetLocalizationsDelegate` **must** be the last in App's localizationsDelegates list.

**Why do we need to have multiple arb files?**

In common scenario - we don't. Just put all localization string in single file and enjoy.
But if you want to add intl localization with arb files to separate package, and than use
it in you project with it's own localization files - that's problem.

Exactly for that situation this package was developed.

See article on Medium for more details - [Localization for Dart package](https://medium.com/@greymag/localization-for-dart-package-8ca2f56ea971).

## Usage

To use this package, add `multiple_localization` as a [dependency in your pubspec.yaml file](https://flutter.dev/platform-plugins/).

Than use `MultipleLocalizations.load` for your delegate load function, instead of call `initializeMessages` explicitly.

### Example

```dart
class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ru'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return MultipleLocalizations.load(
        initializeMessages, locale, (l) => AppLocalizations(l),
        setDefaultLocale: true);
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}
```
