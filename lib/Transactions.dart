import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:monyx/HomeScreen.dart';
import 'package:monyx/AddTransaction.dart';
import 'package:intl/intl.dart';
import 'package:monyx/ProfileScreen.dart';
import 'package:monyx/NotificationScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() => runApp(const Transactions());

class Transactions extends StatelessWidget {
  const Transactions({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontFamily: 'Inter'),
          bodyLarge: TextStyle(fontFamily: 'Inter'),
          bodySmall: TextStyle(fontFamily: 'Inter'),
          labelMedium: TextStyle(fontFamily: 'Inter'),
          labelLarge: TextStyle(fontFamily: 'Inter'),
          labelSmall: TextStyle(fontFamily: 'Inter'),
        ),
        fontFamily: 'Inter',
      ),
      home: const TransactionScreen(),
    );
  }
}

// Define category styles (icons + colors + background)
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

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  int _currentIndex = 1;

  // Filter state variables
  String _selectedFilterType = 'All'; // All, Income, Expense
  String? _selectedCategory; // Selected category for filtering
  String _sortBy = 'Newest'; // Default sort by newest

  // Key for RefreshIndicator
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  // Function to handle pull-to-refresh
  Future<void> _refreshTransactions() async {
    // Simulate a network fetch delay for smooth animation
    await Future.delayed(const Duration(milliseconds: 1000));
    setState(() {
      // Reset filters to default to show all transactions
      _selectedFilterType = 'All';
      _selectedCategory = null;
      _sortBy = 'Newest';
    });
    // Force rebuild of StreamBuilder to fetch fresh data
  }

  // Function to show filter bottom sheet with sort options
  void _showFilterBottomSheet(BuildContext context) {
    String tempFilterType = _selectedFilterType;
    String? tempCategory = _selectedCategory;
    String tempSortBy = _sortBy;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter & Sort Transactions',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Type',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ChoiceChip(
                        label: const Text(
                          'All',
                          style: TextStyle(fontFamily: 'Inter'),
                        ),
                        selected: tempFilterType == 'All',
                        onSelected: (selected) {
                          setModalState(() {
                            tempFilterType = 'All';
                          });
                        },
                      ),
                      ChoiceChip(
                        label: const Text(
                          'Income',
                          style: TextStyle(fontFamily: 'Inter'),
                        ),
                        selected: tempFilterType == 'Income',
                        onSelected: (selected) {
                          setModalState(() {
                            tempFilterType = 'Income';
                          });
                        },
                      ),
                      ChoiceChip(
                        label: const Text(
                          'Expense',
                          style: TextStyle(fontFamily: 'Inter'),
                        ),
                        selected: tempFilterType == 'Expense',
                        onSelected: (selected) {
                          setModalState(() {
                            tempFilterType = 'Expense';
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Category',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    isExpanded: true,
                    value: tempCategory ?? 'All',
                    items:
                        ['All', ...categoryStyles.keys].map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(
                              category,
                              style: const TextStyle(fontFamily: 'Inter'),
                            ),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      setModalState(() {
                        tempCategory = newValue == 'All' ? null : newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Sort by',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    isExpanded: true,
                    value: tempSortBy,
                    items:
                        ['Highest', 'Lowest', 'Newest', 'Oldest'].map((
                          String sortOption,
                        ) {
                          return DropdownMenuItem<String>(
                            value: sortOption,
                            child: Text(
                              sortOption,
                              style: const TextStyle(fontFamily: 'Inter'),
                            ),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      setModalState(() {
                        tempSortBy = newValue!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedFilterType = tempFilterType;
                              _selectedCategory = tempCategory;
                              _sortBy = tempSortBy;
                            });
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Apply',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedFilterType = 'All';
                              _selectedCategory = null;
                              _sortBy = 'Newest';
                            });
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Clear',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Function to show bottom sheet with transaction details
  void _showTransactionDetails(
    BuildContext context,
    Map<String, dynamic> transaction,
  ) {
    final DateTime date = (transaction['date'] as Timestamp).toDate();
    final String formattedDate = DateFormat('MMM dd, yyyy').format(date);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Transaction Details',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Title', transaction['title']),
              _buildDetailRow(
                'Amount',
                '₹${transaction['amount'].toStringAsFixed(2)}',
              ),
              _buildDetailRow(
                'Notes',
                transaction['notes']?.isNotEmpty == true
                    ? transaction['notes']
                    : 'No notes',
              ),
              _buildDetailRow('Date', formattedDate),
              _buildDetailRow(
                'Type',
                transaction['isIncome'] ? 'Income' : 'Expense',
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  // Helper widget to build detail rows
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontFamily: 'Inter', fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Please log in to view transactions.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(200, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Go to Login',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('transactions')
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Text(
                'Error loading transactions.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
          );
        }

        // Get transactions from Firestore
        final transactions = snapshot.data?.docs ?? [];

        // Apply filters
        var filteredTransactions =
            transactions.where((doc) {
              final transaction = doc.data() as Map<String, dynamic>;
              bool matchesType = true;
              bool matchesCategory = true;

              // Filter by type (Income/Expense)
              if (_selectedFilterType == 'Income') {
                matchesType = transaction['isIncome'] == true;
              } else if (_selectedFilterType == 'Expense') {
                matchesType = transaction['isIncome'] == false;
              }

              // Filter by category
              if (_selectedCategory != null && _selectedCategory != 'All') {
                matchesCategory = transaction['category'] == _selectedCategory;
              }

              return matchesType && matchesCategory;
            }).toList();

        // Apply sorting
        if (_sortBy == 'Highest') {
          filteredTransactions.sort((a, b) {
            double amountA = (a.data() as Map<String, dynamic>)['amount'];
            double amountB = (b.data() as Map<String, dynamic>)['amount'];
            return amountB.compareTo(amountA); // Descending
          });
        } else if (_sortBy == 'Lowest') {
          filteredTransactions.sort((a, b) {
            double amountA = (a.data() as Map<String, dynamic>)['amount'];
            double amountB = (b.data() as Map<String, dynamic>)['amount'];
            return amountA.compareTo(amountB); // Ascending
          });
        } else if (_sortBy == 'Newest') {
          filteredTransactions.sort((a, b) {
            Timestamp dateA = (a.data() as Map<String, dynamic>)['timestamp'];
            Timestamp dateB = (b.data() as Map<String, dynamic>)['timestamp'];
            return dateB.compareTo(dateA); // Descending (newest first)
          });
        } else if (_sortBy == 'Oldest') {
          filteredTransactions.sort((a, b) {
            Timestamp dateA = (a.data() as Map<String, dynamic>)['timestamp'];
            Timestamp dateB = (b.data() as Map<String, dynamic>)['timestamp'];
            return dateA.compareTo(dateB); // Ascending (oldest first)
          });
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text(
              'Transactions',
              style: TextStyle(
                fontFamily: 'Inter',
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 22,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.blue,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              },
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list, color: Colors.white),
                onPressed: () {
                  _showFilterBottomSheet(context);
                },
              ),
            ],
          ),
          floatingActionButton: Container(
            width: 60,
            height: 60,
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddTransaction(),
                  ),
                );
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: const Icon(Icons.add, size: 30, color: Colors.white),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          body: RefreshIndicator(
            key: _refreshIndicatorKey,
            color: Colors.blue,
            backgroundColor: Colors.white,
            strokeWidth: 3.0,
            displacement: 40.0,
            onRefresh: _refreshTransactions,
            child:
                filteredTransactions.isEmpty
                    ? const Center(
                      child: Text(
                        'No transactions match the selected filters.',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    )
                    : ListView(
                      padding: const EdgeInsets.all(16),
                      children:
                          filteredTransactions.map((doc) {
                            final transaction =
                                doc.data() as Map<String, dynamic>;
                            return GestureDetector(
                              onTap:
                                  () => _showTransactionDetails(
                                    context,
                                    transaction,
                                  ),
                              child: TransactionItem(
                                category: transaction['category'],
                                title: transaction['title'],
                                amount:
                                    '₹${transaction['amount'].toStringAsFixed(2)}',
                                isIncome: transaction['isIncome'],
                              ),
                            );
                          }).toList(),
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
            selectedLabelStyle: const TextStyle(fontFamily: 'Inter'),
            unselectedLabelStyle: const TextStyle(fontFamily: 'Inter'),
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
              if (index == 0) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              } else if (index == 1) {
                // Current screen
              } else if (index == 3) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationScreen()),
                );
              } else if (index == 4) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                );
              }
            },
            items: [
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'assets/icons/home.svg',
                  height: 24,
                  width: 24,
                  color: _currentIndex == 0 ? Colors.blue : Colors.grey,
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'assets/icons/transaction.svg',
                  height: 24,
                  width: 24,
                  color: _currentIndex == 1 ? Colors.blue : Colors.grey,
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
                  height: 24,
                  width: 24,
                  color: _currentIndex == 3 ? Colors.blue : Colors.grey,
                ),
                label: 'Notifications',
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'assets/icons/settings.svg',
                  height: 24,
                  width: 24,
                  color: _currentIndex == 4 ? Colors.blue : Colors.grey,
                ),
                label: 'Settings',
              ),
            ],
          ),
        );
      },
    );
  }
}

class TransactionItem extends StatelessWidget {
  final String category;
  final String title;
  final String amount;
  final bool isIncome;

  const TransactionItem({
    super.key,
    required this.category,
    required this.title,
    required this.amount,
    required this.isIncome,
  });

  @override
  Widget build(BuildContext context) {
    final style =
        categoryStyles[category] ??
        const CategoryStyle(
          icon: Icons.help_outline,
          iconColor: Colors.grey,
          bgColor: Color(0xFFF7F7F7),
        );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: style.bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(style.icon, color: style.iconColor, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isIncome ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
