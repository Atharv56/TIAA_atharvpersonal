import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:future_wealth/Components/Login.dart';
import 'package:future_wealth/Components/dashboard.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>
    (stream: FirebaseAuth.instance.authStateChanges(), 
    builder: (context, snapshot){
      if(!snapshot.hasData){
        return Login();
      }
      return Dashboard();
    }
    );
  }
}