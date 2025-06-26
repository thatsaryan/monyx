import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'BiometricScreen.dart';
import 'LoginScreen.dart';
import 'Onboarding.dart';
import 'HomeScreen.dart';
import 'notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService().init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      builder: (_, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Spendle',
          theme: ThemeData(
            fontFamily: 'Inter',
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Colors.white,
          ),
          initialRoute: '/biometric',
          getPages: [
            GetPage(name: '/splash', page: () => const SplashScreen()),
            GetPage(name: '/biometric', page: () => const BiometricScreen()),
            GetPage(name: '/onboarding', page: () => const Onboarding()),
            GetPage(name: '/login', page: () => const LoginScreen()),
            GetPage(name: '/home', page: () => HomeScreen()), // Add home
          ],
        );
      },
    );
  }
}

// Updated SplashScreen with navigation logic
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), _handleNavigation);
  }

  void _handleNavigation() {
    final args = Get.arguments as Map<String, dynamic>?;
    final nextRoute = args?['nextRoute'] ?? '/onboarding';
    Get.offAllNamed(nextRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/icons/Spendle.gif',
          height: 300.h,
          width: 300.w,
        ),
      ),
    );
  }
}

