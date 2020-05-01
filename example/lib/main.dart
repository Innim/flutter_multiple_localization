import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multiple_localization_example/app/app_localization.dart';
import 'package:multiple_localization_example/package/package_localization.dart';

void main() async {
  runApp(
    MaterialApp(
      supportedLocales: [Locale('en')],
      localizationsDelegates: [
        AppLocalizations.delegate,
        PackageLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate,
      ],
      home: HomeScreen(),
    ),
  );
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appLocalization = AppLocalizations.of(context);
    final packageLocalization = PackageLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Center(
          child: Column(
            children: [
              Text(appLocalization.messageFromApp),
              Text(packageLocalization.messageFromPackage),
              Text(packageLocalization.messageFromPackageForOverride),
            ],
          ),
        ),
      ),
    );
  }
}
