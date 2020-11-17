import 'package:flutter/material.dart';

class EventInfo {
  final String title;
  final String date;

  EventInfo.fromMap(Map snapshot)
      : title = snapshot['title'] ?? '',
        date = snapshot['date'] ?? '';
}