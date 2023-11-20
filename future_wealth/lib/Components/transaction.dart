import 'package:flutter/material.dart';
import 'package:future_wealth/Components/category_list.dart';
import 'package:future_wealth/Components/tab_bar_view.dart';
import 'package:future_wealth/Components/timeLine_month.dart';
import 'package:intl/intl.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  var category = 'All';
  var monthYear = "";
  

  @override
  void initState(){
    super.initState();
    DateTime now = DateTime.now();
    setState(() {
      monthYear = DateFormat('MMM y').format(now);
    });
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Expenses"),
      ),
      body: Column(children: [
        TimeLineMonth(
          onChanged: (String? value){
            if (value!= null){
              setState(() {
                monthYear = value;
              });
              
            }
          },
        ),
        CategoryList(onChanged: (String? value){
          if (value!= null){
            setState(() {
              category = value;
            });
            
          }
        }
        ),
        TypeTabBar(category: category, monthYear: monthYear,)
      ],)
      
      
      );
  }
}