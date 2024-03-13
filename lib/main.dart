import 'package:flutter/material.dart';
import 'package:tutor_track/appdata/appdata.dart';
import 'package:tutor_track/core/data_model/student.dart';
import 'package:tutor_track/core/theme/app_theme.dart';
import 'package:tutor_track/feature/home/screen/home_screen.dart';
import 'package:tutor_track/screens/inherited_widget.dart';
import 'package:tutor_track/screens/student_info_screen.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.getInstance().then((prefs) {
    final themeIndex = prefs.getInt('theme') ?? 0;
    themeValueNotifier.value = ThemeMode.values[themeIndex];
  });

  AppData appData = AppData();
  await appData.initialize();
  runApp(
    AppDataProvider(
      appData: appData,
      child: ValueListenableBuilder<ThemeMode>(
          valueListenable: themeValueNotifier,
          builder: (context, themeMode, child) {
            return MaterialApp(
              themeMode: themeMode,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              home: HomeScreen(),
            );
          }),
    ),
  );
}

class StreamTest extends StatelessWidget {
  const StreamTest({super.key});

  @override
  Widget build(BuildContext context) {
    final isar = AppDataProvider.of(context).appData.isar!;
    final studentsStream = isar.students
        .filter()
        .batchIdEqualTo(1)
        .nameContains('12')
        .or()
        .mobileContains('12')
        .build()
        .watch(fireImmediately: true);
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: () async {
        final res = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StudentInfoScreen(batchId: 1),
          ),
        );

        if (res != null) {
          isar.writeTxn(() async {
            await isar.students.put(res as Student);
          });
        }
      }),
      body: StreamBuilder(
        stream: studentsStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () async {
                    final res = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StudentInfoScreen.update(
                            batchId: 1, details: snapshot.data![index]),
                      ),
                    );

                    if (res != null) {
                      isar.writeTxn(() async {
                        await isar.students.put(res as Student);
                      });
                    }
                  },
                  title: Text(snapshot.data![index].name ?? ''),
                  subtitle: Text(snapshot.data![index].mobile ?? ''),
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
