import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'ForgotPassword.dart';
import 'HomeScreen.dart';
import 'SignUpScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _checkIfLoggedIn();
  }

  void _checkIfLoggedIn() {
    final user = _auth.currentUser;
    if (user != null) {
      Future.microtask(() => Get.off(() => HomeScreen()));
    }
  }

  Future<void> _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Please enter email and password',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    setState(() => isLoading = true);

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      Get.off(() => HomeScreen());
    } on FirebaseAuthException catch (e) {
      String message = e.message ?? 'Login failed';
      Get.snackbar('Login Error', message,
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() => isLoading = true);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      Get.off(() => HomeScreen());
    } catch (e) {
      Get.snackbar('Google Sign-In Error', e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Login',
            style: TextStyle(
              fontSize: 24.sp,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              color: Colors.white,
            )),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 20.h),
              Image.asset('assets/icons/logo.png',
                  height: 150.h, width: 150.w),
              SizedBox(height: 35.h),

              _buildInputField(
                controller: emailController,
                label: 'Email',
                hint: 'Enter your email',
                obscureText: false,
              ),
              SizedBox(height: 20.h),
              _buildInputField(
                controller: passwordController,
                label: 'Password',
                hint: 'Enter your password',
                obscureText: true,
              ),
              SizedBox(height: 24.h),

              isLoading
                  ? const CircularProgressIndicator(
                color: Colors.blue,
              )
                  : _buildLoginButton(),

              SizedBox(height: 24.h),

              Text("or login with",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontFamily: 'Inter',
                    color: Colors.grey[700],
                  )),
              SizedBox(height: 16.h),

              // Circular Google Login Icon
              InkWell(
                onTap: _loginWithGoogle,
                borderRadius: BorderRadius.circular(30.r),
                child: Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white,
                        blurRadius: 2,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                  child: SvgPicture.asset(
                    'assets/icons/google.svg',
                    height: 28.h,
                    width: 28.w,
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              TextButton(
                onPressed: () => Get.to(() => const ForgotPassword()),
                child: Text('Forgot password?',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 17.sp,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    )),
              ),
              SizedBox(height: 16.h),

              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account yet?",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18.sp,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      )),
                  TextButton(
                    onPressed: () => Get.off(() => const SignUpScreen()),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(' Sign Up',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 17.sp,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                        )),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscureText,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.w),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.4),
              blurRadius: 10.r,
              offset: Offset(0, 8.h),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          cursorColor: Colors.black,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18.r),
              borderSide: const BorderSide(color: Colors.blue),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18.r),
              borderSide: const BorderSide(color: Colors.blue),
            ),
            labelText: label,
            hintText: hint,
            labelStyle: TextStyle(
              fontSize: 16.sp,
              fontFamily: 'Inter',
              color: Colors.black,
            ),
            hintStyle: TextStyle(
              fontSize: 16.sp,
              fontFamily: 'Inter',
              color: Colors.black,
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.w),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 12.r,
              offset: Offset(0, 8.h),
            ),
          ],
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 50.h,
          child: ElevatedButton(
            onPressed: _login,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.r),
              ),
              elevation: 0,
            ),
            child: Text('Login',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                )),
          ),
        ),
      ),
    );
  }
}
