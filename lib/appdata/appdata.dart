import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:tutor_track/appdata/student_details_data_model.dart';
import 'package:tutor_track/constants/constants.dart';
import 'package:tutor_track/core/data_model/batch.dart';
import 'package:tutor_track/core/data_model/transaction.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/data_model/student.dart';

class AppData {
  List<String> payableMonths = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  Student student = Student();

  Isar? isar;
  Future<void> initialize() async {
    final dir = await getTemporaryDirectory();
    isar = await Isar.open([StudentSchema, BatchSchema], directory: dir.path);
  }

  // Future<void> getBatches() async {
  //   List<Batch>? batchs = await isar?.batchs.where().findAll();
  //   if (batchs != null) studentBatch.value = batchs;
  //   print(batchs);
  // }

  Future createBatch(Batch batch) async {
    await isar!.writeTxn(() async {
      await isar!.batchs.put(batch);
    });
  }

  Future<void> addNewStudent(Student student) async {
    print('student name --> ${student.name}');
    await isar!.writeTxn(() async {
      await isar!.students.put(student);
    });
  }

  Future<List<Student>?> getStudents() async {
    List<Student>? students = await isar?.students.where().findAll();
    return students;
  }

  Future<List<Batch>?> getBatches() async {
    List<Batch>? batches = await isar?.batchs.where().findAll();
    return batches;
  }

  Future<List<Student>?> getStudentsOnBatch(int batchId) async {
    List<Student>? students =
        await isar?.students.filter().batchIdEqualTo(batchId).findAll();
    return students;
  }

  void createBackup() async {
    final status = await Permission.manageExternalStorage.request();
    if (!status.isGranted) return;
    isar?.copyToFile('/storage/emulated/0/Download/tutor_track_backup.isar');
    // return;
    final downloadDir = Directory('/storage/emulated/0/Download');
    if (!downloadDir.existsSync()) await downloadDir.create(recursive: true);
    final dirExists = downloadDir.existsSync();

    // final file = await _localFile;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var batchNamesStr = prefs.getString(PreferenceConstants.batchNameKey);
    if (batchNamesStr == null) return;
    List<dynamic> batchNames = jsonDecode(batchNamesStr);

    Map<String, dynamic> data = {};
    for (int i = 0; i < batchNames.length; i++) {
      final batch = batchNames[i];
      final studentsStr = prefs.getString(batch);
      if (studentsStr == null) continue;
      final students = jsonDecode(studentsStr);
      print([batch, students]);
      data[batch] = students;
    }

    var backupStr = jsonEncode(data);
    print(backupStr);

    if (dirExists) {
      final file = File('${downloadDir.path}/tutor_track_backup.txt');
      print(file);
      if (!file.existsSync()) file.createSync();
      print(file.existsSync());
      file.writeAsString(backupStr);
    } else {
      final path = await getTemporaryDirectory();
      final file = File('${path.path}/tutor_track_backup.txt');
      file.writeAsString(backupStr);
      await Share.shareXFiles([
        XFile(
          '${path.path}/tutor_track_backup.txt',
          name: 'tutor_track_backup',
          mimeType: 'application/json',
        )
      ]);
      file.deleteSync();
    }
  }

  Future<void> restoreData() async {
    print('Restore');
    try {
      final result = await FilePicker.platform.pickFiles(
          // type: FileType.custom,
          // allowedExtensions: ['json', 'txt'],
          );
      // isar!.batchs.importJson(jsonEncode(isar!.batchs.where().findAll()));
      print('result --> ${result}');
      final backupIsar = await Isar.open([StudentSchema, BatchSchema],
          directory: result!.files.first.path!);
      print('${result.files.first.path}');
      await isar!.writeTxn(() async {
        isar!.attachCollections({Student: backupIsar.students});
        print('i am in attachCollection');
      });
      backupIsar.close();
      return;
      if (result == null) return;
      print(result);
      final f = File(result.files.first.path!);
      print(f);
      final dataStr = File(f.path!).readAsStringSync();
      f.deleteSync();
      print('dataStr: $dataStr');
      if (dataStr.isEmpty) return;

      final dataMap = jsonDecode(dataStr) as Map?;
      if (dataMap == null || dataMap.isEmpty) return;

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final keys = dataMap.keys.toList();
      await prefs.setString(PreferenceConstants.batchNameKey, jsonEncode(keys));

      for (String batch in keys) {
        await prefs.setString(batch, jsonEncode(dataMap[batch]));
        // studentBatch.value.add(batch);
      }
      // studentBatch.notifyListeners();
      // await getBatchNames();
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateStudentDetails(Student details) async {
    await isar!.writeTxn(() async {
      await isar!.students.put(details);
    });
    await getStudents();
    await getStudentsOnBatch(details.id);
  }

  Future<void> updateBatchDetails(Batch details) async {
    await isar!.writeTxn(() async {
      await isar!.batchs.put(details);
    });
    await getBatches();
  }

  Future<void> deleteStudentDetails(Student details) async {
    await isar!.writeTxn(() async {
      await isar!.students.delete(details.id); // delete
    });
    await getStudents();
  }

  Future<void> deleteBatchDetails(Batch details) async {
    await isar!.writeTxn(() async {
      await isar!.students
          .filter()
          .batchIdEqualTo(details.id)
          .deleteAll(); // delete
      await isar!.batchs.delete(details.id);
    });
    await getBatches();
  }
}
