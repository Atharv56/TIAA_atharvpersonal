
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:future_wealth/Components/Login.dart';
import 'package:future_wealth/Components/analysis.dart';
import 'package:future_wealth/Components/home.dart';
import 'package:future_wealth/Components/navbar.dart';
import 'package:future_wealth/Components/stock.dart';
import 'package:future_wealth/Components/transaction.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {

  int currentIndex = 0;
  var pageViewList = [

    HomeScreen(),
    TransactionScreen(),
    StockChart(),
    TransactionPieChart(),
  ];

  var isLogOutLoading = false;
  logOut() async{
    setState(() {
      isLogOutLoading = true;
    });
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: ((context)=> Login())));
    setState(() {
      isLogOutLoading = false;
    });

  }



  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      bottomNavigationBar: navBar(selectedIndex: currentIndex, onDestinationSelected: (int value){
        setState(() {
          currentIndex = value;
        });
      }),
      appBar: AppBar(
        elevation: 0,
        
        title: const Text(
            "Hey, ",
            style: TextStyle(color: Colors.black, fontSize: 20),
            textAlign: TextAlign.left,
          ),

        automaticallyImplyLeading: false,
        actions: [
          
          IconButton(onPressed: (){
            logOut();
            }, 
          icon: 
          isLogOutLoading ? CircularProgressIndicator()

          :Icon(Icons.exit_to_app)
          )
          ]
          ),
          body: pageViewList[currentIndex],
    );
  }
}