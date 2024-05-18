import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signup_page.dart';  // Import SignupPage
import 'package:coin_savvy/home_page.dart';   // Import HomePage

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String? _email, _password;

  @override
  void initState() {
    super.initState();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _email!,
          password: _password!,
        );
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
      } on FirebaseAuthException catch (e) {
        print('Failed to login: ${e.message}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove the back arrow
        title: Text('Coin Savvy', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.amber)),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/coin_savvy_logo.webp', width: 150, height: 150), // Add logo here
            SizedBox(height: 20), // Add some spacing
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Email'),
                    validator: (value) => value != null && !value.contains('@') ? 'Enter a valid email' : null,
                    onSaved: (value) => _email = value,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (value) => value != null && value.isEmpty ? 'Enter a password' : null,
                    onSaved: (value) => _password = value,
                  ),
                  SizedBox(height: 20), // Add some spacing
                  ElevatedButton(
                    onPressed: _login,
                    child: Text('Login'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SignupPage())),
                    child: Text('No account? Sign up'),
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
