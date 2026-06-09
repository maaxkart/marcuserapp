import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:firebase_core/firebase_core.dart';

import 'package:media_kit/media_kit.dart';

import 'firebase_options.dart';

import 'services/notification_service.dart';

import 'screens/splash/splash_screen.dart';

import 'theme/app_theme.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  // =====================================================
  // FIREBASE INIT
  // =====================================================

  await Firebase.initializeApp(

    options:
    DefaultFirebaseOptions.currentPlatform,
  );

  // =====================================================
  // NOTIFICATION INIT
  // =====================================================

  //await NotificationService.initialize();

  // =====================================================
  // MEDIA KIT
  // =====================================================

  MediaKit.ensureInitialized();

  // =====================================================
  // STATUS BAR
  // =====================================================

  SystemChrome.setSystemUIOverlayStyle(

    const SystemUiOverlayStyle(

      statusBarColor:
      Colors.transparent,

      statusBarIconBrightness:
      Brightness.dark,
    ),
  );

  // =====================================================
  // PORTRAIT MODE
  // =====================================================

  await SystemChrome.setPreferredOrientations([

    DeviceOrientation.portraitUp,

    DeviceOrientation.portraitDown,
  ]);

  // =====================================================
  // RUN APP
  // =====================================================

  runApp(const MarcApp());
}

class MarcApp extends StatelessWidget {

  const MarcApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      title: 'Marc App',

      debugShowCheckedModeBanner:
      false,

      theme:
      AppTheme.lightTheme,

      home:
      const SplashScreen(),
    );
  }
}