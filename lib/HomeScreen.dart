import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:monyx/AddTransaction.dart';
import 'package:monyx/NotificationScreen.dart';
import 'package:monyx/ProfileScreen.dart';
import 'package:monyx/Transactions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CategoryStyle {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;

  const CategoryStyle({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
  });
}

const Map<String, CategoryStyle> categoryStyles = {
  'Shopping': CategoryStyle(
    icon: Icons.shopping_bag,
    iconColor: Colors.orange,
    bgColor: Color(0xFFFFF3E0),
  ),
  'EMI': CategoryStyle(
    icon: Icons.money,
    iconColor: Colors.orange,
    bgColor: Color(0xFFFFF3E0),
  ),
  'Subscription': CategoryStyle(
    icon: Icons.subscriptions,
    iconColor: Colors.purple,
    bgColor: Color(0xFFF3E5F5),
  ),
  'Food': CategoryStyle(
    icon: Icons.fastfood,
    iconColor: Colors.red,
    bgColor: Color(0xFFFFEBEE),
  ),
  'Salary': CategoryStyle(
    icon: Icons.currency_rupee,
    iconColor: Colors.green,
    bgColor: Color(0xFFE8F5E9),
  ),
  'Transportation': CategoryStyle(
    icon: Icons.directions_car,
    iconColor: Colors.blue,
    bgColor: Color(0xFFE3F2FD),
  ),
  'Health': CategoryStyle(
    icon: Icons.health_and_safety,
    iconColor: Colors.teal,
    bgColor: Color(0xFFE0F2F1),
  ),
  'Education': CategoryStyle(
    icon: Icons.school,
    iconColor: Colors.indigo,
    bgColor: Color(0xFFE8EAF6),
  ),
  'Rent': CategoryStyle(
    icon: Icons.house,
    iconColor: Colors.brown,
    bgColor: Color(0xFFD7CCC8),
  ),
  'Travel': CategoryStyle(
    icon: Icons.flight_takeoff,
    iconColor: Colors.deepOrange,
    bgColor: Color(0xFFFFF3E0),
  ),
  'Entertainment': CategoryStyle(
    icon: Icons.movie,
    iconColor: Colors.pink,
    bgColor: Color(0xFFFCE4EC),
  ),
  'Investment': CategoryStyle(
    icon: Icons.trending_up,
    iconColor: Colors.greenAccent,
    bgColor: Color(0xFFE8F5E9),
  ),
  'Utilities': CategoryStyle(
    icon: Icons.lightbulb,
    iconColor: Colors.amber,
    bgColor: Color(0xFFFFF8E1),
  ),
  'Insurance': CategoryStyle(
    icon: Icons.security,
    iconColor: Colors.deepPurple,
    bgColor: Color(0xFFEDE7F6),
  ),
  'Gifts': CategoryStyle(
    icon: Icons.card_giftcard,
    iconColor: Colors.redAccent,
    bgColor: Color(0xFFFFEBEE),
  ),
  'Savings': CategoryStyle(
    icon: Icons.savings,
    iconColor: Colors.lightBlue,
    bgColor: Color(0xFFE1F5FE),
  ),
  'Loan': CategoryStyle(
    icon: Icons.money_off,
    iconColor: Colors.black87,
    bgColor: Color(0xFFEEEEEE),
  ),
  'Charity': CategoryStyle(
    icon: Icons.volunteer_activism,
    iconColor: Colors.cyan,
    bgColor: Color(0xFFE0F7FA),
  ),
  'Tax': CategoryStyle(
    icon: Icons.receipt,
    iconColor: Colors.grey,
    bgColor: Color(0xFFF5F5F5),
  ),
  'Others': CategoryStyle(
    icon: Icons.category,
    iconColor: Colors.grey,
    bgColor: Color(0xFFF5F5F5),
  ),
  'Movies': CategoryStyle(
    icon: Icons.movie,
    iconColor: Colors.pink,
    bgColor: Color(0xFFFCE4EC),
  ),
  'Hotel': CategoryStyle(
    icon: Icons.hotel,
    iconColor: Colors.blueGrey,
    bgColor: Color(0xFFECEFF1),
  ),
};

class TransactionItem extends StatelessWidget {
  final String category;
  final String subtitle;
  final String amount;
  final bool isIncome;

  const TransactionItem({
    super.key,
    required this.category,
    required this.subtitle,
    required this.amount,
    required this.isIncome,
  });

  @override
  Widget build(BuildContext context) {
    final style = categoryStyles[category] ??
        const CategoryStyle(
          icon: Icons.tag, // Distinct icon for custom categories
          iconColor: Colors.grey,
          bgColor: Color(0xFFF7F7F7),
        );

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: style.bgColor,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(style.icon, color: style.iconColor, size: 28.w),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey[600],
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: isIncome ? Colors.green : Colors.red,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomescreenState createState() => _HomescreenState();
}

class _HomescreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final double containerWidth = MediaQuery.of(context).size.width - 40.w;
    final user = FirebaseAuth.instance.currentUser;

    // If user is not authenticated, show login prompt
    if (user == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Please log in to view your dashboard.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16.sp,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: () {
                  // Replace with your actual login screen navigation
                  Get.to(() => const HomeScreen()); // Placeholder
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: Size(200.w, 50.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                child: Text(
                  'Go to Login',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: Colors.white,
                    fontSize: 16.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('transactions')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Text(
                'Error loading transactions.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16.sp,
                  color: Colors.grey,
                ),
              ),
            ),
          );
        }

