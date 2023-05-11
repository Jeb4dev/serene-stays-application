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
  final int id;
  final String name;
  final String description;
  final int servicePrice;
  String? area;

  Service(
    this.id, this.name, this.description, this.servicePrice, {this.area});
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

class Cabin {
  int? id;
  String name;
  String description;
  double price;
  String address;
  String area;
  int numberOfBeds;

  Cabin({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.address,
    required this.area,
    required this.numberOfBeds,
  });
}