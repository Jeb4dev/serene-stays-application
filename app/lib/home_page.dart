import 'package:flutter/material.dart';

import 'login_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final description = Padding(
      padding: const EdgeInsets.all(10),
      child: RichText(
        textAlign: TextAlign.justify,
        text: const TextSpan(
            text: 'Olet kirjautunut sisään.',
            style: TextStyle(color: Colors.black, fontSize: 20)),
      ),
    );
    final buttonLogout = ElevatedButton(
        child: const Text(
          'Kirjaudu ulos',
          style: TextStyle(color: Colors.black87, fontSize: 16),
        ),
        onPressed: () {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const LoginPage()));
        });
    return SafeArea(
        child: Scaffold(
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: <Widget>[description, buttonLogout],
        ),
      ),
    ));
  }
}
