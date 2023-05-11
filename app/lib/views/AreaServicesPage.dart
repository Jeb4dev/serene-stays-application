import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import '../data/Data.dart';
import '../utils/auth.dart';

class ResponseData {
  final String message;
  final List<Service>? data;

  ResponseData(this.message, this.data);
}

class AreaServicesPage extends StatefulWidget {
  final Area area;

  const AreaServicesPage({Key? key, required this.area}) : super(key: key);

  @override
  _AreaServicesPageState createState() => _AreaServicesPageState();
}

class _AreaServicesPageState extends State<AreaServicesPage> {
  List<Service> services = [];
  Service? _selectedService;
  final TextEditingController _serviceNameController = TextEditingController();
  final TextEditingController _servicePriceController = TextEditingController();
  final TextEditingController _serviceDescriptionController =
      TextEditingController();

  Future<ResponseData> getAreaData() async {
    try {
      var token = await storage.read(key: 'jwt');
      var response = await get(
        Uri.parse('http://127.0.0.1:8000/api/area/services/get?area=${widget.area.name}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
      );
      var responseData = json.decode(response.body);

      if (responseData['result'] == 'error') {
        return ResponseData(responseData['message'], []);
      }

      services.clear();

      for (var c in responseData['data']) {
        Service service = Service(c['id'], c['name'], c['description'], c['service_price']);
        services.add(service);
      }
      return ResponseData(responseData['result'], services);
    }
    catch (e) {
      return ResponseData('error', []);
    }
  }

  void _onServiceTap(Service service) {
    setState(() {
      _selectedService = service;
    });
  }

  Future<ResponseData> addService(String name, description, servicePrice) async {
    try {
      var token = await storage.read(key: 'jwt');
      var response = await post(
        Uri.parse('http://127.0.0.1:8000/api/user/register'),
        body: jsonEncode({
          'name': name,
          'description': description,
          'service_price': servicePrice,
        }),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
      );
      var data = json.decode(response.body);
      if (data['status'] == 'success') {
        Service service = Service(
            data['data']['id'],
            data['data']['name'],
            data['data']['description'],
            data['data']['service_price'],
        );
        setState(() {
          services.add(service);
        });
        return ResponseData(data['result'].toString(), [service]);
      }
      return ResponseData(data['message'].toString(),
          [Service(0, "null", "null", "null" as int)]);
    } catch (e) {
      return ResponseData(
          e.toString(), [Service(0, "null", "null", "null" as int)]);
    }
  }

  Future<ResponseData> deleteService(String name) async {
    var token = await storage.read(key: 'jwt');
    var response = await delete(
      Uri.parse('http://127.0.0.1:8000/api/area/services/delete?service=$name'),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );
    var data = json.decode(response.body);
    if (data['result'] == 'success') {
      setState(() {
        services.removeWhere((element) => element.name == name);
      });
    }

    return ResponseData(data['data'].toString(), null);
  }

  Future<ResponseData> editService(String name, description, servicePrice) async {
    try {
      var token = await storage.read(key: 'jwt');
      var response = await put(
        Uri.parse('http://127.0.0.1:8000/api/area/services/update?service=$name'),
        body: jsonEncode({
          'name': name,
          'description': description,
          'service_price': servicePrice,
        }),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
      );
      var data = json.decode(response.body);
      if (data['status'] == 'success') {
        Service service = Service(
            data['data']['id'],
            data['data']['name'],
            data['data']['description'],
            data['data']['service_price'],);
        setState(() {
          services.removeWhere((element) => element.name == name);
          services.add(service);
        });
        return ResponseData(data['result'].toString(), [service]);
      }
      return ResponseData(data['message'].toString(),
          [Service(0, "null", "null", "null" as int)]);
    } catch (e) {
      return ResponseData(
          e.toString(), [Service(0, "null", "null", "null" as int)]);
    }
  }

  void _showAddServiceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Lisää palvelu'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: _serviceNameController,
                  decoration: const InputDecoration(hintText: 'Nimi'),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _servicePriceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'Hinta'),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _serviceDescriptionController,
                  decoration: const InputDecoration(hintText: 'Kuvaus'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Peruuta'),
              onPressed: () {
                _serviceNameController.clear();
                _servicePriceController.clear();
                _serviceDescriptionController.clear();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Lisää'),
              onPressed: () async {
                var response = await addService(
                    _serviceNameController.text,
                    _servicePriceController.text,
                    _serviceDescriptionController.text,);
                if (response.message == "null") {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Palvelu lisätty onnistuneesti!"),
                    duration: Duration(seconds: 4),
                    backgroundColor: Colors.green,
                  ));
                  setState(() {});
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

  void _showUpdateServiceDialog() {
    _serviceNameController.text = _selectedService!.name;
    _servicePriceController.text = _selectedService!.servicePrice.toString();
    _serviceDescriptionController.text = _selectedService!.description;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Päivitä asiakkaan tietoja'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: _serviceNameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Nimi',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _servicePriceController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Hinta',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _serviceDescriptionController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Kuvaus',
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('PERUUTA'),
              onPressed: () {
                // clear all fields
                _serviceNameController.clear();
                _servicePriceController.clear();
                _serviceDescriptionController.clear();

                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('PÄIVITÄ'),
              onPressed: () async {
                var response = await editService(
                    _serviceNameController.text,
                    _servicePriceController.text,
                    _serviceDescriptionController.text,
                );
                setState(() {});
                if (response.message == "null") {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Palvelu päivitetty onnistuneesti!"),
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

  void _showDeleteServiceDialog(String name) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Poista palvelu'),
          content: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 14.0,
                color: Colors.black,
              ),
              children: <TextSpan>[
                const TextSpan(text: 'Haluatko varmasti poistaa asiakkaan?'),
                TextSpan(
                    text: name,
                    style: const TextStyle(fontWeight: FontWeight.bold)
                ),
                const TextSpan(text: ' ?\nTiedot katoavat pysyvästi.'),

              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('PERUUTA'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('POISTA'),
              onPressed: () async {
                var response = await deleteService(name);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(response.message),
                  ),
                );
                setState(() {});
                Navigator.pop(context);
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
        future: getAreaData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              ResponseData data = snapshot.data!;
              List<Widget> serviceWidgets = [];
              for (int i = 0; i < data.data!.length; i++) {
                serviceWidgets.add(
                  ListTile(
                    title: Text(data.data![i].name),
                    subtitle: Text('Hinta: ${data.data![i].servicePrice}'),
                    onTap: () {
                      _onServiceTap(data.data![i]);
                    },
                    trailing: Visibility(
                      visible: true,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              _showUpdateServiceDialog();
                            },
                            icon: const Icon(Icons.edit),
                          ),
                          IconButton(
                            onPressed: () {
                              _showDeleteServiceDialog(data.data![i].name);
                            },
                            icon: const Icon(Icons.delete),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              if (data.data!.isEmpty) {
                serviceWidgets.add(
                  Center(
                    child: Column(children: [
                      const SizedBox(height: 10),
                      Text(
                        "Palveluja ei löytynyt!\n error: ${data.message}",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ]),
                  ),
                );
              }
              // display data here
              return Scaffold(
                appBar: AppBar(
                  title: Text(widget.area.name),
                ),
                body: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      const Text(
                        "Palvelut",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView(
                          children: serviceWidgets,
                        ),
                      ),
                    ],
                  ),
                ),


                floatingActionButton: FloatingActionButton(
                  child: const Icon(Icons.add),
                  onPressed: () {
                    _showAddServiceDialog();
                  },
                ),
              );
            } else if (snapshot.hasError) {
              // handle error here
              String error = snapshot.error.toString();

              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Palveluiden haku epäonnistui!"),
                      const SizedBox(height: 10),
                      const Text(
                          "Tarkista internet-yhteys ja yritä uudelleen!"),
                      const SizedBox(height: 200),
                      const Text("Virheilmoitus kehittäjälle:"),
                      const SizedBox(height: 10),
                      Text(error),
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
