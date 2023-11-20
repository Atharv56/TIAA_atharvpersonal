import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:future_wealth/utils/icons_list.dart';
import 'package:intl/intl.dart';

class transactionCard extends StatelessWidget {
  transactionCard({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                Row(children: [
                  Text("Recent Transactions", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),)
                ],
                ),
                RecentTransaction()
              ],
            ),
          );
  }
}

class RecentTransaction extends StatelessWidget {
  RecentTransaction({
    super.key,
  });
  final userId = FirebaseAuth.instance.currentUser!.uid;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(stream: FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .collection('transactions')
    .orderBy('timestamp', descending: true)
    .limit(20)
    .snapshots(),
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
      return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: data.length,
      itemBuilder: (context, index){
        var cardData = data[index];
      return TransactionCard(data: cardData);
    },
    );
    }
     
     
    );
    
  }
}

class TransactionCard extends StatelessWidget {
  TransactionCard({
    super.key, required this.data
  });
    final dynamic data;
    var appIcons = AppIcons();

  @override
  Widget build(BuildContext context) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(data['timestamp']);

    String formattedDate = DateFormat('d MMM hh:mma').format(date);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 10),
              color: Colors.grey.withOpacity(0.09),
              blurRadius: 10.0,
              spreadRadius: 4.0
            )
          ]
        ),
        child: ListTile(
          minVerticalPadding: 10,
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          leading: Container(
            width: 70,
            height: 100,
            child: Container(
              width: 30, 
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: data['type'] == 'credit'?
                Colors.green.withOpacity((0.2)) 
                : Colors.red.withOpacity((0.2))
              ),
              child: Center(
                child: FaIcon(
                  appIcons.getExpenseCategoryIcons(
                    '${data['category']}'
                  )
                ),
              ),
            ),
          ),
          title: Row(

            children: [
              Expanded(child: Text('${data['title']}')),
              Text("${data['type']=='credit'? '+':'-'} ₹${data['amount']}", style: TextStyle(
                
                color: data['type'] == 'credit'?
                Colors.green
                : Colors.red          
                ),
                )
      
            ],
            
          ),
          subtitle: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Row(
              children: [
                Text("balance", style: TextStyle(color: Colors.grey, fontSize: 13)),
                Spacer(),
                Text("₹${data['remainingAmount']}", style:  TextStyle(color: Colors.grey, fontSize: 13),)
              ],
            ),
            Text(formattedDate, style: TextStyle(color: Colors.grey, fontSize: 13),)
          ]),
        ),
      ),
    );
  }
}