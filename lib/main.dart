import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_trainer/fitness_translations.dart';
import 'package:fitnc_trainer/service/fitness-user.service.dart';
import 'package:fitnc_trainer/service/trainers.service.dart';
import 'package:fitnc_trainer/theming.dart';
import 'package:fitnc_trainer/widget/layout-display.widget.dart';
import 'package:fitnc_trainer/widget/login/login.page.dart';
import 'package:fitnc_trainer/widget/login/sign-up.page.dart';
import 'package:fitnc_trainer/widget/policies_mobile/policies_mobile.page.dart';
import 'package:fitnc_trainer/widget/widgets/firebase.widget.dart';
import 'package:fitness_domain/constants.dart';
import 'package:fitness_domain/service/auth.service.dart';
import 'package:fitness_domain/service/display.service.dart';
import 'package:fitness_domain/service/firebase-storage.service.dart';
import 'package:fitness_domain/service/firebase.service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oktoast/oktoast.dart';

import 'middleware/is_connected_middleware.dart';

void main() {
  initServices();
  runApp(MyApp());
}

void initServices() {
  Get.put(AuthService());
  Get.put(FirebaseService());
  Get.put(FirebaseStorageService());
  Get.put(DisplayTypeService());
  Get.put(FitnessUserService());
  Get.put(TrainersService());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OKToast(
      position: ToastPosition.bottom,
      child: GetMaterialApp(
        title: FitnessConstants.appTitle,
        locale: Get.deviceLocale,
        fallbackLocale: const Locale('en', 'US'),
        translations: FitnessTranslations(),
        debugShowCheckedModeBanner: false,
        theme: Theming.getThemeData(),
        initialRoute: FitnessConstants.routeHome,
        getPages: <GetPage<dynamic>>[
          GetPage<LoginPage>(
            name: FitnessConstants.routeLogin,
            page: () => LoginPage(
              callback: (UserCredential userCredential) =>
                  Get.offNamed(FitnessConstants.routeHome),
            ),
          ),
          GetPage<SignUpPage>(
            name: FitnessConstants.routeSignUp,
            page: () => SignUpPage(
              callback: (UserCredential userCredential) =>
                  Get.offNamed(FitnessConstants.routeHome),
            ),
          ),
          GetPage<PoliciesMobilePage>(
            name: FitnessConstants.routePoliciesMobile,
            page: () => const PoliciesMobilePage(),
          ),
          GetPage<LayoutDisplayNotifier>(
              name: FitnessConstants.routeHome,
              page: () => const LayoutDisplayNotifier(
                    child: FirebaseWidget(),
                  ),
              middlewares: [IsConnectedMiddleware()]),
        ],
      ),
    );
  }
}
