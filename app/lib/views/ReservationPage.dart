import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';

import '../data/Data.dart';
import '../data/User.dart';
import '../utils/auth.dart';

class ResponseData {
  final String? result;
  final String? message;
  final List<Invoice>? invoices;

  ResponseData(this.result, this.message, this.invoices);
}

class ReservationPage extends StatefulWidget {

  @override
  _ReservationPageState createState() => _ReservationPageState();

  List<String> areas = [];
  List<Cabin> cabins = [];
  List<User> users = [];
  List<Service> services = [];
}

class _ReservationPageState extends State<ReservationPage> {
  @override
  void initState() {
    super.initState();
    _fetchAreas();
  }

  Future<void> _fetchAreas() async {
    // if areas are already fetched, don't fetch again
    if (widget.areas.isNotEmpty) {
      return;
    }

    var token = await storage.read(key: 'jwt');
    var response = await get(
      Uri.parse('http://127.0.0.1:8000/api/area/'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
      setState(() {
        for (var area in responseData['data']) {
          widget.areas.add(area['area'].toString());
        }
      });
    } else {
      // Handle error
      print('Failed to fetch areas: ${response.statusCode}');
    }

    // fetch cabins
    response = await get(
      Uri.parse('http://127.0.0.1:8000/api/area/cabins'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
      setState(() {
        for (var cabin in responseData['data']) {
          Cabin _cabin = Cabin(
            name: cabin['name'],
            area: cabin['area'],
            address: cabin['address'],
            price: double.parse(cabin['price_per_night'].toString()),
            description: cabin['description'],
            numberOfBeds: cabin['num_of_beds'],
          );
          widget.cabins.add(_cabin);
        }
      });
    } else {
      // Handle error
      print('Failed to fetch cabins: ${response.statusCode}');
    }

    // fetch services
    response = await get(
      Uri.parse('http://127.0.0.1:8000/api/service/get'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
      setState(() {
        for (var service in responseData['data']) {
          Service _service = Service(
            service['name'],
            service['description'],
            double.parse(service['service_price'].toString()) as int,
          );
          widget.services.add(_service);
        }
      });
    } else {
      // Handle error
      print('Failed to fetch services: ${response.statusCode}');
    }

    // fetch users
    response = await get(
      Uri.parse('http://127.0.0.1:8000/api/user/'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
      setState(() {
        for (var u in responseData['data']) {
          User _users = User(u['username'], u['email'], u['first_name'],
              u['last_name'], u['address'], u['phone'], u['zip']);
          widget.users.add(_users);
        }
      });
    } else {
      // Handle error
      print('Failed to fetch services: ${response.statusCode}');
    }
  }

  int _selectedIndex = -1;
  final List<String> _reservationStatus = [
    'Kaikki varaukset',
    'Hyväksytyt',
    'Hyväksymättömät',
    'Peruutetut'
  ];

  final TextEditingController _cottageController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  String? _selectedArea;
  User? _selectedUser;
  Cabin? _selectedCabin;
  TextEditingController _startDateController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();
  List<String> _selectedServices = [];


  void _openReservationPage(String reservationStatus) {
    Widget page;

    if (reservationStatus == 'Hyväksytyt') {
      page = ApprovedReservation();
    } else {
      page = ReservationStatusPages(
        reservationStatus: reservationStatus,
      );
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => page,
      ),
    );
  }

  void _showAddReservationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Lisää uusi varaus'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[

                Tooltip(
                  message: 'Valitse alue',
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedArea,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedArea = newValue;
                        });
                      },
                      items: [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text("Valitse alue"),
                        ),
                        ...widget.areas.map((String area) {
                          return DropdownMenuItem<String>(
                            value: area,
                            child: Text(area),
                          );
                        }).toList(),
                      ],
                      underline: Container(),
                      iconEnabledColor: Colors.black,
                      style: TextStyle(color: Colors.black),
                      isExpanded: true,
                      hint: Text(_selectedArea ?? "Valitse alue"),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // cabin
                Tooltip(
                  message: 'Valitse mökki',
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: DropdownButton<Cabin>(
                      value: _selectedCabin,
                      onChanged: (Cabin? newValue) {
                        setState(() {
                          _selectedCabin = newValue;
                        });
                      },
                      items: [
                        DropdownMenuItem<Cabin>(
                          value: _selectedCabin,
                          child: Text("Valitse mökki"),
                        ),
                        ...widget.cabins.map((Cabin cabin) {
                          return DropdownMenuItem<Cabin>(
                            value: cabin,
                            child: Text(cabin.name),
                          );
                        }).toList(),
                      ],
                      underline: Container(),
                      iconEnabledColor: Colors.black,
                      style: TextStyle(color: Colors.black),
                      isExpanded: true,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // customer
                Tooltip(
                  message: 'Valitse asiakas',
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: DropdownButton<User>(
                      value: _selectedUser,
                      onChanged: (User? newValue) {
                        setState(() {
                          _selectedUser = newValue;
                        });
                      },
                      items: [
                        const DropdownMenuItem<User>(
                          value: null,
                          child: Text("Valitse asiakas"),
                        ),
                        ...widget.users.map((User user) {
                          return DropdownMenuItem<User>(
                            value: user,
                            child: Text(user.username.toString()),
                          );
                        }).toList(),
                      ],
                      underline: Container(),
                      iconEnabledColor: Colors.black,
                      style: TextStyle(color: Colors.black),
                      isExpanded: true,
                      hint: Text(_selectedArea ?? "Valitse alue"),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                //fist day
                GestureDetector(
                  onTap: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2015, 8),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _startDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: _startDateController,
                      decoration: InputDecoration(
                        labelText: 'Ensimmäinen päivä',
                        hintText: 'Valitse varauksen alku päivä',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // last day
                GestureDetector(
                  onTap: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2015, 8),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _endDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: _endDateController,
                      decoration: InputDecoration(
                        labelText: 'Viimeinen päivä',
                        hintText: 'Valitse varauksen loppu päivä',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // services
                PopupMenuButton<Service>(
                  onSelected: (Service value) {
                    setState(() {
                      if (_selectedServices.contains(value)) {
                        _selectedServices.remove(value);
                      } else {
                        _selectedServices.add(value.name);
                      }
                    });
                  },
                  itemBuilder: (BuildContext context) {
                    return widget.services.map((Service value) {
                      return CheckedPopupMenuItem<Service>(
                        value: value,
                        checked: _selectedServices.contains(value),
                        child: Text(value.name),
                      );
                    }).toList();
                  },
                  child: Text('Valitse lisäpalvelut'),
                ),
                const SizedBox(height: 10),

              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Peruuta'),
              onPressed: () {
                _cottageController.clear();
                _areaController.clear();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Lisää'),
              onPressed: () {
                if (_selectedCabin == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Täytä kaikki kentät!'),
                    duration: Duration(seconds: 2),
                  ));
                  return;
                }
                // Implement the logic for adding a reservation
                _cottageController.clear();
                _areaController.clear();
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
      body: Column(
        children: [
          const SizedBox(height: 10),
          const Text(
            "Varaukset",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: _reservationStatus.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_reservationStatus[index]),
                  selected: _selectedIndex == index,
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  trailing: ElevatedButton(
                    onPressed: () {
                      _openReservationPage(_reservationStatus[index]);
                    },
                    child: const Text('AVAA'),
                  ),
                );
              },
            ),
          ),
        ],
      ),






      floatingActionButton: FloatingActionButton(
        onPressed: _showAddReservationDialog,
        tooltip: 'Lisää uusi varaus',
        child: const Icon(Icons.add),
      ),
    );
  }
}




