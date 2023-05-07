import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:serene_stays_app/screens/home_page.dart';

import '../utils/auth.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<StatefulWidget> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String errorText = "";

  void login(String email, username, password) async {
    setState(() {
      errorText = '';
    });
    try {
      Response response = await post(
          Uri.parse('http://127.0.0.1:8000/api/user/register'),
          body: {'email': email, 'password': password, 'username': username});

      if (response.statusCode == 201) {
        Response response = await post(
            Uri.parse('http://127.0.0.1:8000/api/user/login'),
            body: {'email': email, 'password': password}
        );
        var data = jsonDecode(response.body.toString());
        var token = data['jwt'];
        await storage.write(key: 'jwt', value: token);
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
                controller: usernameController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  hintText: 'Käyttäjänimi',
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
                  login(
                      emailController.text.toString(),
                      usernameController.text.toString(),
                      passwordController.text.toString());
                },
                child: const Text('Rekisteröidy'),
              ),
              const SizedBox(
                height: 25,
              ),
              const Text(
                "Onko sinulla jo tili?",
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                child: const Text('Kirjaudu sisään'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
