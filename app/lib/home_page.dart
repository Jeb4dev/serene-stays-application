import 'package:flutter/material.dart';
import 'package:serene_stays_app/mokit_page.dart';
import 'alueet_page.dart';
import 'koti_page.dart';
import 'lasku_page.dart';
import 'palvelut_page.dart';
import 'raportit_page.dart';
import 'varaus_page.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = KotiPage();
        break;
      case 1:
        page = MokitPage();
        break;
      case 2:
        page = AlueetPage();
        break;
      case 3:
        page = PalvelutPage();
        break;
      case 4:
        page = VarausPage();
        break;
      case 5:
        page = LaskuPage();
        break;
      case 6:
        page = RaportitPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Serene Stays'),
        ),
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 600, // ← Here.
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.cabin),
                    label: Text('Mökit'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.map_outlined),
                    label: Text('Alueet'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.wine_bar_rounded),
                    label: Text('Palvelut'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.calendar_month_outlined),
                    label: Text('Varaukset'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.mail_outlined),
                    label: Text('Laskut'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.analytics_outlined),
                    label: Text('Raportit'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}
