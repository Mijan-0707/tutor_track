import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
part 'batch.g.dart';

@collection
class Batch {
  Id id = Isar.autoIncrement;
  @Index(type: IndexType.value)
  String? name;
  String? description;
  int students = 0;
  List<String>? weekDays;
  String? time;
  bool? isActive;
}
