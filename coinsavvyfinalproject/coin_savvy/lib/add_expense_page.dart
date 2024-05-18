import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';

class AddExpensePage extends StatefulWidget {
  @override
  _AddExpensePageState createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State

{
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String _category = 'credit';
  File? _receiptImage;

  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    //picker.getImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _receiptImage = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> uploadImage(File imageFile) async {
    try {
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('receipts')
          .child('${DateTime.now()}.png');
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
    FirebaseFirestore.instance.collection('expenses').add({
      'name': name,
      'amount': amount,
      'category': category,
      'image_url': imageUrl,
      'timestamp': timestamp,
    }).then((value) {
      Navigator.pop(context);
    }).catchError((error) {
      print("Failed to add expense: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Expense'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
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
    );
  }
}
