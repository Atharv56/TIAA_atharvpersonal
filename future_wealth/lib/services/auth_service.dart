import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:future_wealth/Components/dashboard.dart';
import 'package:future_wealth/services/db.dart';

class AuthService{
  var db = DB();
  createUser(data, context)async{
    try{
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: data['email'],
        password: data['password']
      );
      await db.addUser(data, context);
    }
    catch(e){
      // print(e);
      showDialog(context: context, builder: (context){
        return AlertDialog(
          title: Text('Login'),
          content: Text(e.toString()),
        );
      });
    }
  }

  login(data, context) async {
    try{
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: data['email'], password: data['password']);
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: ((context)=> Dashboard())));
    }
    catch(e){
      showDialog(context: context, builder: (context){
        return AlertDialog(
          title: Text('login Failed'),
          content: Text(e.toString()),
        );
      }
      );
    }
  }
}