import 'package:flutter/material.dart';

class Item {
  String name;
  bool active;
  int type;
  String? extension;
  double? quantity;
  int? pcs;
  Color? color;
  String senderId;
  DateTime addDate;
  Item({
    required this.name,
    required this.quantity,
    required this.senderId,
    required this.addDate,
    this.active = false,
    this.type = 0,
    this.extension = "",
    this.pcs = 1,
    this.color,
  });
}
