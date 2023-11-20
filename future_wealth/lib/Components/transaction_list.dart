import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:future_wealth/Components/transactionCard.dart';

class TransactionList extends StatelessWidget {
  TransactionList({super.key, required this.category, required this.type, required this.monthYear});

final userId = FirebaseAuth.instance.currentUser!.uid;
final String category;
final String type;
final String monthYear;



  @override
  Widget build(BuildContext context) {
    Query query = FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .collection('transactions')
    .orderBy('timestamp', descending: true)
    .where('monthyear', isEqualTo: monthYear)
    .where('type', isEqualTo: type);

    if(category != 'All'){
      query = query.where("category", isEqualTo: category);
    }


    return FutureBuilder(
      future: query.limit(150).get(),
     builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
      if(snapshot.hasError){
        return Text('Something went wrong');
      }
      if (snapshot.connectionState == ConnectionState.waiting){
        return Text('Loading...');
      }
      if (!snapshot.hasData || snapshot.data!.docs.isEmpty){
        return Text("No transactions found");
      }
      var data = snapshot.data!.docs;
      return SingleChildScrollView(
        child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: data.length,
        itemBuilder: (context, index){
          var cardData = data[index];
        return TransactionCard(data: cardData);
          },
          ),
      );
    }
     
     
    );
    
  }
}