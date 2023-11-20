import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:future_wealth/Components/Login.dart';
import 'package:future_wealth/Components/dashboard.dart';
import 'package:future_wealth/Components/SignUp.dart';
import 'package:future_wealth/Components/stock.dart';
import 'package:future_wealth/firebase_options.dart';
import 'package:future_wealth/services/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FutureWealth',
      builder: (context, child){
        return MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0)
        , child: child!);
      },
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        // appBar: AppBar(
        //   title: const Text('FutureWealth'),
        // ),
        
        body: AuthGate()
      ) 
    );
  
}
}