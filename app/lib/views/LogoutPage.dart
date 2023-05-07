import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

import '../data/User.dart';
import '../screens/LoginPage.dart';
import '../utils/auth.dart';

class ResponseData {
  final String message;
  final User user;

  ResponseData(this.message, this.user);
}

class LogoutPage extends StatelessWidget {
  LogoutPage({super.key});

  Future<ResponseData> getUserData() async {
    var token = await storage.read(key: 'jwt');
    var response = await get(
      Uri.parse('http://127.0.0.1:8000/api/user/'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );
    var responseData = json.decode(response.body);
    User user = User(
        responseData['data']['username'],
        responseData['data']['email'],
        responseData['data']['first_name'],
        responseData['data']['last_name'],
        responseData['data']['address'],
        responseData['data']['phone'],
        responseData['data']['zip']);
    return ResponseData(responseData['result'], user);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<ResponseData>(
        future: getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              ResponseData data = snapshot.data!;
              // display data here
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Tervetuloa, ${data.user.username}!"),
                      const Icon(Icons.key, size: 100),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginPage()));
                        },
                        child: const Text('Kirjaudu Ulos'),
                      ),
                    ],
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              // handle error here
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Tervetuloa, tuntematon käyttäjä!"),
                      const SizedBox(height: 50),
                      const Icon(Icons.key, size: 100),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginPage()));
                        },
                        child: const Text('Kirjaudu sisään'),
                      ),
                    ],
                  ),
                ),
              );
            }
          }
          // handle other connection states here
          return CircularProgressIndicator();
        },
      ),
    );
  }
}
