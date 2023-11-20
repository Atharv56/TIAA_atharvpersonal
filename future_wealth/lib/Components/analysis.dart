import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:math';
import 'package:http/http.dart' as http;

class TransactionPieChart extends StatefulWidget {
  @override
  _TransactionPieChartState createState() => _TransactionPieChartState();
}

class _TransactionPieChartState extends State<TransactionPieChart> {
  List<ChartData> debitData = [];
  List<ChartData> creditData = [];
  bool isLoading = true;
  TextEditingController queryController = TextEditingController();
  String advice = '';
  bool isFetchingAdvice = false;

  @override
  void initState() {
    super.initState();
    fetchTransactionData();
  }

  Future<void> fetchTransactionData() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .get();

    final transactions =
        querySnapshot.docs.map((doc) => doc.data()).toList();

    debitData = processTransactions(transactions, 'debit');
    creditData = processTransactions(transactions, 'credit');
    setState(() {
      isLoading = false;
    });
  }

  List<ChartData> processTransactions(
      List<dynamic> transactions, String type) {
    Map<String, int> categoryAmountMap = {};

    transactions.forEach((transaction) {
      final String category = transaction['category'];
      final int amount = transaction['amount'];

      if (transaction['type'] == type) {
        if (categoryAmountMap.containsKey(category)) {
          categoryAmountMap[category] = categoryAmountMap[category]! + amount;
        } else {
          categoryAmountMap[category] = amount;
        }
      }
    });

    Map<String, Color> categoryColors = {};
    categoryAmountMap.keys.forEach((category) {
      categoryColors[category] =
          Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
    });

    List<ChartData> data = categoryAmountMap.entries
        .map((entry) =>
            ChartData(entry.key, entry.value, categoryColors[entry.key]!))
        .toList();
    return data;
  }

  Future<void> sendToFlask(int creditAmount, int debitAmount, String userQuery) async {
    const url = 'http://localhost:5000/advice'; // Replace with your Flask endpoint

    Map<String, dynamic> requestData = {
      'creditAmount': creditAmount.toString(),
      'debitAmount': debitAmount.toString(),
      'userQuery': userQuery,
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 200) {
      print('Data sent successfully!');
      print('Response: ${response.body}');
      var jsonResponse = json.decode(response.body);
      setState(() {
        advice = jsonResponse['advice']; // Store fetched advice
      });
    } else {
      print('Failed to send data. Error: ${response.statusCode}');
    }
  }

  Future<Map> fetchCredAndDeb() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();
    final Map data = querySnapshot.data() as Map;
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction Analysis'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: SfCircularChart(
                      title: ChartTitle(text: 'Debit Analysis'),
                      series: <CircularSeries>[
                        PieSeries<ChartData, String>(
                          dataSource: debitData,
                          xValueMapper: (ChartData data, _) => data.category,
                          yValueMapper: (ChartData data, _) => data.amount,
                          dataLabelSettings: DataLabelSettings(
                            isVisible: true,
                          ),
                          dataLabelMapper: (datum, index) => datum.category,
                          pointColorMapper: (ChartData data, _) =>
                              data.categoryColor,
                          explode: true,
                          explodeIndex: 0,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    child: SfCircularChart(
                      title: ChartTitle(text: 'Credit Analysis'),
                      series: <CircularSeries>[
                        PieSeries<ChartData, String>(
                          dataSource: creditData,
                          xValueMapper: (ChartData data, _) => data.category,
                          yValueMapper: (ChartData data, _) => data.amount,
                          dataLabelSettings: DataLabelSettings(
                            isVisible: true,
                          ),
                          dataLabelMapper: (datum, index) => datum.category,
                          pointColorMapper: (ChartData data, _) =>
                              data.categoryColor,
                          explode: true,
                          explodeIndex: 0,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: TextField(
                      controller: queryController,
                      decoration: InputDecoration(
                        hintText: 'Enter your query and mention your financial goals',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      String userQuery = queryController.text.trim();
                      var deb = await fetchCredAndDeb();
                      setState(() {
                        isFetchingAdvice = true;
                      });
                      await sendToFlask(
                          deb['totalCredit'], deb['totalDebit'], userQuery);
                      setState(() {
                        isFetchingAdvice = false;
                      });
                    },
                    child: Text('Get Financial Advice'),
                  ),
                  SizedBox(height: 20),
                  isFetchingAdvice
                      ? CircularProgressIndicator()
                      : advice.isNotEmpty
                          ? Text(
                              'Advice: $advice',
                              style: TextStyle(fontSize: 12),
                            )
                          : SizedBox(),
                ],
              ),
          ),
    );
  }
}

class ChartData {
  final String category;
  final int amount;
  final Color categoryColor;

  ChartData(this.category, this.amount, this.categoryColor);
}
