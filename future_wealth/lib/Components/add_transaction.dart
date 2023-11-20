import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:future_wealth/Components/category_dropdown.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class AddTransaction extends StatefulWidget {
  const AddTransaction({super.key});

  @override
  State<AddTransaction> createState() => _AddTransactionState();
}

class _AddTransactionState extends State<AddTransaction> {
  var type = 'credit';
  var category = 'Others';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var isLoader = false;
  var amountEditController = TextEditingController();
  var titleEditController = TextEditingController();
  var uid = Uuid();

  Future<void> _submitForm() async{
    if (_formKey.currentState!.validate()){
      setState(() {
        isLoader = true;
      });
      final user = FirebaseAuth.instance.currentUser;
      int timestamp = DateTime.now().millisecondsSinceEpoch;
      var amount = int.parse(amountEditController.text);
      DateTime date = DateTime.now();

      var id = uid.v4();
      String monthyear = DateFormat('MMM y').format(date);

      final userDoc = await FirebaseFirestore.instance.collection('users')
      .doc(user!.uid)
      .get();

      int remainingAmount = userDoc['remainingAmount'];
      int totalCredit = userDoc['totalCredit'];
      int totalDebit = userDoc['totalDebit'];

      if(type == 'credit'){
        remainingAmount += amount;
        totalCredit += amount;

      }
      else{
        remainingAmount -= amount;
        totalDebit += amount;
      }

      await FirebaseFirestore.instance.collection('users')
      .doc(user.uid).update({
        "remainingAmount": remainingAmount,
        "totalCredit": totalCredit,
        "totalDebit": totalDebit,
        "updatedAt": timestamp
      });

      var data = {
        "id": id,
        "title": titleEditController.text,
        "amount": amount,
        "type": type,
        "timestamp": timestamp,
        "totalCredit": totalCredit,
        "totalDebit": totalDebit,
        "remainingAmount": remainingAmount,
        "monthyear": monthyear,
        "category": category

      };

      await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection("transactions")
      .doc(id)
      .set(data);

      Navigator.pop(context);


      setState(() {
        isLoader = false;
      });
    }
  }

  String? isEmptyCheck(value){
    if(value!.isEmpty){
      return "Please Fill details";
    }
    return null;
  }
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: titleEditController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: isEmptyCheck,
                decoration: InputDecoration(labelText: 'Title'),
          
              ),
              TextFormField(
                controller: amountEditController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: isEmptyCheck,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Amount'),
              ),
              CategoryDropdown(
              cattype: category,
              onChanged: (String? value){
                if (value != null){
                  setState(() {
                  category = value;
                });
                }
              },),
              DropdownButton(
                value: type,
                items: const [
                DropdownMenuItem(value: 'credit',child: Text('Credit'),),
                DropdownMenuItem(value: 'debit',child: Text('Debit'),),
              ], onChanged: (value){
                if(value != null){
                  setState(() {
                  type = value;
                });
                }
                
              })
            
            ,
            SizedBox(height: 16,),
            ElevatedButton(onPressed: (){
              if (isLoader == false){
                _submitForm();
              }
              
            }, child: isLoader ? CircularProgressIndicator()
            
            :Text("Add Transaction"))
            ],
          ),
        ),
      ),
    );
  }
}