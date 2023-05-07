import 'package:flutter/material.dart';
import 'Data/Data.dart';

class AreaItemsPage extends StatefulWidget {
  final Area area;

  const AreaItemsPage({Key? key, required this.area}) : super(key: key);

  @override
  _AreaItemsPageState createState() => _AreaItemsPageState();
}

class _AreaItemsPageState extends State<AreaItemsPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<Item> _selectedItems = [];
  Item? _selectedItem;
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemPriceController = TextEditingController();
  final TextEditingController _itemDescriptionController =
      TextEditingController();
  final TextEditingController _itemAddressController = TextEditingController();

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
      appBar: AppBar(
        title: Text(widget.area.name),
      ),
      body: ListView.builder(
        itemCount: widget.area.items.length,
        itemBuilder: (BuildContext context, int index) {
          final Item item = widget.area.items[index];

          return ListTile(
            title: Text(item.name),
            subtitle: Text('Hinta: ${item.price}'),
            onTap: () {
              _onItemTap(item);
            },
            trailing: Visibility(
              visible: _selectedItem == item,
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
                      _onItemDelete(item);
                    },
                    icon: const Icon(Icons.delete),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          _showAddItemDialog();
        },
      ),
    );
  }
}
