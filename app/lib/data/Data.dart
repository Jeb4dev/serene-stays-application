import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';

import 'User.dart';

class Area {
  String name;
  List<Item> items;
  List<Service> services;

  Area({required this.name, required this.items, required this.services});

  static Area fromJson(area) {
    if (area.containsKey('area')) {
      return Area(
        name: area['area'],
        items: [],
        services: [],
      );
    } else {
      throw Exception('Invalid JSON data');
    }
  }
}


class Item {
  String name;
  double price;
  String description;
  String address;

  Item(
      {required this.name,
      required this.price,
      required this.description,
      required this.address});
}

class Service {
  String name;
  double price;
  String description;

  Service({
    required this.name,
    required this.price,
    required this.description,
  });
}

List<Area> areas = [
  Area(
    name: 'Ruka',
    items: [
      Item(name: 'Mökki 1', price: 2, description: 'Kuvaus 1', address: 'tie'),
      Item(name: 'Mökki 2', price: 1, description: 'Kuvaus 2', address: 'katu'),
      Item(name: 'Mökki 3', price: 1, description: 'Kuvaus 3', address: 'kuja'),
    ],
    services: [
      Service(name: 'Palvelu1', price: 10, description: 'description')
    ],
  ),
  Area(
    name: 'Luosto',
    items: [
      Item(name: 'Mökki 4', price: 1, description: 'Kuvaus 4', address: 'tie'),
      Item(name: 'Mökki 5', price: 1, description: 'Kuvaus 5', address: 'tie'),
      Item(name: 'Mökki 6', price: 2, description: 'Kuvaus 6', address: 'tie'),
    ],
    services: [
      Service(name: 'Palvelu1', price: 10, description: 'description')
    ],
  ),
  Area(
    name: 'Tahko',
    items: [
      Item(name: 'Mökki 7', price: 1, description: 'Kuvaus 7', address: 'tie'),
      Item(name: 'Mökki 8', price: 1, description: 'Kuvaus 8', address: 'tie'),
      Item(name: 'Mökki 9', price: 1, description: 'Kuvaus 9', address: 'tie'),
    ],
    services: [
      Service(name: 'Palvelu1', price: 10, description: 'description')
    ],
  ),
];


class Reservation {
  int cabin;
  int customer;
  int owner;
  List<int> services;
  String? startDate;
  String? endDate;
  String? createdAt;
  String? acceptedAt;
  String? cancelledAt;

  Reservation({
    required this.cabin,
    required this.customer,
    required this.owner,
    required this.services,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.acceptedAt,
    required this.cancelledAt,
  });
}


class Invoice {
  String reservation;
  double? price;
  String? customer;
  DateTime? createdAt;
  DateTime? paidAt;
  DateTime? cancelledAt;
  DateTime? updatedAt;

  Invoice({
    required this.reservation,
    required this.price,
    required this.createdAt,
    required this.customer,
    required this.paidAt,
    required this.cancelledAt,
    required this.updatedAt,
  });
}