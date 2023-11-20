// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:future_wealth/Components/add_transaction.dart';
import 'package:future_wealth/Components/transactionCard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var isLogOutLoading = false;
  // logOut() async{
  //   setState(() {
  //     isLogOutLoading = true;
  //   });
  //   await FirebaseAuth.instance.signOut();
  //   Navigator.of(context).pushReplacement(MaterialPageRoute(builder: ((context)=> Login())));
  //   setState(() {
  //     isLogOutLoading = false;
  //   });

  // }
    final userId = FirebaseAuth.instance.currentUser!.uid; 
 

_dialogBuilder(BuildContext context){
  return showDialog(context: context, builder: (context){
    return AlertDialog(
      content: AddTransaction(),
    );
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purpleAccent,

        onPressed: ((){
          _dialogBuilder(context);
      }),
      child: Icon(Icons.add, color: Colors.white,),
      
      ),
      body: Container(
        width: double.infinity,

        child: SingleChildScrollView(
          child: Column(
            
            children: [
            HeroCard(userId: userId,),
            transactionCard()
            ]
            ),
        )
        ),
    );
  }
}

class HeroCard extends StatelessWidget {
  HeroCard({
    super.key, required this.userId,
  });
  final String userId;


  @override
  Widget build(BuildContext context) {
    final Stream<DocumentSnapshot> _userStream = FirebaseFirestore.instance.collection('users').doc(userId).snapshots();

    return StreamBuilder<DocumentSnapshot>(
      stream: _userStream,
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot){
        if (snapshot.hasError){
          return Text("Something went wrong");

        }
        if(!snapshot.hasData || !snapshot.data!.exists){
          return Text("Document does not exist");
        }
        if(snapshot.connectionState == ConnectionState.waiting){
          return Text("Loading...");
        }
        var data = snapshot.data!.data() as Map<String, dynamic>;
        return Cards(data: data,);
      }
      );
  }
}

class Cards extends StatelessWidget {
  const Cards({
    super.key, required this.data,
  });
  final Map data;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.purple,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
          padding: const EdgeInsets.all(0), //0 pe pura cover kar rha hai
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                      
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Text("Total Balance", style: TextStyle(fontSize: 18, color: Colors.white, height: 1.2, fontWeight: FontWeight.w600),
                  
                  ),
                  Text("₹ ${data['remainingAmount']}", style: TextStyle(fontSize: 50, color: Colors.white, height: 1.2, fontWeight: FontWeight.w600),
                  ),
                      
                      
                    ]
                  ),
              ),
            Container(
              padding: EdgeInsets.only(top: 30, bottom: 10, left: 10, right: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        
                color: Colors.white
              ),
              child: Row(
                children: [
                  CardOne(color: Colors.green, heading: 'Credit', amount: '${data['totalCredit']}',),
                  SizedBox(width: 10,),
                  CardOne(color: Colors.red, heading: 'Debit', amount: '${data['totalDebit']}',),
        
        
              ]),
            )
            ],
          ),
        ),
        ]
      ),
    );
  }
}

class CardOne extends StatelessWidget {
  const CardOne({
    super.key, required this.color, required this.heading, required this.amount,
  });

  final Color color;
  final String heading;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10)
        ),
        
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(heading, style: TextStyle(color: color, fontSize: 14),),
                Text("₹$amount", style: TextStyle(color: color, fontSize: 30, fontWeight: FontWeight.w600),)
              ],
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.all(8.0),

              child: Icon(
                heading == "Credit"?
                Icons.arrow_upward_outlined:Icons.arrow_downward_outlined,
                 color: color,),
            )
          ]),
        ),
      ),
    );
  }
}