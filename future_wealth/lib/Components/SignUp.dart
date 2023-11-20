import 'package:flutter/material.dart';
import 'package:future_wealth/Components/Login.dart';
import 'package:future_wealth/Components/dashboard.dart';
import 'package:future_wealth/services/auth_service.dart';

class SignUp extends StatefulWidget {
  SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _userNameController = TextEditingController();

  final _emailController = TextEditingController();

  final _phoneController = TextEditingController();

  final _passController = TextEditingController();

  var authService = AuthService();

  var isLoader = false;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()){
      
      setState((){
        isLoader = true;
      });
      var data = {
        "username": _userNameController.text,
        "email": _emailController.text,
        "password": _passController.text,
        "phone": _phoneController.text,
        "remainingAmount": 0,
        "totalCredit": 0,
        "totalDebit": 0
      };
      await authService.createUser(data, context);
      Navigator.push(context, MaterialPageRoute(builder: (context)=>Dashboard()));
      setState((){
        isLoader = false;
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

  String? _validatePhone(value){
    if(value!.isEmpty){
      return "Please Enter a phone number";
    }
    if(value.length != 10){
      return"Please enter a 10-digit phone number";
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
              controller: _userNameController,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                labelText: 'Username',
                suffixIcon:  Icon(Icons.person),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))
                ),
                validator: (value){
                  if(value!.isEmpty){
                    return 'Please enter a username';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0,),
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
              const SizedBox(height: 16.0,),
              TextFormField(
                controller: _phoneController,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                
                labelText: 'Phone Number',
                suffixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))
                ),
                validator: _validatePhone
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
                  onPressed: (){
                    isLoader ? print("loading") : _submitForm();
                  }, 

                  child: isLoader ? Center(child: CircularProgressIndicator(),)
                  :
                  Text('Create')
                )
              ),
              const SizedBox(height: 30,),
              TextButton(
                onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Login(),
                      ),
                    );
                },
                child: const Text(
                  "Login",
                  style: TextStyle(color: Colors.amberAccent, fontSize: 25),
                ),
              )

            ],
          )
        ),
      ),
    );
  }
}