import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import '../data/Data.dart';
import '../utils/auth.dart';

class ResponseData {
  final String message;
  final List<Item>? data;

  ResponseData(this.message, this.data);
}

class AreaItemsPage extends StatefulWidget {
  final Area area;

  const AreaItemsPage({Key? key, required this.area}) : super(key: key);

  @override
  _AreaItemsPageState createState() => _AreaItemsPageState();
}

class _AreaItemsPageState extends State<AreaItemsPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<Item> _cabins = [];
  Item? _selectedItem;
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemPriceController = TextEditingController();
  final TextEditingController _itemDescriptionController = TextEditingController();
  final TextEditingController _itemAddressController = TextEditingController();

  Future<ResponseData> getAreaData() async {
    try {
      var token = await storage.read(key: 'jwt');
      var response = await get(
        Uri.parse('http://127.0.0.1:8000/api/area/cabins?area=${widget.area.name}'),
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

      _cabins.clear();

      for (var c in responseData['data']) {
        Item cabin = Item(
          name: c['name'],
          price: double.parse(c['price_per_night']),
          description: c['description'],
          address: c['address'],
        );
        _cabins.add(cabin);
      }

      return ResponseData(responseData['result'], _cabins);
  }
    catch (e) {
      return ResponseData('error', []);
    }
  }

  void _onItemTap(Item item) {
    setState(() {
      _selectedItem = item;
    });
  }

  void _onItemDelete(Item item) {
    setState(() {
      widget.area.items.remove(item);
    });
  }

  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Lisää'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: _itemNameController,
                  decoration: const InputDecoration(hintText: 'Nimi'),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _itemPriceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'Hinta'),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _itemAddressController,
                  decoration: const InputDecoration(hintText: 'Osoite'),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _itemDescriptionController,
                  decoration: const InputDecoration(hintText: 'Kuvaus'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Peruuta'),
              onPressed: () {
                _itemNameController.clear();
                _itemPriceController.clear();
                _itemAddressController.clear();
                _itemDescriptionController.clear();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Lisää'),
              onPressed: () {
                if (_itemNameController.text.isEmpty ||
                    _itemPriceController.text.isEmpty ||
                    _itemAddressController.text.isEmpty ||
                    _itemDescriptionController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Täytä kaikki kentät!'),
                    duration: Duration(seconds: 2),
                  ));
                  return;
                }
                setState(() {
                  widget.area.items.add(
                    Item(
                      name: _itemNameController.text,
                      price: double.parse(_itemPriceController.text),
                      address: _itemAddressController.text,
                      description: _itemDescriptionController.text,
                    ),
                  );

                  _itemNameController.clear();
                  _itemPriceController.clear();
                  _itemAddressController.clear();
                  _itemDescriptionController.clear();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _onItemEdit() {
    _itemNameController.text = _selectedItem!.name;
    _itemPriceController.text = _selectedItem!.price.toString();
    _itemAddressController.text = _selectedItem!.address;
    _itemDescriptionController.text = _selectedItem!.description;

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
                  controller: _itemNameController,
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
                  controller: _itemPriceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Hinta'),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Syötä hinta!';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Hinta on numero!';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _itemAddressController,
                  decoration: const InputDecoration(labelText: 'Osoite'),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Syötä osoite!';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _itemDescriptionController,
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
                    _selectedItem!.name = _itemNameController.text;
                    _selectedItem!.price =
                        double.parse(_itemPriceController.text);
                    _selectedItem!.address = _itemAddressController.text;
                    _selectedItem!.description =
                        _itemDescriptionController.text;
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
                List<Widget> cabinWidgets = [];
                for (int i = 0; i < data.data!.length; i++) {
                  cabinWidgets.add(
                      ListTile(
                        title: Text(data.data![i].name),
                        subtitle: Text('Hinta: ${data.data![i].price}'),
                        onTap: () {
                          _onItemTap(data.data![i]);
                        },
                        trailing: Visibility(
                          visible: true,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  _onItemEdit();
                                },
                                icon: const Icon(Icons.edit),
                              ),
                              IconButton(
                                onPressed: () {
                                  _onItemDelete(data.data![i]);
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
                  cabinWidgets.add(
                    Center(
                      child: Column(children: [
                        const SizedBox(height: 10),
                        Text(
                          "Mökkejä ei löytynyt!\n error: ${data.message}",
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
                          "Mökit",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: ListView(
                            children: cabinWidgets,
                          ),
                        ),
                      ],
                    ),
                  ),


                  floatingActionButton: FloatingActionButton(
                    child: const Icon(Icons.add),
                    onPressed: () {
                      _showAddItemDialog();
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
                        const Text("Mökkien haku epäonnistui!"),
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
