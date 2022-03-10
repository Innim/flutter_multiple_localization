import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:multiple_localization/src/multiple_localization.dart';

void main() {
  group('MultipleLocalizations', () {
    group('load()', () {
      tearDown(MultipleLocalizations.reset);

      group('fallback locale', () {
        test('should load if provided', () async {
          final loaded = <String>{};
          await MultipleLocalizations.load((localeName) {
            loaded.add(localeName);
            return Future.value(true);
          }, const Locale('es'), (locale) => null, fallbackLocale: 'en');

          expect(loaded.length, 2);
          expect(loaded, contains('en'));
        });

        test('should not load if not provided', () async {
          final loaded = <String>{};
          await MultipleLocalizations.load((localeName) {
            loaded.add(localeName);
            return Future.value(true);
          }, const Locale('es'), (locale) => null);

          expect(loaded, {'es'});
        });

        test('should not load if equals to current locale', () async {
          final loaded = <String>{};
          await MultipleLocalizations.load((localeName) {
            loaded.add(localeName);
            return Future.value(true);
          }, const Locale('es'), (locale) => null, fallbackLocale: 'es');

          expect(loaded, {'es'});
        });
      });
    });
  });
}
