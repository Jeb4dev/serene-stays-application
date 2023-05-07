import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Admin Bottom Navigation Example',
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const Center(child: Text('Home')),
    const AdminPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mökki App'),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings), label: "Admin"),
        ],
      ),
    );
  }
}

class AdminPage extends StatelessWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          leading: const Icon(Icons.people),
          title: const Text('Käyttäjät'),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.book_online),
          title: const Text('Varaukset'),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.bar_chart),
          title: const Text('Raportit'),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.location_city),
          title: const Text('Alueet'),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.receipt),
          title: const Text('Laskut'),
          onTap: () {},
        ),
      ],
    );
  }
}
