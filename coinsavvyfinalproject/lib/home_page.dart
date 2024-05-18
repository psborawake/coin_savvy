import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_expense_page.dart';
import 'all_expenses_page.dart';
import 'auth/login_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double totalBalance = 0.0; // Total balance
  double creditAmount = 0.0; // Total credit amount
  double debitAmount = 0.0; // Total debit amount
  String userName = "Loading..."; // Initial user name placeholder
  String userEmail = ""; // User email address

  List<Map<String, dynamic>> recentExpenses = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userEmail = user.email ?? "";
      fetchUserName(user.uid);
      fetchExpenses();
    }
  }

  void fetchUserName(String uid) {
    FirebaseFirestore.instance.collection('users').doc(uid).get().then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists && documentSnapshot.data() != null) {
        setState(() {
          userName = documentSnapshot.get('name');
        });
      }
    });
  }

  void fetchExpenses() {
    FirebaseFirestore.instance
        .collection('expenses')
        .where('user_email', isEqualTo: userEmail)
        .orderBy('timestamp', descending: true)
        .get()
        .then((QuerySnapshot snapshot) {
      double localTotalCredit = 0.0;
      double localTotalDebit = 0.0;
      List<Map<String, dynamic>> expenses = [];
      snapshot.docs.forEach((DocumentSnapshot doc) {
        Map<String, dynamic> expense = {
          'name': doc['name'],
          'category': doc['category'],
          'amount': doc['amount'],
        };

        if (expense['category'] == 'credit') {
          localTotalCredit += double.parse(expense['amount'].toString());
        } else if (expense['category'] == 'debit') {
          localTotalDebit += double.parse(expense['amount'].toString());
        }

        expenses.add(expense);
      });

      setState(() {
        recentExpenses = expenses.sublist(0, expenses.length > 10 ? 10 : expenses.length);
        totalBalance = localTotalCredit - localTotalDebit;
        creditAmount = localTotalCredit;
        debitAmount = localTotalDebit;
      });
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      switch (index) {
        case 1:
          Navigator.push(context, MaterialPageRoute(builder: (context) => AddExpensePage())).then((_) => fetchExpenses());
          break;
        case 2:
          Navigator.push(context, MaterialPageRoute(builder: (context) => AllExpensesPage())).then((_) => fetchExpenses());
          break;
        case 3:
          FirebaseAuth.instance.signOut().then((_) {
            setState(() {
              totalBalance = 0.0;
              creditAmount = 0.0;
              debitAmount = 0.0;
              userName = "Loading...";
              userEmail = "";
              recentExpenses = [];
              _selectedIndex = 0;
            });
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
          });
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue,
        title: Text(userName, style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.amber)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.blue,
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Total Balance', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text('\$$totalBalance', style: TextStyle(fontSize: 72, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(top: 8.0),
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.lightGreenAccent.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Credit', style: TextStyle(fontSize: 16, color: Colors.green)),
                          Text('\$$creditAmount', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(top: 8.0),
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Debit', style: TextStyle(fontSize: 16, color: Colors.red)),
                          Text('\$$debitAmount', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recent Expenses', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => AddExpensePage())).then((_) => fetchExpenses());
                    },
                    child: Icon(Icons.add),
                  ),
                ],
              ),
            ),
            Container(
              height: 400,
              child: ListView.builder(
                itemCount: recentExpenses.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(recentExpenses[index]['name']),
                    subtitle: Text('${recentExpenses[index]['category']} - \$${recentExpenses[index]['amount']}'),
                    tileColor: recentExpenses[index]['category'] == 'credit' ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add Expense'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'All Expenses'),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Logout'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
