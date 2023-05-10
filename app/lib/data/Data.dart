import 'dart:convert';

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
  String price;
  String description;
  String address;

  Item(
      {required this.name,
        required this.price,
        required this.description,
        required this.address});
}

class Service {
  final String name;
  final String description;
  final int servicePrice;

  Service(
      this.name, this.description, this.servicePrice
      );
}


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