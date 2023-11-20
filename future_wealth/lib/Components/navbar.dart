import 'package:flutter/material.dart';

class navBar extends StatelessWidget {
  const navBar({super.key, required this.selectedIndex, required this.onDestinationSelected});

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: const <Widget>[

      NavigationDestination(icon: Icon(Icons.explore), label: 'Home'),
      NavigationDestination(icon: Icon(Icons.commute), label: 'Transaction'),
      NavigationDestination(icon: Icon(Icons.pie_chart), label: 'StockChart'),
      NavigationDestination(icon: Icon(Icons.analytics), label: 'TransactionPieChart')
    ]);
  }
}