// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poem/business_logic/view_models/home_view_model.dart';
import 'package:poem/services/service_locator.dart';
import 'package:poem/ui/views/home_view.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

final homeProvider = ChangeNotifierProvider((_) => HomeViewModel());

RateMyApp rateMyApp = RateMyApp(
  preferencesPrefix: 'rateMyApp_',
  minDays: 7,
  minLaunches: 10,
  remindDays: 7,
  remindLaunches: 10,
  googlePlayIdentifier: 'mobi.ranka.poem',
  appStoreIdentifier: '1509333489',
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await setupServiceLocator();
  await rateMyApp.init();

  runApp(
    ProviderScope(
      child: EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('sk')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      //web is not supported
    } else {
      if (rateMyApp.shouldOpenDialog) {
        rateMyApp.showStarRateDialog(
          context,
          title: 'Rate this app', // The dialog title.
          message:
              'You like this app ? Then take a little bit of your time to leave a rating :', // The dialog message.
          // contentBuilder: (context, defaultContent) => content, // This one allows you to change the default dialog content.
          actionsBuilder: (context, stars) {
            // Triggered when the user updates the star rating.
            return [
              // Return a list of actions (that will be shown at the bottom of the dialog).
              TextButton(
                child: const Text('OK'),
                onPressed: () async {
                  print(
                      'Thanks for the ${stars == null ? '0' : stars.round().toString()} star(s) !');
                  // You can handle the result as you want (for instance if the user puts 1 star then open your contact page, if he puts more then open the store page, etc...).
                  // This allows to mimic the behavior of the default "Rate" button. See "Advanced > Broadcasting events" for more information :
                  await rateMyApp
                      .callEvent(RateMyAppEventType.rateButtonPressed);
                  Navigator.pop<RateMyAppDialogButton>(
                      context, RateMyAppDialogButton.rate);
                },
              ),
            ];
          },
          dialogStyle: const DialogStyle(
            titleAlign: TextAlign.center,
            messageAlign: TextAlign.center,
            messagePadding: EdgeInsets.only(bottom: 20),
          ),
          starRatingOptions:
              const StarRatingOptions(), // Custom star bar rating options.
          onDismissed: () => rateMyApp.callEvent(RateMyAppEventType
              .laterButtonPressed), // Called when the user dismissed the dialog (either by taping outside or by pressing the "back" button).
        );
      }
    }

    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      title: 'title'.tr(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: false,
      ),
      home: const HomeView(),
      debugShowCheckedModeBanner: false,
    );
  }
}
