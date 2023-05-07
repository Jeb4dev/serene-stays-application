import 'package:flutter/material.dart';

class Area {
  String name;
  List<Item> items;
  List<Service> services;

  Area({required this.name, required this.items, required this.services});
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
