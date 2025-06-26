import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ForgotPassword.dart';
import 'HomeScreen.dart';
import 'Transactions.dart';
import 'LoginScreen.dart';
import 'NotificationScreen.dart';
import 'AddTransaction.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  bool isBiometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadBiometricStatus();
  }

  Future<void> _loadBiometricStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final savedStatus = prefs.getBool('biometric_enabled') ?? false;
    print('Biometric loaded from storage: $savedStatus');
    setState(() {
      isBiometricEnabled = savedStatus;
    });
  }

  Future<void> _toggleBiometric(bool enable) async {
    final prefs = await SharedPreferences.getInstance();
    print('Toggling biometric to: $enable');

    if (enable) {
      bool canCheck = await auth.canCheckBiometrics;
      print('Device can check biometrics: $canCheck');

      if (!canCheck) {
        Get.snackbar('Unsupported', 'Your device does not support biometrics');
        return;
      }

      try {
        final authenticated = await auth.authenticate(
          localizedReason: 'Please authenticate to enable biometrics',
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
          ),
        );

        if (authenticated) {
          await prefs.setBool('biometric_enabled', true);
          setState(() => isBiometricEnabled = true);
          Get.snackbar('Success', 'Biometric authentication enabled');
          print('Biometric enabled');
        } else {
          Get.snackbar('Cancelled', 'Authentication cancelled');
          print('User cancelled biometric auth');
        }
      } catch (e) {
        print('Biometric error: $e');
        Get.snackbar('Error', 'Authentication failed: ${e.toString()}');
      }
    } else {
      await prefs.setBool('biometric_enabled', false);
      setState(() => isBiometricEnabled = false);
      Get.snackbar('Disabled', 'Biometric authentication disabled');
      print('Biometric disabled');
    }
  }


  void _confirmLogout() {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              try {
                await FirebaseAuth.instance.signOut();
                Get.offAll(() => const LoginScreen());
              } catch (e) {
                Get.snackbar('Error', 'Failed to logout: $e',
                    snackPosition: SnackPosition.BOTTOM);
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.off(() => HomeScreen());
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          title: Text(
            "Profile",
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              fontSize: 22.sp,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Get.off(() => HomeScreen());
            },
          ),
        ),
        backgroundColor: Colors.white,
        body: DefaultTextStyle(
          style: TextStyle(
            fontFamily: 'Inter',
            color: Colors.black,
            fontSize: 16.sp,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40.r,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, size: 50.sp, color: Colors.white),
                ),
                SizedBox(height: 10.h),
                Text(
                  "Username",
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                ),
                Text(
                  "Aryan Maheta",
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 30.h),
                buildOptionCard(
                  icon: Icons.compare_arrows,
                  text: "Transactions",
                  trailing: Icon(Icons.arrow_forward_ios, size: 16.sp),
                  onTap: () => Get.to(() => const Transactions()),
                ),
                buildOptionCard(
                  icon: Icons.fingerprint,
                  text: "Biometrics enable/disable",
                  trailing: Switch(
                    value: isBiometricEnabled,
                    onChanged: (val) => _toggleBiometric(val),
                    activeColor: Colors.blue,
                    activeTrackColor: Colors.blue[200],
                  ),
                ),
                buildOptionCard(
                  icon: Icons.lock,
                  text: "Change password",
                  trailing: Icon(Icons.arrow_forward_ios, size: 16.sp),
                  onTap: () => Get.to(() => const ForgotPassword()),
                ),
                buildOptionCard(
                  icon: Icons.logout,
                  text: "Logout",
                  trailing: Icon(Icons.arrow_forward_ios, size: 16.sp),
                  onTap: _confirmLogout,
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: Container(
          width: 60.w,
          height: 60.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Colors.blue, Colors.blueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: FloatingActionButton(
            onPressed: () => Get.to(() => AddTransaction()),
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Icon(Icons.add, size: 30.sp, color: Colors.white),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFFF6F5F5),
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          currentIndex: 4,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          onTap: (index) {
            if (index == 0) Get.off(() => HomeScreen());
            else if (index == 1) Get.off(() => Transactions());
            else if (index == 3) Get.off(() => NotificationScreen());
          },
          items: [
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/icons/home.svg',
                height: 24.h,
                width: 24.w,
                color: Colors.grey,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/icons/transaction.svg',
                height: 24.h,
                width: 24.w,
                color: Colors.grey,
              ),
              label: 'Transactions',
            ),
            const BottomNavigationBarItem(
              icon: SizedBox(height: 24, width: 24),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/icons/notifications.svg',
                height: 24.h,
                width: 24.w,
                color: Colors.grey,
              ),
              label: 'Notifications',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/icons/settings.svg',
                height: 24.h,
                width: 24.w,
                color: Colors.blue,
              ),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  Widget buildOptionCard({
    required IconData icon,
    required String text,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24.sp),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                text,
                style: TextStyle(fontSize: 16.sp),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }
}
