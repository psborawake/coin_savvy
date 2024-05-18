import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'home_page.dart';
import 'all_expenses_page.dart';
import 'auth/login_page.dart';

class AddExpensePage extends StatefulWidget {
  @override
  _AddExpensePageState createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String _category = 'credit';
  File? _receiptImage;

  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _receiptImage = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> uploadImage(File imageFile) async {
    const uuid = Uuid();
    final String filename = uuid.v4();
    try {
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('receipts')
          .child('12345.jpg');
      await ref.putFile(imageFile);
      String imageUrl = await ref.getDownloadURL();
      saveExpenseToFirestore(imageUrl);
    } catch (e) {
      print(e);
    }
  }

  void saveExpenseToFirestore(String imageUrl) {
    final name = _nameController.text.trim();
    final amount = _amountController.text.trim();
    final category = _category;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    User? user = FirebaseAuth.instance.currentUser;
    String userEmail = user?.email ?? "no-email";  // Default to "no-email" if user is null

    FirebaseFirestore.instance.collection('expenses').add({
      'name': name,
      'amount': amount,
      'category': category,
      'image_url': imageUrl,
      'timestamp': timestamp,
      'user_email': userEmail,  // Store the user's email with the expense
    }).then((value) {
      Navigator.pop(context); // Redirect to home page
    }).catchError((error) {
      print("Failed to add expense: $error");
    });
  }

  int _selectedIndex = 1;
  void _onItemTapped(int index) {
    setState(() {
      if (index == 0) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else if(index == 2) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AllExpensesPage()),
        );
      }
      else if(index == 3) {
        FirebaseAuth.instance.signOut();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: Text(
          'Add Expense',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.amber),
        ),
      ),
      body: SingleChildScrollView( // Add SingleChildScrollView here
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField(
                    value: _category,
                    onChanged: (value) {
                      setState(() {
                        _category = value.toString();
                      });
                    },
                    items: ['credit', 'debit']
                        .map(
                          (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category.toUpperCase()),
                      ),
                    )
                        .toList(),
                    decoration: InputDecoration(labelText: 'Category'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: getImage,
                    child: Icon(Icons.camera_alt),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            _receiptImage != null
                ? Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: FileImage(_receiptImage!),
                  fit: BoxFit.cover,
                ),
              ),
            )
                : SizedBox(),
            SizedBox(height: 20),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _receiptImage != null
                  ? () {
                uploadImage(_receiptImage!);
              }
                  : null,
              child: Text('Add Expense'),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.lightBlue[100],
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
