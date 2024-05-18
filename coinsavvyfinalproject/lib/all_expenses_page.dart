import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_expense_page.dart';
import 'home_page.dart';
import 'auth/login_page.dart';

class AllExpensesPage extends StatefulWidget {
  @override
  _AllExpensesPageState createState() => _AllExpensesPageState();
}

class _AllExpensesPageState extends State<AllExpensesPage> {
  bool _showCredit = true;
  int _selectedIndex = 2;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
      } else if (index == 1) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => AddExpensePage()));
      } else if (index == 3) {
        FirebaseAuth.instance.signOut();
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String userEmail = user?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'All Expenses',
          style: TextStyle(
            fontSize: 24,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
            color: Colors.amber,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.grey[300], // Slightly darker for better contrast
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Space items evenly
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: Text('Credit'),
                    selected: _showCredit,
                    onSelected: (selected) {
                      setState(() {
                        _showCredit = true;
                      });
                    },
                    backgroundColor: Colors.lightGreen[50],
                    selectedColor: Colors.lightGreen[200],
                  ),
                ),
                Expanded(
                  child: ChoiceChip(
                    label: Text('Debit'),
                    selected: !_showCredit,
                    onSelected: (selected) {
                      setState(() {
                        _showCredit = false;
                      });
                    },
                    backgroundColor: Colors.red[50],
                    selectedColor: Colors.red[200],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('expenses')
                  .where('user_email', isEqualTo: userEmail)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return Center(child: Text("No data available"));
                }
                List<DocumentSnapshot> filteredExpenses = snapshot.data!.docs.where((doc) {
                  return doc['category'] == (_showCredit ? 'credit' : 'debit');
                }).toList();

                return ListView.builder(
                  itemCount: filteredExpenses.length,
                  itemBuilder: (context, index) {
                    var expense = filteredExpenses[index];
                    return ListTile(
                      title: Text(expense['name']),
                      subtitle: Text('Amount: \$${expense['amount']}'),
                      tileColor: _showCredit ? Colors.lightGreen[100] : Colors.red[100],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add Expense',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'All Expenses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: 'Logout',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
