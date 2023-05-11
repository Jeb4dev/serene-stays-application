import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

import '../data/Data.dart';
import '../utils/auth.dart';
import 'AreaCabinPage.dart';
import 'AreaServicesPage.dart';

class ResponseData {
  final String message;
  final List<Object>? data;

  ResponseData(this.message, this.data);
}

class AreaManagementPage extends StatefulWidget {
  @override
  _AreaManagementPageState createState() => _AreaManagementPageState();
}

class _AreaManagementPageState extends State<AreaManagementPage> {
  int _selectedIndex = -1;
  final List<Area> _areas = [];

  final _areaNameController = TextEditingController();

  Future<ResponseData> getAreaData() async {
    try {
      var token = await storage.read(key: 'jwt');
      var response = await get(
        Uri.parse('http://127.0.0.1:8000/api/area/'),
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

      _areas.clear();

      for (var alue in responseData['data']) {
        Area area = Area(
          name: alue['area'],
          items: [],
          services: [],
        );
        _areas.add(area);
      }

      return ResponseData(responseData['result'], _areas);
    }
    catch (e) {
      return ResponseData('error', []);
    }
  }

  void _renameArea(String newName) {
    setState(() {
      _areas[_selectedIndex].name = newName;
    });
  }

  Future<ResponseData> editArea(String name) async {
    try {
      var token = await storage.read(key: 'jwt');
      var response = await put(
        Uri.parse('http://127.0.0.1:8000/api/area/update?area=$name'),
        body: jsonEncode({
          'name': name,
        }),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
      );
      var data = json.decode(response.body);
      if (data['status'] == 'success') {
        Area area = Area(name: name, items: [], services: []);
        setState(() {
          _areas.removeWhere((element) => element.name == name);
          _areas.add(area);
        });
        return ResponseData(data['result'].toString(), [area]);
      }
      return ResponseData(data['message'].toString(),
          [Area(name: "null", items: [], services: [])]);
    } catch (e) {
      return ResponseData(
          e.toString(), [Area(name: "null", items: [], services: [])]);
    }
  }
  
  void _showUpdateArea(String name) {
    _areaNameController.text = name;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Päivitä alueen nimi'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: _areaNameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Uusi nimi',
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
                _areaNameController.clear();

                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('PÄIVITÄ'),
              onPressed: () async {
                var response = await editArea(
                    _areaNameController.text,
                );
                setState(() {});
                if (response.message == "null") {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Alueen nimi päivitetty onnistuneesti!"),
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

  Future<ResponseData> deleteArea(String name) async {
    var token = await storage.read(key: 'jwt');
    var response = await delete(
      Uri.parse('http://127.0.0.1:8000/api/area/delete?area=$name'),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );
    var data = json.decode(response.body);
    if (data['result'] == 'success') {
      setState(() {
        _areas.removeWhere((element) => element.name == name);
      });
    }

    return ResponseData(data['data'].toString(), null);
  }

  void _showDeleteDialog(String name) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Poista alue'),
          content: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 14.0,
                color: Colors.black,
              ),
              children: <TextSpan>[
                const TextSpan(text: 'Haluatko varmasti poistaa alueen?'),
                TextSpan(
                    text: name,
                    style: const TextStyle(fontWeight: FontWeight.bold)
                ),
                const TextSpan(text: ' ?\nAlueen tiedot katoavat pysyvästi.'),

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
                var response = await deleteArea(name);
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

  void _showRenameDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Rename Area'),
          content: TextField(
            controller: _areaNameController,
            decoration: const InputDecoration(hintText: 'Uusi nimi'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Peruuta'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Tallenna'),
              onPressed: () {
                _renameArea(_areaNameController.text);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddAreaDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Lisää uusi alue'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: _areaNameController,
                  decoration: const InputDecoration(hintText: 'Nimi'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Peruuta'),
              onPressed: () {
                _areaNameController.clear();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Lisää'),
              onPressed: () async {
                if (_areaNameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Syötä nimi!'),
                    duration: Duration(seconds: 2),
                  ));
                  return;
                }
                else {
                  try {
                    var token = await storage.read(key: 'jwt');
                    var response = await post(
                      Uri.parse('http://127.0.0.1:8000/api/area/create'),
                      body: jsonEncode({
                        'area': _areaNameController.text,
                      }),
                      headers: {
                        "Content-Type": "application/json",
                        "Accept": "application/json",
                        HttpHeaders.authorizationHeader: 'Bearer $token',
                      },
                    );
                    var data = json.decode(response.body);
                    if (data['result'] == 'success') {
                      Area area = Area(
                        name: _areaNameController.text,
                        items: [],
                        services: [],
                      );
                      setState(() {
                        _areas.add(area);
                      });
                    } else {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(
                        content: Text('Alueen lisääminen epäonnistui! ' + data['message']),
                        duration: const Duration(seconds: 6),
                      ));
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          'Alueen lisääminen epäonnistui! ' + e.toString()),
                      duration: const Duration(seconds: 6),
                    ));
                  }

                  _areaNameController.clear();
                }
                Navigator.of(context).pop();
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
              List<Widget> userWidgets = [];
              if (data.data!.isEmpty) {
                userWidgets.add(
                  Center(
                    child: Column(children: [
                      const SizedBox(height: 10),
                      Text(
                        "Alueita ei löytynyt!\n error: ${data.message}",
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
                body: Column(
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                      "Alueet",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _areas.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(_areas[index].name),
                            selected: _selectedIndex == index,
                            onTap: () {
                              // setState(() {
                              //   _selectedIndex = index;
                              // });
                            },
                            trailing: true == true
                                ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AreaItemsPage(area: _areas[index]),
                                      ),
                                    );
                                  },
                                  child: const Text('Mökit'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AreaServicesPage(area: _areas[index]),
                                      ),
                                    );
                                  },
                                  child: const Text('Palvelut'),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: () {
                                    _showUpdateArea(_areas[index].name);
                                  },
                                  icon: const Icon(Icons.edit),
                                ),
                                IconButton(
                                  onPressed: () {
                                    _showDeleteDialog(_areas[index].name);
                                  },
                                  icon: const Icon(Icons.delete),
                                ),
                              ],
                            )
                                : null,
                          );
                        },
                      ),
                    ),
                  ],
                ),
                floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    _showAddAreaDialog();
                  },
                  tooltip: 'Lisää uusi alue',
                  child: const Icon(Icons.add),
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
                      const Text("Alueiden haku epäonnistui!"),
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