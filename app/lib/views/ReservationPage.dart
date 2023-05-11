import 'package:flutter/material.dart';

class ReservationPage extends StatefulWidget {
  const ReservationPage({Key? key}) : super(key: key);

  @override
  _ReservationPageState createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  int _selectedIndex = -1;
  final List<String> _reservationStatus = [
    'Kaikki varaukset',
    'Hyväksytyt',
    'Hyväksymättömät',
    'Peruutetut'
  ];

  final TextEditingController _cottageController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();

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
                TextField(
                  controller: _cottageController,
                  decoration: const InputDecoration(hintText: 'Mökki'),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _areaController,
                  decoration: const InputDecoration(hintText: 'Alueet'),
                ),
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
                if (_cottageController.text.isEmpty ||
                    _areaController.text.isEmpty) {
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
