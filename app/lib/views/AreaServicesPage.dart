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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<Service> _services = [];
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

      _services.clear();

      for (var c in responseData['data']) {
        Service service = Service(
          name: c['name'],
          price: double.parse(c['service_price']),
          description: c['description'],
        );
        _services.add(service);
      }
      return ResponseData(responseData['result'], _services);
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

  void _onServiceDelete(Service service) {
    setState(() {
      widget.area.services.remove(service);
    });
  }

  void _showAddServiceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Lisää'),
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
              onPressed: () {
                if (_serviceNameController.text.isEmpty ||
                    _servicePriceController.text.isEmpty ||
                    _serviceDescriptionController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Täytä kaikki kentät!'),
                    duration: Duration(seconds: 2),
                  ));
                  return;
                }
                setState(() {
                  widget.area.services.add(
                    Service(
                      name: _serviceNameController.text,
                      price: double.parse(_servicePriceController.text),
                      description: _serviceDescriptionController.text,
                    ),
                  );

                  _serviceNameController.clear();
                  _servicePriceController.clear();
                  _serviceDescriptionController.clear();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _onServiceEdit() {
    _serviceNameController.text = _selectedService!.name;
    _servicePriceController.text = _selectedService!.price.toString();
    _serviceDescriptionController.text = _selectedService!.description;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Muokkaa'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _serviceNameController,
                  decoration: const InputDecoration(labelText: 'Nimi'),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Syötä nimi!';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _servicePriceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Hinta'),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Syötä hinta!';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Hinta on numero! Syötä hinta!';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _serviceDescriptionController,
                  decoration: const InputDecoration(labelText: 'Kuvaus'),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Syötä kuvaus!';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Peruuta'),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    _selectedService!.name = _serviceNameController.text;
                    _selectedService!.price =
                        double.parse(_servicePriceController.text);
                    _selectedService!.description =
                        _serviceDescriptionController.text;
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Tallenna'),
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
                    subtitle: Text('Hinta: ${data.data![i].price}'),
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
                              _onServiceEdit();
                            },
                            icon: const Icon(Icons.edit),
                          ),
                          IconButton(
                            onPressed: () {
                              _onServiceDelete(data.data![i]);
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
