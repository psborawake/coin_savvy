import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State

{
  double totalBalance = 0.0; // Total balance
  double creditAmount = 0.0; // Total credit amount
  double debitAmount = 0.0; // Total debit amount

  List<Map<String, dynamic>> recentExpenses = [];

  @override
  void initState() {
    super.initState();
    fetchRecentExpenses();
  }

  void fetchRecentExpenses() {
    FirebaseFirestore.instance
        .collection('expenses')
        .orderBy('timestamp', descending: true)
        .limit(5)
        .get()
        .then((QuerySnapshot snapshot) {
      List<Map<String, dynamic>> expenses = [];
      snapshot.docs.forEach((DocumentSnapshot doc) {
        expenses.add({
          'name': doc['name'],
          'category': doc['category'],
          'amount': doc['amount'],
        });
      });
      setState(() {
        recentExpenses = expenses;
        calculateTotalBalance();
      });
    });
  }

  void calculateTotalBalance() {
    double totalCredit = 0.0;
    double totalDebit = 0.0;
    recentExpenses.forEach((expense) {
      if (expense['category'] == 'credit') {
        totalCredit += double.parse(expense['amount']);
      } else {
        totalDebit += double.parse(expense['amount']);
      }
    });
    setState(() {
      totalBalance = totalCredit - totalDebit;
      creditAmount = totalCredit;
      debitAmount = totalDebit;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Tracker'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Total Balance',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '\$$totalBalance',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Expenses',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: Icon(Icons.add),
                  ),
                ],
              ),
            ),
            Container(
              height: 200,
              child: ListView.builder(
                itemCount: recentExpenses.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(recentExpenses[index]['name']),
                    subtitle: Text('${recentExpenses[index]['category']} - \$${recentExpenses[index]['amount']}'),
                    // Color the text based on credit or debit
                    tileColor: recentExpenses[index]['category'] == 'credit'
                        ? Colors.green.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Credit: \$$creditAmount',
                    style: TextStyle(fontSize: 16, color: Colors.green),
                  ),
                  Text(
                    'Debit: \$$debitAmount',
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
