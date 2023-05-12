import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';

import '../data/Data.dart';
import '../utils/auth.dart';
import 'dart:html' as html;
import 'package:pdf/widgets.dart' as pw;

class ResponseData {
  final String? result;
  final String? message;
  final List<Invoice>? invoices;

  ResponseData(this.result, this.message, this.invoices);
}

class InvoicePage extends StatefulWidget {
  @override
  _InvoicePageState createState() => _InvoicePageState();

  List<String> areas = [];
}

class _InvoicePageState extends State<InvoicePage> {
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
  }

  final _searchController = TextEditingController();
  String _selectedStatus = 'Kaikki';
  List<String> _selectedAreas = [];

  List<Invoice> invoices = [];

  Future<ResponseData> getInvoices() async {
    try {
      var token = await storage.read(key: 'jwt');
      var response = await get(
        Uri.parse('http://127.0.0.1:8000/api/reservation/invoice'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
      );

      var responseData = json.decode(response.body);

      if (responseData['result'] == 'error') {
        return ResponseData(
            responseData['result'], responseData['message'], null);
      }

      invoices.clear();

      for (var i in responseData['data']) {
        var reservation = i['reservation_id'];
        var customer = i['customer'];
        var price = i['total_price'];
        var cabin_area = i['reservation_cabin_area'].toString();

        var createdAt = i['created_at'];
        var paidAt = i['paid_at'];
        var cancelledAt = i['canceled_at'];
        var updatedAt = i['updated_at'];

        // filter by invoice status
        switch (_selectedStatus) {
          case 'Kaikki':
            break;
          case 'Maksetut':
            if (paidAt == null) {
              continue;
            }
            break;
          case 'Maksamattomat':
            if (paidAt != null) {
              continue;
            }
            break;
          case 'Peruutetut':
            if (cancelledAt == null) {
              continue;
            }
            break;
        }

        // filter by customer username
        if (_searchController.value.text.isNotEmpty) {
          if (!customer.toLowerCase().contains(_searchController.value.text.toLowerCase())) {
            continue;
          }
        }

        // filter by selected areas
        if (_selectedAreas.isNotEmpty) {
          if (!_selectedAreas.contains(cabin_area)) {
            continue;
          }
        }

        // add invoice
        invoices.add(Invoice(
          reservation: reservation,
          price: price,
          customer: customer,
          paidAt: (paidAt == null) ? null : DateTime.parse(paidAt),
          cancelledAt:
              (cancelledAt == null) ? null : DateTime.parse(cancelledAt),
          updatedAt: (updatedAt == null) ? null : DateTime.parse(updatedAt),
          createdAt: (createdAt == null) ? null : DateTime.parse(createdAt),
          pdf: i['pdf'],
        ));
      }

      return ResponseData(responseData['result'], null, invoices);
    } catch (e) {
      print("error $e");
      return ResponseData('error', e.toString(), null);
    }
  }

  void _searchCustomers(String search) {
    setState(() {});
  }

  void _payInvoice(Invoice invoice) async {
    var token = await storage.read(key: 'jwt');
    var response = await patch(
      Uri.parse('http://127.0.0.1:8000/api/reservation/invoice/update?invoice=${invoice.reservation}'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
      body : jsonEncode(<String, dynamic>{
        'paid_at': DateTime.now().toIso8601String(),
      }),
    );

    var responseData = json.decode(response.body);

    if (responseData['result'] == 'error') {
      print("error ${responseData['message']}");
    }
    setState(() {});
  }

  void _cancelInvoice(Invoice invoice) async {
    var token = await storage.read(key: 'jwt');
    var response = await patch(
      Uri.parse('http://127.0.0.1:8000/api/reservation/invoice/update?invoice=${invoice.reservation}'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
      body : jsonEncode(<String, dynamic>{
        'canceled_at': DateTime.now().toIso8601String(),
      }),
    );

    var responseData = json.decode(response.body);

    if (responseData['result'] == 'error') {
      print("error ${responseData['message']}");
    }
    setState(() {});
  }

  Future<void> showInvoice(Invoice invoice) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(
          child: pw.Column(
            children: [
              pw.Text('Lasku'),
              pw.Text(invoice.pdf.toString())
            ],
          ),
        ),
      ),
    );

    final blob = html.Blob([await pdf.save()], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.window.open(url, '_blank');
    html.Url.revokeObjectUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Etsi laskuja asiakkaan käyttäjänimellä...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () =>
                            {_searchController.clear(), setState(() {})},
                      ),
                      border: InputBorder.none,
                    ),
                    onChanged: _searchCustomers,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Tooltip(
                message: 'Valitse laskun tila',
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedStatus,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedStatus = newValue!;
                      });
                    },
                    items: <String>[
                      'Kaikki',
                      'Maksetut',
                      'Maksamattomat',
                      'Peruutetut'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    underline: Container(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(30),
                ),
                child: PopupMenuButton<String>(
                  tooltip: "Valitse alue",
                  onSelected: (String value) {
                    setState(() {
                      if (_selectedAreas.contains(value)) {
                        _selectedAreas.remove(value);
                      } else {
                        _selectedAreas.add(value);
                      }
                    });
                  },
                  itemBuilder: (BuildContext context) {
                    return widget.areas
                        .map((String value) => CheckedPopupMenuItem<String>(
                              value: value,
                              checked: _selectedAreas.contains(value),
                              child: Text(value),
                            ))
                        .toList();
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.area_chart, color: Colors.grey[700]),
                      const SizedBox(width: 5),
                      Icon(Icons.arrow_drop_down, color: Colors.grey[700])
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: FutureBuilder<ResponseData>(
        future: getInvoices(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              ResponseData data = snapshot.data!;
              List<Widget> invoiceWidgets = [];
              if (data.invoices != null) {
                for (var invoice in data.invoices!) {
                  invoiceWidgets.add(
                    Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "Lasku varaukselle #${invoice.reservation}    -    ${invoice.price}€ ",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                "Luotu: ${invoice.createdAt != null ? DateFormat('d.M.yyyy kk:mm').format(invoice.createdAt!) : "Ei"}",
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Text(
                                "Asiakas: ${invoice.customer}",
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.grey,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                "Päivitetty: ${invoice.updatedAt != null ? DateFormat('d.M.yyyy kk:mm').format(invoice.updatedAt!) : "Ei"}",
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              // if not paid show button if paid show text
                              if (invoice.cancelledAt == null && invoice.paidAt == null)
                                TextButton(
                                  onPressed: () => _payInvoice(invoice),
                                  child: const Text("Merkitse maksetuksi"),
                                )
                              else
                                Text(
                                  invoice.paidAt != null ? "Maksettu: ${DateFormat('d.M.yyyy kk:mm').format(invoice.paidAt!)}" : "Maksettu -",
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.grey,
                                  ),
                                ),
                              const Spacer(),
                              if (invoice.cancelledAt == null && invoice.paidAt == null)
                                TextButton(
                                  onPressed: () => _cancelInvoice(invoice),
                                  child: const Text("Merkitse peruutetuksi"),
                                )
                              else
                                Text(
                                  invoice.cancelledAt != null ? ("Peruutettu: ${DateFormat('d.M.yyyy kk:mm').format(invoice.cancelledAt!)}") : "Peruutettu -",
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.grey,
                                  ),
                                ),
                            ],
                          ),
                          Row(
                            children: [
                              TextButton(
                                onPressed: () => {
                                  showInvoice(invoice),
                                },
                                child: const Text("Näytä paperilasku"),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: () => {
                                  showInvoice(invoice),
                                },
                                child: const Text("Lähetä e-lasku"),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }
                if (invoiceWidgets.isEmpty) {
                  invoiceWidgets.add(
                    Center(
                      child: Column(children: const [
                        SizedBox(height: 10),
                        Icon(
                          Icons.error_outline,
                          size: 50,
                          color: Colors.red,
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Laskuja ei löytynyt annetuilla hakuehdoilla",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ]),
                    ),
                  );
                }
              } else {
                invoiceWidgets.add(
                  Center(
                    child: Column(children: [
                      const SizedBox(height: 10),
                      const Icon(
                        Icons.error_outline,
                        size: 50,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Laskuja ei löytynyt",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Virhekoodi kehittäjälle: ${data.message}",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                          color: Colors.grey,
                        ),
                      ),
                    ]),
                  ),
                );
              }

              // display data here
              return Scaffold(
                body: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      const Text(
                        "Laskutusjärjestelmä",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView(
                          children: invoiceWidgets,
                        ),
                      ),
                    ],
                  ),
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
                      const Text("Laskujen haku epäonnistui!"),
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
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
