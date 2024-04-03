import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/formfields/nsg_field_type.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_data/controllers/nsg_data_controller_mode.dart';

import 'app_pages.dart';

void main() async {
  if (!kDebugMode) {
//
  }

  ControlOptions newinstance = ControlOptions(
      fileExchangeVersion: 0.1,
      nsgButtonMargin: const EdgeInsets.only(bottom: 10),
      nsgInputMargin: const EdgeInsets.only(bottom: 10),
      nsgInputFilled: true,
      nsgInputColorFilled: const Color(0xFF65982F).withOpacity(0.1),
      nsgInputOutlineBorderType: TextFormFieldType.outlineInputBorder,
      nsgInputHintAlwaysOnTop: true,
      nsgInputContentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
      sizeH1: 48,
      sizeH4: 22,
      borderRadius: 9,
      appMaxWidth: 1920,
      appMinWidth: 375,
      colorPrimary: const Color(0xFF65982F),
      colorSecondary: const Color.fromRGBO(189, 189, 189, 1),
      tableHeaderColor: const Color.fromARGB(255, 46, 95, 0),
      tableHeaderLinesColor: const Color.fromRGBO(158, 255, 94, 0),
      colorMain: const Color(0xFF65982F),
      colorMainDark: const Color.fromARGB(255, 81, 121, 38),
      colorMainLight: const Color(0xFF80C537),
      colorMainLighter: const Color.fromARGB(255, 165, 253, 72),
      colorMainText: const Color.fromRGBO(255, 255, 255, 1),
      colorText: const Color.fromRGBO(30, 30, 30, 1),
      colorInverted: const Color.fromRGBO(255, 255, 255, 1),
      colorGrey: const Color.fromRGBO(189, 189, 189, 1),
      colorGreyLight: const Color(0xFFEDEFF3),
      colorGreyLighter: const Color(0xFFF4F4F4),
      colorGreyDark: const Color.fromRGBO(136, 136, 136, 1),
      colorGreyDarker: const Color.fromRGBO(51, 51, 51, 1),

      // colorWhite: const Color.fromRGBO(255, 255, 255, 1),
      colorWarning: const Color(0xFFF7B217),
      colorError: const Color(0xFFFF0000),
      gradients: {
        'main': [const Color(0xFF65982F), const Color(0xFF80C537)],
        'main2': [const Color.fromARGB(255, 52, 100, 121), const Color(0xFF529FBF)],
        'secondary': [const Color(0xFFEDEFF3), const Color(0xFFF4F4F4)],
      });
  ControlOptions.instance = newinstance;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    NsgDataControllerMode.defaultDataControllerMode = const NsgDataControllerMode(storageType: NsgDataStorageType.local);
    return GetMaterialApp(
      textDirection: TextDirection.ltr,
      defaultTransition: Transition.fadeIn,
      title: 'Controls Examples',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: TextTheme(
          bodyLarge: TextStyle(
            fontSize: 14.0,
            color: ControlOptions.instance.colorText,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w400,
            height: 1.20,
          ),
          bodyMedium: TextStyle(
            fontSize: 14.0,
            color: ControlOptions.instance.colorText,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w400,
            height: 1.20,
          ),
          displayLarge: TextStyle(
            fontSize: 20.0,
            color: ControlOptions.instance.colorText,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w600,
          ),
          displayMedium: TextStyle(
            fontSize: 18.0,
            color: ControlOptions.instance.colorText,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w600,
            height: 1.40,
            letterSpacing: 1.0,
          ),
          displaySmall: TextStyle(
            fontSize: 18.0,
            color: ControlOptions.instance.colorText,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.normal,
          ),
          headlineMedium: TextStyle(
            fontSize: 14.0,
            color: ControlOptions.instance.colorText,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.normal,
          ),
          labelLarge: const TextStyle(
            fontSize: 14.0,
            color: Color.fromRGBO(0, 0, 0, 1),
            fontFamily: 'Roboto',
            fontWeight: FontWeight.normal,
            height: 1.40,
            letterSpacing: 1.0,
          ),
          bodySmall: const TextStyle(
            fontSize: 14.0,
            color: Color.fromRGBO(33, 32, 30, 1),
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w500,
            height: 1.40,
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ru')],
      locale: const Locale('ru'),
    );
  }
}
