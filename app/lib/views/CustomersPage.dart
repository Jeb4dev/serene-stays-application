import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

import '../data/User.dart';
import '../utils/auth.dart';

class ResponseData {
  final String message;
  final List<User>? user;

  ResponseData(this.message, this.user);
}

class CustomersPage extends StatefulWidget {
  @override
  _CustomersPageState createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _zipController = TextEditingController();
  List<User> users = [];

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

    for (var u in responseData['data']) {
      User user = User(u['username'], u['email'], u['first_name'],
          u['last_name'], u['address'], u['phone'], u['zip']);
      users.add(user);
    }

    return ResponseData(responseData['result'], users);
  }

  Future<ResponseData> addUser(String username, first_name, last_name, email,
      address, phone, zip, password) async {
    try {
      var token = await storage.read(key: 'jwt');
      var response = await post(
        Uri.parse('http://127.0.0.1:8000/api/user/register'),
        body: jsonEncode({
          'username': username,
          'first_name': first_name,
          'last_name': last_name,
          'email': email,
          'address': address,
          'phone': phone,
          'zip': zip,
          'password': password,
        }),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
      );
      var data = json.decode(response.body);
      if (data['status'] == 'success') {
        User user = User(
            data['data']['username'],
            data['data']['email'],
            data['data']['first_name'],
            data['data']['last_name'],
            data['data']['address'],
            data['data']['phone'],
            data['data']['zip']);
        users.add(user);
        return ResponseData(data['result'].toString(), [user]);
      }
      return ResponseData(data['message'].toString(),
          [User("null", "null", null, null, null, null, null)]);
    } catch (e) {
      return ResponseData(
          e.toString(), [User("null", "null", null, null, null, null, null)]);
    }
  }

  Future<ResponseData> deleteUser(String username) async {
    return ResponseData("Not implemented", null);
  }

  Future<ResponseData> editUser(String username) async {
    return ResponseData("Not implemented", null);
  }

  Future<ResponseData> getInvoices(String username) async {
    return ResponseData("Not implemented", null);
  }

  Future<ResponseData> getReservations(String username) async {
    return ResponseData("Not implemented", null);
  }

  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Lisää uusi asiakas'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Käyttäjätunnus',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Sähköposti',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Salasana',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Etunimi',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Sukunimi',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Osoite',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Puhelinnumero',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _zipController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Postinumero',
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Peruuta'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Lisää'),
              onPressed: () async {
                var response = await addUser(
                    _usernameController.text,
                    _firstNameController.text,
                    _lastNameController.text,
                    _emailController.text,
                    _addressController.text,
                    _phoneController.text,
                    _zipController.text,
                    _passwordController.text);
                if (response.message == "null") {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Käyttäjä lisätty onnistuneesti!"),
                    duration: Duration(seconds: 4),
                    backgroundColor: Colors.green,
                  ));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(response.message),
                      duration: Duration(seconds: 4),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
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
              List<Widget> userWidgets = [];
              for (var u in data.user!) {
                userWidgets.add(Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        // Replace this with the user's profile picture
                                        backgroundImage: NetworkImage(
                                            'https://picsum.photos/200'),
                                      ),
                                      const SizedBox(width: 16),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${u.first_name} ${u.last_name}',
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(u.email),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () async {
                                          // Handle edit button press
                                          var response = await editUser(u.username);
                                          if (response.message == "null") {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                              content: Text(
                                                  "Käyttäjän tiedot päivitetty onnistuneesti!"),
                                              duration: Duration(seconds: 4),
                                              backgroundColor: Colors.green,
                                            ));
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(response.message),
                                                duration: Duration(seconds: 4),
                                              ),
                                            );
                                          }
                                        },
                                        icon: Icon(Icons.edit),
                                      ),
                                      IconButton(
                                        onPressed: () async {
                                          // Handle delete button press
                                          var response = await deleteUser(u.username);
                                          if (response.message == "null") {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                              content: Text(
                                                  "Käyttäjä poistettu onnistuneesti!"),
                                              duration: Duration(seconds: 4),
                                              backgroundColor: Colors.green,
                                            ));
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(response.message),
                                                duration: Duration(seconds: 4),
                                              ),
                                            );
                                          }
                                        },
                                        icon: Icon(Icons.delete),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Divider(),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Icon(Icons.account_circle),
                                  const SizedBox(width: 8),
                                  Text('Username'),
                                  const SizedBox(width: 16),
                                  Text(u.username),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.home),
                                      const SizedBox(width: 8),
                                      Text('Address'),
                                      const SizedBox(width: 16),
                                      Text(u.address.toString()),
                                    ],
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      // Handle invoices button press
                                      var response = await getInvoices(u.username);
                                      if (response.message == "null") {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                          content: Text(
                                              "Käyttäjä poistettu onnistuneesti!"),
                                          duration: Duration(seconds: 4),
                                          backgroundColor: Colors.green,
                                        ));
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(response.message),
                                            duration: Duration(seconds: 4),
                                          ),
                                        );
                                      }
                                    },
                                    child: const Text('INVOICES'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.phone),
                                      const SizedBox(width: 8),
                                      Text('Phone'),
                                      const SizedBox(width: 16),
                                      Text(u.phone.toString()),
                                    ],
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      // Handle invoices button press
                                      var response = await getReservations(u.username);
                                      if (response.message == "null") {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                          content: Text(
                                              "Käyttäjä poistettu onnistuneesti!"),
                                          duration: Duration(seconds: 4),
                                          backgroundColor: Colors.green,
                                        ));
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(response.message),
                                            duration: Duration(seconds: 4),
                                          ),
                                        );
                                      }
                                    },
                                    child: const Text('RESERVATIONS'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ));
              }
              // display data here
              return Scaffold(
                body: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      const Text(
                        "Asiakkaat",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView(
                          children: userWidgets,
                        ),
                      ),
                    ],
                  ),
                ),
                floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    _showAddUserDialog();
                  },
                  tooltip: 'Lisää uusi asiakas',
                  child: const Icon(Icons.add),
                ),
              );
            } else if (snapshot.hasError) {
              // handle error here
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(snapshot.error.toString()),
                  duration: Duration(seconds: 10),
                ),
              );

              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text("Asiakkaiden haku epäonnistui!"),
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
