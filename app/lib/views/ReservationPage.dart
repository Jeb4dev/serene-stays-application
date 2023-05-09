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

  void _openReservationPage(String reservationStatus) {
    Widget page;

    if (reservationStatus == 'Hyväksytyt') {
      page = ApprovedReservation();
    } else {
      page = ReservationStatusPage(
        reservationStatus: reservationStatus,
      );
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => page,
      ),
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
        onPressed: () {
          // Implement add reservation action here
        },
        tooltip: 'Lisää uusi varaus',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ReservationStatusPage extends StatelessWidget {
  final String reservationStatus;

  const ReservationStatusPage({Key? key, required this.reservationStatus})
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
