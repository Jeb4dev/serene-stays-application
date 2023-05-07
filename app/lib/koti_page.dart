import 'package:flutter/material.dart';
import 'login_page.dart';

class KotiPage extends StatelessWidget {
  const KotiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.key, size: 100),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const LoginPage()));
              },
              child: const Text('Kirjaudu Ulos'),
            ),
          ],
        ),
      ),
    );
  }
}
