import 'package:flutter/material.dart';
import 'AreaManagementPage.dart';
import 'LogoutPage.dart';
import 'BillingPage.dart';
import 'RaportPage.dart';
import 'ReservationPage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    AreaManagementPage(),
    ReservationPage(),
    LogoutPage(),

    // Add more pages here as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservation System'),
      ),
      body: Row(
        children: <Widget>[
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home),
                label: Text('Alueet'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.tab),
                label: Text('Varaukset'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.key),
                label: Text('Kirjautuminen'),
              ),
              // Add more destinations here as needed
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _pages[_selectedIndex],
          ),
        ],
      ),
    );
  }
}