        // Get transactions
        final transactions = snapshot.data?.docs ?? [];

        // Calculate total income and expense
        double totalIncome = 0;
        double totalExpense = 0;
        for (var doc in transactions) {
          final transaction = doc.data() as Map<String, dynamic>;
          final amount = (transaction['amount'] as num).toDouble();
          if (transaction['isIncome'] == true) {
            totalIncome += amount;
          } else {
            totalExpense += amount;
          }
        }
        final netBalance = totalIncome - totalExpense;

        // Get last 5 transactions
        final recentTransactions = transactions.take(5).toList();

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Hello ${user.displayName ?? 'User'}',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                fontSize: 24.sp,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.blue,
            automaticallyImplyLeading: false,
            actions: [
              Padding(
                padding: EdgeInsets.only(right: 16.w),
                child: GestureDetector(
                  onTap: () => Get.to(() => NotificationScreen()),
                  child: SvgPicture.asset(
                    'assets/icons/notifications.svg',
                    height: 30.h,
                    width: 30.w,
                    fit: BoxFit.contain,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(top: 40.h, left: 20.w, right: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Container 1: Net Balance
                  Container(
                    width: containerWidth,
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 17.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F5F5),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: Colors.grey, width: 1.w),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.4),
                          blurRadius: 8.r,
                          offset: Offset(0, 2.h),
                        ),
                      ],
                    ),
                    child: Text(
                      'Net Balance: ₹${netBalance.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 19.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 30.h),
                  // Container 2: Income & Expense with Pie Chart
                  Container(
                    width: containerWidth,
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F5F5),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: Colors.grey, width: 1.w),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8.r,
                          offset: Offset(0, 2.h),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 5.w,
                                  height: 50.h,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(5.r),
                                  ),
                                  margin: EdgeInsets.only(right: 8.w),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Income',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                    SizedBox(height: 5.h),
                                    Text(
                                      '₹${totalIncome.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 17.sp,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 10.h),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 5.w,
                                  height: 50.h,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(5.r),
                                  ),
                                  margin: EdgeInsets.only(right: 8.w),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Expense',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                    SizedBox(height: 5.h),
                                    Text(
                                      '₹${totalExpense.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 17.sp,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 140.w,
                          height: 140.h,
                          child: PieChart(
                            PieChartData(
                              sections: [
                                PieChartSectionData(
                                  value: totalIncome,
                                  color: Colors.green,
                                  title: '', // Removed text
                                  radius: 40.r,
                                  titleStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                PieChartSectionData(
                                  value: totalExpense,
                                  title: '', // Removed text
                                  color: Colors.red,
                                  radius: 40.r,
                                  titleStyle: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ],
                              sectionsSpace: 2.w,
                              centerSpaceRadius: 30.r,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30.h),
                  // Container 3: Recent Transactions header and "See all" button
                  Container(
                    padding: EdgeInsets.only(left: 5.w),
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent transaction',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20.sp,
                            fontFamily: 'Inter',
                          ),
                        ),
                        SizedBox(
                          width: 100.w,
                          height: 35.h,
                          child: TextButton(
                            onPressed: () => Get.to(() => const TransactionScreen()),
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(0xFFF6F5F5),
                              side: BorderSide(color: Colors.grey, width: 1.w),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              alignment: Alignment.center,
                            ),
                            child: Text(
                              'See all',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16.sp,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Transaction list (last 5)
                  ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    children: recentTransactions.map((doc) {
                      final transaction = doc.data() as Map<String, dynamic>;
                      return TransactionItem(
                        category: transaction['category'],
                        subtitle: transaction['title'],
                        amount: '₹${transaction['amount'].toStringAsFixed(2)}',
                        isIncome: transaction['isIncome'],
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: const Color(0xFFF6F5F5),
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey,
            currentIndex: _currentIndex,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
              if (index == 1) {
                Get.to(() => const TransactionScreen());
              } else if (index == 3) {
                Get.to(() => NotificationScreen());
              } else if (index == 4) {
                Get.to(() => ProfileScreen());
              }
            },
            items: [
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'assets/icons/home.svg',
                  height: 24.h,
                  width: 24.w,
                  color: _currentIndex == 0 ? Colors.blue : Colors.grey,
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'assets/icons/transaction.svg',
                  height: 24.h,
                  width: 24.w,
                  color: _currentIndex == 1 ? Colors.blue : Colors.grey,
                ),
                label: 'Transactions',
              ),
              BottomNavigationBarItem(
                icon: SizedBox(
                  height: 24.h,
                  width: 24.w,
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'assets/icons/notifications.svg',
                  height: 24.h,
                  width: 24.w,
                  color: _currentIndex == 3 ? Colors.blue : Colors.grey,
                ),
                label: 'Notifications',
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'assets/icons/settings.svg',
                  height: 24.h,
                  width: 24.w,
                  color: _currentIndex == 4 ? Colors.blue : Colors.grey,
                ),
                label: 'Settings',
              ),
            ],
          ),
          floatingActionButton: Container(
            width: 60.w,
            height: 60.h,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.blueAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: FloatingActionButton(
              onPressed: () => Get.to(() => const AddTransaction()),
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Icon(
                Icons.add,
                size: 30.w,
                color: Colors.white,
              ),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        );
      },
    );
  }
}