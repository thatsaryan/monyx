import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_auth/local_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricScreen extends StatefulWidget {
  const BiometricScreen({super.key});

  @override
  State<BiometricScreen> createState() => _BiometricScreenState();
}

class _BiometricScreenState extends State<BiometricScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  String _authStatus = "Checking biometric preference...";
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _checkAndStartBiometric();
  }

  Future<void> _checkAndStartBiometric() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isBiometricEnabled = prefs.getBool('biometric_enabled') ?? false;

    final user = FirebaseAuth.instance.currentUser;

    if (!isBiometricEnabled) {
      setState(() {
        _authStatus = "Biometric login is disabled.";
      });
      await Future.delayed(const Duration(seconds: 1));

      // 🔁 Redirect based on user login status
      if (user != null) {
        Get.offNamed('/home');
      } else {
        Get.offNamed('/onboarding');
      }
      return;
    }

    _authenticate(); // biometric is enabled
  }


  Future<void> _authenticate() async {
    setState(() {
      _isAuthenticating = true;
      _authStatus = "Authenticating...";
    });

    try {
      final isSupported = await auth.isDeviceSupported();
      final canCheck = await auth.canCheckBiometrics;

      if (!isSupported || !canCheck) {
        setState(() {
          _authStatus = "Biometrics not supported.";
        });
        return;
      }

      final authenticated = await auth.authenticate(
        localizedReason: 'Please authenticate using biometrics',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );

      if (authenticated) {
        setState(() => _authStatus = "Authentication Successful");
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          Get.offNamed('/home');
        } else {
          Get.offNamed('/onboarding');
        }
      } else {
        setState(() => _authStatus = "Authentication Failed");
      }
    } catch (e) {
      setState(() => _authStatus = "Error: ${e.toString()}");
    } finally {
      setState(() => _isAuthenticating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Secure Login"),
        centerTitle: true,
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Card(
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.fingerprint, size: 100.sp, color: Colors.blue),
                  SizedBox(height: 24.h),
                  Text(
                    _authStatus,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 32.h),
                  ElevatedButton.icon(
                    onPressed: _isAuthenticating ? null : _authenticate,
                    style: ElevatedButton.styleFrom(
                      padding:
                      EdgeInsets.symmetric(horizontal: 32.w, vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.r),
                      ),
                    ),
                    icon: const Icon(Icons.refresh),
                    label: const Text("Try Again"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
