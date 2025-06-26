import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      'image': 'assets/icons/onboarding_1.png',
      'title': 'Gain total control of your money',
      'desc': 'Become your own money manager and make every rupee count.'
    },
    {
      'image': 'assets/icons/onboarding_2.png',
      'title': 'Know where your money goes',
      'desc': 'Track your transaction easily, with categories and financial report.'
    },
    {
      'image': 'assets/icons/onboarding_3.png',
      'title': 'Planning ahead',
      'desc': 'Setup your budget for each category so you stay in control.'
    },
    {
      'image': 'assets/icons/onboarding_4.png',
      'title': 'Timely reminders',
      'desc': 'Set your reminders and get notified on time.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: onboardingData.length,
              onPageChanged: (int index) {
                setState(() => _currentPage = index);
              },
              itemBuilder: (_, index) {
                return Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        onboardingData[index]['image']!,
                        height: 300.h,
                      ),
                      SizedBox(height: 40.h),
                      Text(
                        onboardingData[index]['title']!,
                        style: TextStyle(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        onboardingData[index]['desc']!,
                        style: TextStyle(
                          fontSize: 18.sp,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 30.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Get.offNamed('/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: Colors.black),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 10.h,
                    ),
                    child: Text(
                      'Skip',
                      style: TextStyle(fontSize: 16.sp),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    if (_currentPage == onboardingData.length - 1) {
                      Get.offNamed('/login');
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 24.sp,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              onboardingData.length,
                  (index) => buildDot(index),
            ),
          ),
          SizedBox(height: 30.h),
        ],
      ),
    );
  }

  Widget buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: EdgeInsets.symmetric(horizontal: 6.w),
      height: 10.h,
      width: _currentPage == index ? 24.w : 10.w,
      decoration: BoxDecoration(
        color: _currentPage == index ? Colors.blue : Colors.grey,
        borderRadius: BorderRadius.circular(5.r),
      ),
    );
  }
}
