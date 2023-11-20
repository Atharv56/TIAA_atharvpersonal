  import 'package:flutter/material.dart';
  import 'package:http/http.dart' as http;
  import 'dart:convert';
  import 'package:syncfusion_flutter_charts/charts.dart';
  import 'dart:math';

  class StockChart extends StatefulWidget {
    const StockChart({super.key});

    @override
    // ignore: library_private_types_in_public_api
    _StockChartState createState() => _StockChartState();
  }

  class _StockChartState extends State<StockChart> {
    List<String> selectedTickers = [];
    List<Map<String, dynamic>> stockData = [];
    DateTime? startDate;
    DateTime? endDate;

    Map<String, Color> tickerColors = {};

    List<Color> tickColor = [];

    Future<void> fetchData() async {
      try {
        final response = await http.post(
          Uri.parse('http://127.0.0.1:5000/stock_data'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'tickers': selectedTickers,
            'start_time': startDate?.toIso8601String().substring(0, 10),
            'end_time': endDate?.toIso8601String().substring(0, 10),
          }),
        );

        final Map<String, dynamic> responseData = jsonDecode(response.body);

        stockData.clear();
        tickerColors.clear();
        tickColor.clear();

        for (String ticker in selectedTickers) {
          List<dynamic> stockValues = responseData[ticker];
          List<Map<String, dynamic>> formattedData = stockValues
              .asMap()
              .entries
              .map((entry) => {'index': entry.key, 'name': ticker, 'value': entry.value})
              .toList();

          stockData.addAll(formattedData);
          // print(stockData);

          // Assign random colors to tickers
          
          var col = Color((Random().nextDouble() * 0xFFFFFF).toInt())
              .withOpacity(1.0);
          tickerColors[ticker] = col;
          tickColor.add(col);

        }
        // print(tickerColors);

        setState(() {});
      } catch (error) {
        // ignore: avoid_print
        print('Error fetching data: $error');
      }
    }

    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Wrap(
                      children: selectedTickers.map((ticker) {
                        return Chip(
                          label: Text(ticker),
                          backgroundColor: tickerColors[ticker],
                          deleteIconColor: Colors.black,
                          onDeleted: () {
                            setState(() {
                              selectedTickers.remove(ticker);
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    DropdownButton<String>(
                      value: null,
                      items: <String>[
                        'TSL',
                        'AAPL',
                        'BTC-USD',
                        'ETH-USD',
                        'ADBE',
                        'AXS',
                        'BBAX',
                        'BCS',
                        'MSFT',
                        'AMZN',
                        'GOOGL',
                        'FB',
                        'TSLA',
                        'NFLX',
                        'JPM',
                        'JNJ',
                        'XRP-USD'
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          if (newValue != null) {
                            if (selectedTickers.contains(newValue)) {
                              selectedTickers.remove(newValue);
                            } else {
                              selectedTickers.add(newValue);
                            }
                          }
                        });
                      },
                      hint: const Text('Select Tickers (Multiple)'),
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down),
                      iconSize: 36,
                      iconEnabledColor: Colors.blue,
                      selectedItemBuilder: (BuildContext context) {
                        return selectedTickers.map<Widget>((String item) {
                          return Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            margin: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item,
                              style: const TextStyle(fontSize: 14),
                            ),
                          );
                        }).toList();
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            ).then((value) {
                              setState(() {
                                startDate = value;
                              });
                            });
                          },
                          child: Text(
                            startDate != null
                                ? 'Start Date: ${startDate!.toString().substring(0, 10)}'
                                : 'Select Start Date',
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            ).then((value) {
                              setState(() {
                                endDate = value;
                              });
                            });
                          },
                          child: Text(
                            endDate != null
                                ? 'End Date: ${endDate!.toString().substring(0, 10)}'
                                : 'Select End Date',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        fetchData();
                      },
                      child: const Text('Fetch Data'),
                    ),
                    
                  SingleChildScrollView(
                    // scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      height: 500,
                      width: MediaQuery.of(context).size.height,
                      // width: 150,
                      child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch, 
                children: <Widget>[
                  Flexible(
                    flex: 2,
                      // scrollDirection: Axis.horizontal,
                    child: stockData.isNotEmpty
                    ?SfCartesianChart(
                    
                        primaryXAxis: CategoryAxis(),
                        legend: const Legend(
                          isVisible: true,
                          overflowMode: LegendItemOverflowMode.wrap,
                          position: LegendPosition.bottom,
                        ),
                        series: [
                          for (String ticker in selectedTickers)
                            LineSeries<Map<String, dynamic>, int>(
                              dataSource: stockData
                                  .where((data) =>
                                      data['index'] != null &&
                                      data['value'] != null &&
                                      data['name'] == ticker)
                                  .toList(),
                              xValueMapper: (Map<String, dynamic> data, _) =>
                                  data['index'],
                              yValueMapper: (Map<String, dynamic> data, _) =>
                                  data['value'],
                              name: ticker,
                              // Assigning color based on the ticker
                              color: tickerColors[ticker],
                              // pointColorMapper: (datum, index) => tickColor[index],
                              
                              // pointColorMapper: (datum, index) {
                              //   print(datum);
                              //   return tickerColors[datum];
                              // },
                              //     tickerColors[ticker],
                              // Disable the line connecting points
                              enableTooltip: true,
                              // enableSmartLabels: true,
                              dashArray: <double>[0,0],
                              width: 0
                            ),
                        ],
                      ): const Center(
                        child: Text('No data available'),
                    ),
                    ),
                    
                  
                  const SizedBox(height: 20,),
                  const Expanded(flex: 2,child: ChatWidget(),)   
                ]
                      ),
                    ),
            ),
              
              
                  ], 
                ),
              ),
            ),
          ),
        ),
      );
    }

  }

  class ChatWidget extends StatefulWidget {
    const ChatWidget({Key? key}) : super(key: key);

    @override
    // ignore: library_private_types_in_public_api
    _ChatWidgetState createState() => _ChatWidgetState();
  }

  class _ChatWidgetState extends State<ChatWidget> {
    final TextEditingController _textController = TextEditingController();
    String prediction = '';

    Future<void> fetchPrediction(String quote) async {
      try {
        final response = await http.post(
          Uri.parse('http://127.0.0.1:5000/chat'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'quote': quote}),
        );

        final Map<String, dynamic> responseData = jsonDecode(response.body);
        setState(() {
          prediction = responseData['message'];
        });
        print(prediction);
      } catch (error) {
        print('Error fetching prediction: $error');
      }
    }

    @override
    void dispose() {
      _textController.dispose();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextField(
            controller: _textController,
            decoration: const InputDecoration(
              labelText: 'Enter the Quote',
            ),
          ),
          ElevatedButton(
            onPressed: () {
              fetchPrediction(_textController.text);
            },
            child: const Text('Predict'),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Prediction: $prediction',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      );
    }
  }
