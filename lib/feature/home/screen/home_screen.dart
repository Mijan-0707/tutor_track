import 'package:flutter/material.dart';
import 'package:tutor_track/core/data_model/batch.dart';
import 'package:tutor_track/core/data_model/student.dart';
import 'package:tutor_track/core/theme/app_theme.dart';
import 'package:tutor_track/feature/batch/screen/batch_info_screen.dart';
import 'package:tutor_track/feature/home/screen/search_Screen.dart';
import 'package:tutor_track/feature/home/widget/batch_tile.dart';
import 'package:tutor_track/feature/home/widget/horizontal_batch_list.dart';
import 'package:tutor_track/screens/inherited_widget.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../screens/student_info_screen.dart';
import '../../../screens/studentlist.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // final isar = AppDataProvider.of(context).appData.isar!;
    // var batches = isar.batchs.where().findAll();
    AppDataProvider.of(context).appData.getBatches();
    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
            buildGreetings(context),
            const SizedBox(height: 32),
            const HorizantalBatchList(),
            const SizedBox(height: 32),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget buildGreetings(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 50,
              ),
              Text(
                'Hello,',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(
                'Sharif Khan',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Spacer(),
          buildSearch(context),
          buildPopupMenu(context),
        ],
      ),
    );
  }

  PopupMenuButton<dynamic> buildPopupMenu(BuildContext context) {
    final menuMap = {
      'Backup': (BuildContext context) {
        AppDataProvider.of(context).appData.createBackup();
      },
      'Restore': (BuildContext context) {
        AppDataProvider.of(context).appData.restoreData();
      },
      'Theme': (BuildContext context) => showThemeChangerDialog(context),
    };
    return PopupMenuButton(itemBuilder: (c) {
      return menuMap.keys.map((String choice) {
        return PopupMenuItem(
          child: Text(choice),
          onTap: () => menuMap[choice]?.call(context),
        );
      }).toList();
    });
  }

  Widget buildSearch(BuildContext context) {
    return IconButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SearchScreen(),
              ));
        },
        icon: const Icon(Icons.search));
  }

  // Widget buildSearchBar(BuildContext context) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  //     child: TextField(
  //       decoration: const InputDecoration(
  //         hintText: 'Search Student',
  //         suffixIcon: Icon(Icons.search),
  //       ),
  //       onChanged: (value) {
  //         getAllStudents();
  //       },
  //     ),
  //   );
  // }

  void showThemeChangerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildMenuItem(context, ThemeMode.light),
              buildMenuItem(context, ThemeMode.dark),
              buildMenuItem(context, ThemeMode.system),
            ],
          ),
        );
      },
    );
  }

  ListTile buildMenuItem(BuildContext context, ThemeMode mode) {
    return ListTile(
      title: Text('${mode.name[0].toUpperCase()}${mode.name.substring(1)}'),
      onTap: () {
        SharedPreferences.getInstance().then((prefs) {
          prefs.setInt('theme', mode.index);
        });
        themeValueNotifier.value = mode;
        Navigator.pop(context);
      },
      trailing:
          themeValueNotifier.value == mode ? const Icon(Icons.check) : null,
    );
  }

  Widget buildStudentTile(BuildContext context, Map<String, dynamic> student) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox.square(
        dimension: MediaQuery.of(context).size.width * .35,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.face, size: 30),
            const SizedBox(height: 8),
            Text(student['name']!.toString()),
            const SizedBox(height: 8),
            Text(
              '${student['due']!}',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ],
        ),
      ),
    );
  }

  buildSectionTitle(BuildContext context, title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Divider(thickness: 1.2),
        ],
      ),
    );
  }

  // String search = '';
  // Stream<List<Student>> getAllStudents({String? search}) async* {
  //   print(search);
  //   Isar? isar;
  //   final query = isar!.students
  //       .where()
  //       .filter()
  //       .nameContains(search ?? '', caseSensitive: false);

  //   await for (final results in query.watch(fireImmediately: true)) {
  //     if (results.isNotEmpty) {
  //       yield results;
  //     }
  //   }
  // }
}
