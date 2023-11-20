import 'package:flutter/material.dart';
import 'package:future_wealth/Components/SignUp.dart';
import 'package:future_wealth/Components/dashboard.dart';
import 'package:future_wealth/services/auth_service.dart';

class Login extends StatefulWidget {
  Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();

  final _passController = TextEditingController();
  var isLoader = false;
  var authService = AuthService();
  
  Future<void> _submitForm() async {
    if(_formKey.currentState!.validate()){
      var data = {
        "email": _emailController.text,
        "password": _passController.text
      };
      await authService.login(data, context);
      
      setState((){
        isLoader = true;
      });
    }
  }

  String? _validateEmail(value){
    if(value!.isEmpty){
      return 'Please Enter an email';
    }
    RegExp emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value)){
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePass(value){
    if(value!.isEmpty){
      return "Please Enter a password";
    }
    if(value.length < 8){
      return"password should be atleast of 8 characters";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
          children: [
            const SizedBox(height: 50,),

            const Text('Create a New Account',
            textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black, fontSize: 28),
            ),
              const SizedBox(height: 25,),
              TextFormField(
              controller: _emailController,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                
                labelText: 'Email',
                suffixIcon: Icon(Icons.email),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))
                ),
                validator: _validateEmail
              ),
              const SizedBox(height: 16,),
              TextFormField(
              controller: _passController,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                
                labelText: 'Password',
                suffixIcon: const Icon(Icons.lock),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))
                ),
                validator: _validatePass,
                obscureText: true,
              ),
              const SizedBox(height: 16.0,),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:(){
                    isLoader ? print("loading") : _submitForm();
                  } , child: isLoader ? Center(child: CircularProgressIndicator())
                  : Text('Login')
                )
              ),
              const SizedBox(height: 30,),
              TextButton(onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SignUp(),
                    ),
                  );
              }, child: Text("Create an Account", style: TextStyle(color: Colors.amberAccent, fontSize: 25),))
            ],
          )
        ),
      ),
    );
  }
}