class ReservationStatusPages extends StatelessWidget {
  final String reservationStatus;

  const ReservationStatusPages({Key? key, required this.reservationStatus})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(reservationStatus),
      ),
      body: Center(
        child: Text('Tämä on $reservationStatus -sivu'),
      ),
    );
  }
}

class ApprovedReservation extends StatefulWidget {
  const ApprovedReservation({Key? key}) : super(key: key);

  @override
  _ApprovedReservationState createState() => _ApprovedReservationState();
}

class _ApprovedReservationState extends State<ApprovedReservation> {
  // Add your list of approved reservations here with price, cottage and area information.
  final List<Map<String, dynamic>> _approvedReservations = [
    {
      'price': 100.0,
      'cottage': 'Mökki A',
      'area': 'Alue 1',
    },
    {
      'price': 150.0,
      'cottage': 'Mökki B',
      'area': 'Alue 2',
    },
  ];






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hyväksytyt varaukset'),
      ),
      body: ListView.builder(
        itemCount: _approvedReservations.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
                '${_approvedReservations[index]['cottage']} (${_approvedReservations[index]['area']})'),
            subtitle: Text('Hinta: ${_approvedReservations[index]['price']}'),
            onTap: () {
              // Perform any action when tapping on an approved reservation
            },
          );
        },
      ),
    );
  }
}
