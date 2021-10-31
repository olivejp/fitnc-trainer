import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_trainer/fitness_translations.dart';
import 'package:fitnc_trainer/middleware/init_domain_service_middleware.dart';
import 'package:fitnc_trainer/service/config.service.dart';
import 'package:fitnc_trainer/service/firebase/firebase_init_firestore.service.dart';
import 'package:fitnc_trainer/service/firebase/firebase_init_functions.service.dart';
import 'package:fitnc_trainer/service/fitness-user.service.dart';
import 'package:fitnc_trainer/service/trainers.service.dart';
import 'package:fitnc_trainer/theming.dart';
import 'package:fitnc_trainer/widget/login/login.page.dart';
import 'package:fitnc_trainer/widget/login/sign-up.page.dart';
import 'package:fitnc_trainer/widget/policies_mobile/policies_mobile.page.dart';
import 'package:fitnc_trainer/widget/widgets/auth.widget.dart';
import 'package:fitness_domain/constants.dart';
import 'package:fitness_domain/middleware/is_connected_middleware.dart';
import 'package:fitness_domain/middleware/layout_notifier_middleware.dart';
import 'package:fitness_domain/service/auth.service.dart';
import 'package:fitness_domain/service/display.service.dart';
import 'package:fitness_domain/service/firebase-storage.service.dart';
import 'package:fitness_domain/widget/layout-display.widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oktoast/oktoast.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ConfigService configService = Get.put(ConfigService());

  @override
  Widget build(BuildContext context) {
    return OKToast(
      position: ToastPosition.bottom,
      child: GetMaterialApp(
        onInit: initAllServices,
        title: FitnessConstants.appTitle,
        locale: Get.deviceLocale,
        fallbackLocale: const Locale('en', 'US'),
        translations: FitnessTranslations(),
        debugShowCheckedModeBanner: configService.isDevMode(),
        theme: Theming.getThemeData(),
        initialRoute: FitnessConstants.routeHome,
        getPages: getPages(),
      ),
    );
  }

  ///
  /// Initialisation des différents services dépendants de Firebase.
  ///
  void initAllServices() {
    developer.log('onInit() called');

    final ConfigService conf = Get.find();

    Get.lazyPut(() => DisplayTypeService());
    Get.put(FirebaseInitFirestoreService(emulate: conf.emulateFirestore()));
    Get.put(FirebaseInitFunctionsService(
      emulate: conf.emulateFunctions(),
      region: FitnessConstants.firebaseRegion,
    ));
    Get.put(AuthService(emulate: conf.emulateAuth()));
    Get.put(FirebaseStorageService(emulate: conf.emulateStorage()));
    Get.put(FitnessUserService());
    Get.put(TrainersService());
  }

  ///
  /// Routing de l'application
  ///
  List<GetPage<dynamic>> getPages() {
    return <GetPage<dynamic>>[
      GetPage<SignUpPage>(
        name: FitnessConstants.routeSignUp,
        middlewares: <GetMiddleware>[LayoutNotifierMiddleware()],
        page: () => SignUpPage(
          callback: (UserCredential userCredential) =>
              Get.offNamed(FitnessConstants.routeHome),
        ),
      ),
      GetPage<PoliciesMobilePage>(
        name: FitnessConstants.routePoliciesMobile,
        middlewares: <GetMiddleware>[LayoutNotifierMiddleware()],
        page: () => const PoliciesMobilePage(),
      ),
      GetPage<LayoutNotifier>(
        name: FitnessConstants.routeHome,
        middlewares: <GetMiddleware>[
          IsConnectedMiddleware(),
          LayoutNotifierMiddleware(),
          InitDomainServiceMiddleware(),
        ],
        page: () => AuthWidget(),
      ),
      GetPage<LoginPage>(
        name: FitnessConstants.routeLogin,
        middlewares: <GetMiddleware>[LayoutNotifierMiddleware()],
        page: () => LoginPage(
          callback: (UserCredential userCredential) =>
              Get.offNamed(FitnessConstants.routeHome),
        ),
      ),
    ];
  }
}
