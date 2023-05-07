import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:serene_stays_app/screens/RegisterPage.dart';

import '../utils/auth.dart';
import 'HomePage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String errorText = "";

  void login(String email, password) async {
    setState(() {
      errorText = '';
    });
    try {
      Response response = await post(
          Uri.parse('http://127.0.0.1:8000/api/user/login'),
          body: {'email': email, 'password': password});

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());
        var token = data['jwt'];
        await storage.write(key: 'jwt', value: token);
        print('Login successfully');
      } else {
        var data = jsonDecode(response.body.toString());
        setState(() {
          errorText = data['message'];
        });
      }
    } catch (e) {
      setState(() {
        errorText = 'Login failed, please try again later';
      });
      print(e);
    }

    if (errorText == '') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Serene Stays'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Center(
          child: Column(
            children: [
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'Sähköposti',
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'Salasana',
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              // login error text
              Text("$errorText", key: Key("textKey")),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: () {
                  login(emailController.text.toString(),
                      passwordController.text.toString());
                },
                child: const Text('Kirjaudu'),
              ),
              const SizedBox(
                height: 25,
              ),
              const Text(
                "Eikö sinulla ole tiliä?",
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterPage()),
                  );
                },
                child: const Text('Rekisteröidy'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
