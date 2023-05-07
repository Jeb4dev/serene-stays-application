import 'package:flutter/material.dart';
import '../data/Data.dart';

class AreaServicesPage extends StatefulWidget {
  final Area area;

  const AreaServicesPage({Key? key, required this.area}) : super(key: key);

  @override
  _AreaServicesPageState createState() => _AreaServicesPageState();
}

class _AreaServicesPageState extends State<AreaServicesPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<Service> _selectedServices = [];
  Service? _selectedService;
  final TextEditingController _serviceNameController = TextEditingController();
  final TextEditingController _servicePriceController = TextEditingController();
  final TextEditingController _serviceDescriptionController =
      TextEditingController();

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
      appBar: AppBar(
        title: Text(widget.area.name),
      ),
      body: ListView.builder(
        itemCount: widget.area.services.length,
        itemBuilder: (BuildContext context, int index) {
          final Service service = widget.area.services[index];

          return ListTile(
            title: Text(service.name),
            subtitle: Text(
                'Hinta: ${service.price} - ' 'Kuvaus: ${service.description}'),
            onTap: () {
              _onServiceTap(service);
            },
            trailing: Visibility(
              visible: _selectedService == service,
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
                      _onServiceDelete(service);
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
          _showAddServiceDialog();
        },
      ),
    );
  }
}
