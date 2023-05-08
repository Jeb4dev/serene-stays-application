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
  final List<Area> _areas = areas;

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

  void _deleteArea() {
    setState(() {
      _areas.removeAt(_selectedIndex);
      _selectedIndex = -1;
    });
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Poista alue'),
          content: const Text('Oletko varma? Kaikki alueen tiedot poistetaan.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Peruuta'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('POISTA'),
              onPressed: () {
                _deleteArea();
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
                                    _showRenameDialog();
                                  },
                                  icon: const Icon(Icons.edit),
                                ),
                                IconButton(
                                  onPressed: () {
                                    _showDeleteDialog();
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
