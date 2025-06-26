import 'dart:io' show Platform; // Add for Platform.isAndroid
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'notification_service.dart';
import 'HomeScreen.dart';
import 'LoginScreen.dart';
import 'Transactions.dart';
import 'ProfileScreen.dart';
import 'AddTransaction.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    // Check if user is authenticated
    if (FirebaseAuth.instance.currentUser == null) {
      Get.snackbar('Error', 'Please sign in to access reminders',
          backgroundColor: Colors.red, colorText: Colors.white);
      Get.off(() => const LoginScreen());
    }
  }

  void _showAddReminderForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => const AddReminderForm(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontFamily: 'Inter',
          fontSize: 22.sp,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 24.sp),
          color: Colors.white,
          onPressed: () => Get.back(),
        ),
        title: Text('Notifications', style: TextStyle(fontSize: 22.sp)),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('reminders')
                    .where('userId',
                    isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading reminders: ${snapshot.error}',
                        style: TextStyle(fontSize: 16.sp, color: Colors.red),
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        'No reminders found',
                        style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                      ),
                    );
                  }
                  final reminders = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: reminders.length,
                    itemBuilder: (context, index) {
                      final reminder = reminders[index].data() as Map<String, dynamic>;

                      // ✅ Safe parsing of 'dateTime'
                      final dynamic rawDate = reminder['dateTime'];
                      DateTime reminderDate;

                      if (rawDate is Timestamp) {
                        reminderDate = rawDate.toDate();
                      } else if (rawDate is String) {
                        try {
                          reminderDate = DateTime.parse(rawDate);
                        } catch (e) {
                          reminderDate = DateTime.now();
                        }
                      } else {
                        reminderDate = DateTime.now();
                      }

                      return NotificationCard(
                        title: reminder['title'] ?? 'Untitled',
                        date: DateFormat('dd-MM-yyyy').format(reminderDate),
                        amount: '₹${(reminder['amount'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                        category: reminder['category'] ?? 'Unknown',
                        frequency: reminder['frequency'] ?? 'Unknown',
                      );
                    },
                  );

                },
              ),
            ),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.blue, Colors.blueAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: ElevatedButton(
                onPressed: _showAddReminderForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                child: Text(
                  'Add Reminder',
                  style: TextStyle(fontSize: 16.sp, color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
      floatingActionButton: Container(
        width: 60.w,
        height: 60.w,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.blueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FloatingActionButton(
          onPressed: () {
            Get.to(() => const AddTransaction());
          },
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
        currentIndex: 3,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        onTap: (index) {
          switch (index) {
            case 0:
              Get.off(() => const HomeScreen());
              break;
            case 1:
              Get.off(() => const Transactions());
              break;
            case 3:
              break;
            case 4:
              Get.off(() => const ProfileScreen());
              break;
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/home.svg',
              height: 24.w,
              width: 24.w,
              colorFilter:
              const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/transaction.svg',
              height: 24.w,
              width: 24.w,
              colorFilter:
              const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
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
              height: 24.w,
              width: 24.w,
              colorFilter:
              const ColorFilter.mode(Colors.blue, BlendMode.srcIn),
            ),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/settings.svg',
              height: 24.w,
              width: 24.w,
              colorFilter:
              const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
            ),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class AddReminderForm extends StatefulWidget {
  const AddReminderForm({super.key});

  @override
  State<AddReminderForm> createState() => _AddReminderFormState();
}

class _AddReminderFormState extends State<AddReminderForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedCategory = 'Bills';
  String _selectedFrequency = 'Monthly';
  DateTime _selectedDateTime = DateTime.now();

  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        Get.snackbar('Error', 'Please sign in to add reminders',
            backgroundColor: Colors.red, colorText: Colors.white);
        Navigator.pop(context);
        Get.off(() => const LoginScreen());
        return;
      }

      if (_selectedDateTime.isBefore(DateTime.now())) {
        Get.snackbar('Error', 'Please select a future date and time',
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      final id = const Uuid().v4();
      final reminder = {
        'id': id,
        'title': _titleController.text,
        'amount': double.parse(_amountController.text),
        'category': _selectedCategory,
        'frequency': _selectedFrequency,
        'dateTime': Timestamp.fromDate(_selectedDateTime),
        'notes': _notesController.text,
        'userId': user.uid,
      };

      await FirebaseFirestore.instance.collection('reminders').doc(id).set(reminder);


      try {
        await FirebaseFirestore.instance.collection('reminders').doc(id).set(reminder);
        print('Reminder saved to Firestore: $id');

        // Request notification permission
        final permissionStatus = await Permission.notification.status;
        if (permissionStatus.isDenied || permissionStatus.isPermanentlyDenied) {
          final status = await Permission.notification.request();
          if (!status.isGranted) {
            Get.snackbar(
              'Permission Required',
              'Please allow notification permission in settings',
              backgroundColor: Colors.orange,
              colorText: Colors.white,
            );
            return;
          }
        }

        if (Platform.isAndroid) {
          await NotificationService().requestDisableBatteryOptimization();
        }

        // ✅ Schedule notifications based on saved Firestore data
        await NotificationService().fetchAndScheduleReminders();

        _titleController.clear();
        _amountController.clear();
        _notesController.clear();

        setState(() {
          _selectedCategory = 'Bills';
          _selectedFrequency = 'Monthly';
          _selectedDateTime = DateTime.now();
        });

        Get.snackbar('Success', 'Reminder added successfully',
            backgroundColor: Colors.blue, colorText: Colors.white);
        Navigator.pop(context);
      } catch (e) {
        print('Reminder addition error: $e');
        Get.snackbar('Error', 'Failed to add reminder: $e',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.w).copyWith(
          bottom: MediaQuery.of(context).viewInsets.bottom + 32.h,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Reminder',
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                style: TextStyle(fontSize: 16.sp),
                validator: (value) =>
                value!.isEmpty ? 'Title is required' : null,
              ),
              SizedBox(height: 12.h),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                keyboardType: TextInputType.number,
                style: TextStyle(fontSize: 16.sp),
                validator: (value) =>
                value!.isEmpty || double.tryParse(value) == null
                    ? 'Valid amount is required'
                    : null,
              ),
              SizedBox(height: 12.h),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                style: TextStyle(fontSize: 16.sp, color: Colors.black),
                items: ['Bills', 'Subscriptions', 'Rent', 'Other']
                    .map((category) => DropdownMenuItem(
                  value: category,
                  child: Text(category),
                ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedCategory = value!),
              ),
              SizedBox(height: 12.h),
              DropdownButtonFormField<String>(
                value: _selectedFrequency,
                decoration: InputDecoration(
                  labelText: 'Frequency',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                style: TextStyle(fontSize: 16.sp, color: Colors.black),
                items: ['Daily', 'Weekly', 'Monthly', 'Custom']
                    .map((frequency) => DropdownMenuItem(
                  value: frequency,
                  child: Text(frequency),
                ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedFrequency = value!),
              ),
              SizedBox(height: 12.h),
              ListTile(
                title: Text(
                  'Date & Time: ${DateFormat('MMM dd, yyyy HH:mm').format(_selectedDateTime)}',
                  style: TextStyle(fontSize: 16.sp),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  side: BorderSide(color: Colors.grey[300]!),
                ),
                onTap: _selectDateTime,
              ),
              SizedBox(height: 12.h),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Notes (Optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                maxLines: 2,
                style: TextStyle(fontSize: 16.sp),
              ),
              SizedBox(height: 16.h),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.blue, Colors.blueAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: Text(
                    'Add',
                    style: TextStyle(fontSize: 16.sp, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final String title;
  final String date;
  final String amount;
  final String category;
  final String frequency;

  const NotificationCard({
    super.key,
    required this.title,
    required this.date,
    required this.amount,
    required this.category,
    required this.frequency,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Amount: $amount',
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                ),
                Text(
                  'Category: $category',
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                ),
                Text(
                  'Frequency: $frequency',
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(
            date,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}