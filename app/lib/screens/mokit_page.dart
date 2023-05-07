import 'package:flutter/material.dart';

// Tää on pohja mökkilistalle

const int itemCount = 10;

class MokitPage extends StatelessWidget {
  const MokitPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: itemCount,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text('Cabin ${index + 1}'),
          );
        });
  }
}
