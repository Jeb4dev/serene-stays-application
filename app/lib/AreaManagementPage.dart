import 'package:flutter/material.dart';

import 'Data/Data.dart';
import 'AreaItemsPage.dart';
import 'AreaServicesPage.dart';

class AreaManagementPage extends StatefulWidget {
  @override
  _AreaManagementPageState createState() => _AreaManagementPageState();
}

class _AreaManagementPageState extends State<AreaManagementPage> {
  int _selectedIndex = -1;
  final List<Area> _areas = areas;

  final _areaNameController = TextEditingController();

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
              onPressed: () {
                if (_areaNameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Syötä nimi!'),
                    duration: Duration(seconds: 2),
                  ));
                  return;
                }
                setState(
                      () {
                    _areas.add(
                      Area(
                        name: _areaNameController.text,
                        items: [],
                        services: [],
                      ),
                    );

                    _areaNameController.clear();
                  },
                );
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
      appBar: AppBar(
        title: const Text('Alueiden hallinta'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _areas.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_areas[index].name),
                  selected: _selectedIndex == index,
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  trailing: _selectedIndex == index
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
  }
}
