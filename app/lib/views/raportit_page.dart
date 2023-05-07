import 'package:flutter/material.dart';

class RaportitPage extends StatelessWidget {
  const RaportitPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.image, size: 100),
            SizedBox(height: 16),
            Text(
              'Coming soon!',
              style: TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}
