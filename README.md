# multiple_localization

[![pub package](https://img.shields.io/pub/v/multiple_localization)](https://pub.dartlang.org/packages/multiple_localization)
![Analyze & Test](https://github.com/Innim/flutter_multiple_localization/actions/workflows/dart.yml/badge.svg?branch=master)
[![innim lint](https://img.shields.io/badge/style-innim_lint-40c4ff.svg)](https://pub.dev/packages/innim_lint)

Support for multiple abr and messages localization files for [intl](https://pub.dev/packages/intl) package.

## Problem

If you want to have multiple arb files and register separate delegate for each one of them,
then you have a problem. Intl doesn't allow multiple `initializeMessages` calls. Only
first one will be processed and only it's messages will be used. Every calls after the first one
will be ignored.

**Why do we need to have multiple arb files?**

In common scenario - we don't. Just put all localization string in single file and enjoy.
But if you want to add intl localization with arb files to separate package, and than use
it in you project with it's own localization files - that's problem.

`MultipleLocalizations` supports using `Localizations.override(delegates: [SomeLocalizationsDelegate(), ...])` widget, too.

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

### Override string from package in project

If you want to override string from package localization in project
(for example to change some labels in package widgets) - you need to
define string with required name in you app localization class.

### Example. 

If package has string `messageFromPackageForOverride`:

```dart
class PackageLocalizations {
  ...

  String get messageFromPackageForOverride =>
        Intl.message('Package', name: 'messageFromPackageForOverride');
```

Then you need to define `messageFromPackageForOverride` in you `AppLocalizations`:

```dart
class AppLocalizations {
  ...

  String get messageFromPackageForOverride =>
        Intl.message('App', name: 'messageFromPackageForOverride');
```

Make sure that you add the app localization delegate before
the package localization delegate:

```dart
  ...
  const MaterialApp(
    localizationsDelegates: [
      AppLocalizations.delegate,
      PackageLocalizations.delegate,
      ...
    ],
    ...
```

Now, whenever package use `messageFromPackageForOverride` you will see `App`, not `Package`.

### Set fallback locale

Also you can specify a fallback locale when loading application localization delegate.
Use [fallbackLocale] parameter to set locale which will be used if some key not found for current locale. 
Only first call of [load] will set fallback locale, make sure that your app's localization delegate 
added as a first element of the delegates list.

Also pay attention that if you provide the [fallbackLocale], than all messages will be uploaded in memory
on the start of application in addition to current locale.