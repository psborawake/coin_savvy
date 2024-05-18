import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';  // Import LoginPage

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String? _email, _name;

  void _signup() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _email!,
          password: _passwordController.text,
        );
        FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'name': _name,
          'email': _email,
        });
        Navigator.pop(context);  // Pop current page and go back to the LoginPage
      } on FirebaseAuthException catch (e) {
        print('Failed to sign up: ${e.message}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.amber)),
      ),
      body: SingleChildScrollView(  // Add SingleChildScrollView here
        child: Form(
          key: _formKey,
          child: Padding(  // Add padding to the content
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset('assets/coin_savvy_logo.webp', width: 150, height: 150), // Add logo here
                SizedBox(height: 20), // Add some spacing
                TextFormField(
                  decoration: InputDecoration(labelText: 'Name'),
                  validator: (value) => value == null || value.isEmpty ? 'Enter your name' : null,
                  onSaved: (value) => _name = value,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => value == null || !value.contains('@') ? 'Enter a valid email' : null,
                  onSaved: (value) => _email = value,
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) => value == null || value.length < 6 ? 'Password must be at least 6 characters long' : null,
                ),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(labelText: 'Confirm Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20), // Add some spacing
                ElevatedButton(
                  onPressed: _signup,
                  child: Text('Sign Up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
