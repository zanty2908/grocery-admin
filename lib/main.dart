import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grocery_admin/resources/theme_manager.dart';
import 'package:grocery_admin/views/splash/entry.dart';
import 'constants/color.dart';
import 'controllers/route_manager.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ErrorWidget.builder = (FlutterErrorDetails details) => Container();

  await Firebase.initializeApp(
    options: kIsWeb || Platform.isAndroid
        ? const FirebaseOptions(
            apiKey: "AIzaSyDwQEBBE6Liryi1Ct5yC8-BFf3Z6XX-UFU",
            authDomain: "yenquan.firebaseapp.com",
            projectId: "yenquan",
            storageBucket: "yenquan.appspot.com",
            messagingSenderId: "787924438322",
            appId: "1:787924438322:web:8e3afe801a8faa8ac89b2b",
            measurementId: "G-QMDW11L2E3",
          )
        : null,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
    );

    EasyLoading.instance
      ..backgroundColor = primaryColor
      ..progressColor = Colors.white
      ..loadingStyle = EasyLoadingStyle.light;

    return MaterialApp(
      theme: getLightTheme(),
      title: 'Yến Quân Grocery',
      debugShowCheckedModeBanner: false,
      home: const EntryScreen(),
      routes: routes,
      builder: EasyLoading.init(),
    );
  }
}
