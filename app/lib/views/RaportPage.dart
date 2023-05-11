import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

import '../data/Data.dart';
import '../data/User.dart';
import '../utils/auth.dart';

class ResponseData {
  final String? result;
  final String? message;
  final List<Reservation>? reservations;

  ResponseData(this.result, this.message, this.reservations);
}

class RaportPage extends StatefulWidget {
  @override
  _RaportPageState createState() => _RaportPageState();

  List<Reservation> reservations = [];
  List<Service> services = [];
  List<User> users = [];
  List<Cabin> cabins = [];
}

class _RaportPageState extends State<RaportPage> {
  @override
  void initState() {
    super.initState();
    _fetchReservations();
  }

  Future<void> _fetchReservations() async {
    // if areas are already fetched, don't fetch again
    if (widget.reservations.isNotEmpty) {
      return;
    }

    var token = await storage.read(key: 'jwt');
    var response = await get(
      Uri.parse('http://127.0.0.1:8000/api/reservation'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
      setState(() {
        for (var reservation in responseData['data']) {
          var _reservation = Reservation(
            cabin: reservation['cabin'],
            customer: reservation['customer'],
            owner: reservation['owner'],
            services: reservation['services'].cast<int>(),
            startDate: reservation['start_date'],
            endDate: reservation['end_date'],
            createdAt: reservation['created_at'],
            cancelledAt: reservation['canceled_at'],
            acceptedAt: reservation['accepted_at'],
            cost: reservation['price'],
          );
          widget.reservations.add(_reservation);
        }
      });
    } else {
      // Handle error
      print('Failed to fetch reservations: ${response.statusCode}');
    }

    // service data
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
        for (var services in responseData['data']) {
          var _services = Service(
            services['id'],
            services['name'],
            services['description'],
            double.parse(services['service_price']) as int,
            area: services['area'],
          );
          widget.services.add(_services);
        }
      });
    } else {
      // Handle error
      print('Failed to fetch reservations: ${response.statusCode}');
    }

    // users
    // service data
    response = await get(
      Uri.parse('http://127.0.0.1:8000/api/user'),
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
          User _user = User(u['username'], u['email'], u['first_name'],
              u['last_name'], u['address'], u['phone'], u['zip'],
              id: u['id']);
          widget.users.add(_user);
        }
      });
    } else {
      // Handle error
      print('Failed to fetch reservations: ${response.statusCode}');
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
            id: cabin['id'],
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Raportti'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            child: Column(
              // write overview of the data
              children: [
                Text('Datasta näkemyksiä', style: TextStyle(fontSize: 24)),
                SizedBox(height: 20),
                Text('Varausten määrä: ${widget.reservations.length}',
                    style: TextStyle(fontSize: 18)),
                SizedBox(height: 20),
                Text('Palveluiden määrä: ${widget.services.length}',
                    style: TextStyle(fontSize: 18)),
                SizedBox(height: 20),
                Text('Asiakkaiden määrä: ${widget.users.length}',
                    style: TextStyle(fontSize: 18)),
                SizedBox(height: 20),
                Text('Mökkien määrä: ${widget.cabins.length}',
                    style: TextStyle(fontSize: 18)),
                SizedBox(height: 40),
                Text('KAIKKI TULOT:', style: TextStyle(fontSize: 24)),
                SizedBox(height: 20),
                // calculate total income
                Text(
                    'Varauksen keskimääräinen tuotto: ${widget.reservations.fold(0, (previousValue, element) => (previousValue + element.cost! / widget.reservations.length).toInt())} €',
                    style: TextStyle(fontSize: 18)),
                SizedBox(height: 20),
// calculate income per cabin
                SizedBox(height: 20),
                Text(
                    'Mökkien tuotto: ${widget.reservations.fold(0, (previousValue, element) => (previousValue + element.cost!).toInt())} €',
                    style: TextStyle(fontSize: 18)),
                SizedBox(height: 20),
                // calculate income per cabin
                ...widget.cabins.map((cabin) {
                  var income = widget.reservations
                      .where((reservation) => reservation.cabin == cabin.id)
                      .fold(
                          0,
                          (previousValue, element) =>
                              (previousValue + element.cost!).toInt());
                  return Text('${cabin.name}: $income €',
                      style: TextStyle(fontSize: 18));
                }),
                SizedBox(height: 20),
                Text(
                    'Palveluiden tuotto yhteensä: ${widget.services.fold(0, (previousValue, element) => (previousValue + element.servicePrice).toInt())} €',
                    style: TextStyle(fontSize: 18)),
                Text(
                    'Keskimääräinen tuotto per palvelu: ${widget.services.length > 0 ? (widget.services.fold(0, (previousValue, element) => (previousValue + element.servicePrice / widget.services.length).toInt())) : 0} €',
                    style: TextStyle(fontSize: 21)),
                SizedBox(height: 20),
                // calculate income per service
                ...widget.services.map((service) {
                  var income = widget.reservations
                      .where((reservation) =>
                          reservation.services.contains(service.id))
                      .fold(
                          0,
                          (previousValue, element) =>
                              (previousValue + element.cost!).toInt());
                  return Text('${service.name}: $income €',
                      style: TextStyle(fontSize: 18));
                }),
                SizedBox(height: 20),
                Text(
                    'Keskimääräinen tuotto per asiakas: ${widget.users.length > 0 ? (widget.reservations.fold(0, (previousValue, element) => (previousValue + element.cost! / widget.users.length).toInt())) : 0} €',
                    style: TextStyle(fontSize: 21)),
                SizedBox(height: 20),
                // calculate income per customer
                ...widget.users.map((user) {
                  var income = widget.reservations
                      .where((reservation) => reservation.customer == user.id)
                      .fold(
                          0,
                          (previousValue, element) =>
                              (previousValue + element.cost!).toInt());
                  return Text('${user.username}: $income €',
                      style: TextStyle(fontSize: 18));
                }),

              ],
            ),
          ),
        ],
      ),
    );
  }
}
