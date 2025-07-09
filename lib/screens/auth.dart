import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {

  final _globalKey = GlobalKey<FormState>();

  bool _isLogin = false;
  String _email = "";
  String _password = "";
  String _username = "";

  void _save() async{
    if (!_globalKey.currentState!.validate()){
      return;
    }
    _globalKey.currentState!.save();

    try{
      var cred;
      if (_isLogin){
        final userCredentials = await _firebase.signInWithEmailAndPassword(email: _email, password: _password);
        cred = userCredentials;
      }
      else{
        final userCredentials = await _firebase.createUserWithEmailAndPassword(email: _email, password: _password);
        cred = userCredentials;
      }
      FirebaseFirestore.instance.
        collection('users').
        doc(cred.user!.uid).
        set({
        'username' : _username,
        'email' : _email,
      });
    }
    on FirebaseAuthException catch(error){
      if (error.code == 'email-already-in-use'){

      }
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error.message ?? 'Authentication failed'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(top: 30, left: 20, right: 20, bottom: 20),
                width: 200,
                child: Image.asset('assets/images/chat.png'),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _globalKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            decoration: InputDecoration(
                              label: Text('Email Address'),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty || !value.contains('@')){
                                return 'The email address is invalid';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _email = value!;
                            },
                          ),
                          if (!_isLogin) TextFormField(
                            decoration: InputDecoration(
                              label: Text('Username'),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty || value.trim().length < 4){
                                return 'Username should be at least 4 characters';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _username = value!;
                            },
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              label: Text('Password'),
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty || value.trim().length < 6){
                                return 'The password must be at least 6 characters long';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _password = value!;
                            },
                          ),
                          const SizedBox(height: 12,),
                          ElevatedButton(
                            onPressed: _save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                            ),
                            child: Text(_isLogin ? 'Login' : 'Signup'),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLogin = !_isLogin;
                              });
                            },
                            child: Text(_isLogin ? 'Create Account' : 'I Already have an account'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
