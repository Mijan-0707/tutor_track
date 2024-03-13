import 'package:flutter/material.dart';
import 'package:tutor_track/core/data_model/batch.dart';
import 'package:tutor_track/core/data_model/student.dart';
import 'package:tutor_track/feature/batch/screen/batch_info_screen.dart';
import 'package:tutor_track/feature/home/screen/home_screen.dart';
import 'package:tutor_track/screens/student_info_screen.dart';
import 'package:tutor_track/screens/studentprofile.dart';
import 'package:isar/isar.dart';
import '../widgets/profileicon.dart';
import 'inherited_widget.dart';

class StudentListPage extends StatefulWidget {
  StudentListPage({
    super.key,
    required this.batchDetails,
  });
  Batch? batchDetails;

  @override
  State<StudentListPage> createState() => _StudentListPageState();
}

class _StudentListPageState extends State<StudentListPage> {
  final searchText = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isar = AppDataProvider.of(context).appData.isar!;
    var isarStream = isar.students
        .filter()
        .batchIdEqualTo(widget.batchDetails!.id)
        .watch(fireImmediately: true);
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () async {
            Student? result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentInfoScreen(
                    batchId: widget.batchDetails!.id,
                  ),
                ));
            if (result == null) return;
            widget.batchDetails!.students += 1;
            AppDataProvider.of(context)
                .appData
                .updateBatchDetails(widget.batchDetails!);
            AppDataProvider.of(context).appData.addNewStudent(result);
          },
        ),
        appBar: AppBar(
            centerTitle: true,
            title: Text('${widget.batchDetails!.name}'),
            actions: [
              PopupMenuButton(
                itemBuilder: (c) {
                  return {'Edit', 'Delete'}.map((String choice) {
                    return PopupMenuItem(
                        onTap: () async {
                          if (choice == 'Edit') {
                            var res = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BatchInfoScreen.update(
                                      details: widget.batchDetails!),
                                ));
                            await AppDataProvider.of(context)
                                .appData
                                .updateBatchDetails(res);
                            setState(() {});
                          } else if (choice == 'Delete') {
                            await AppDataProvider.of(context)
                                .appData
                                .deleteBatchDetails(widget.batchDetails!);
                            Navigator.pop(context, true);
                          }
                        },
                        value: choice,
                        child: Text(choice));
                  }).toList();
                },
              )
            ],
            leading: IconButton(
                onPressed: () {
                  Navigator.pop(context,
                      MaterialPageRoute(builder: ((context) => HomeScreen())));
                },
                icon: const Icon(Icons.arrow_back))),
        body: StreamBuilder(
          stream: isarStream,
          builder: (context, students) {
            if (students.hasData) {
              return ListView.builder(
                itemCount: students.data!.length,
                itemBuilder: (context, index) {
                  students.data!
                      .sort((a, b) => a.name!.compareTo(b.name ?? ''));
                  return ListTile(
                    title: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StudentProfile(
                                  details: students.data![index]),
                            ));
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        color: Colors.transparent,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Name: ${students.data![index].name}'),
                            Text('Roll: ${students.data![index].roll}'),
                            Text('Section: ${students.data![index].section}'),
                          ],
                        ),
                      ),
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (c) {
                        return {'Edit', 'Delete'}.map((String choice) {
                          return PopupMenuItem(
                              onTap: () async {
                                Future.delayed(
                                  const Duration(seconds: 0),
                                  () async {
                                    if (choice == 'Edit') {
                                      Student? res = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                StudentInfoScreen.update(
                                                    details:
                                                        students.data![index],
                                                    batchId: widget
                                                        .batchDetails!.id),
                                          ));
                                      if (res == null) return;
                                      AppDataProvider.of(context)
                                          .appData
                                          .updateStudentDetails(res);
                                    } else if (choice == 'Delete') {
                                      AppDataProvider.of(context)
                                          .appData
                                          .deleteStudentDetails(
                                              students.data![index]);
                                      widget.batchDetails!.students -= 1;
                                      AppDataProvider.of(context)
                                          .appData
                                          .updateBatchDetails(
                                              widget.batchDetails!);
                                    }
                                  },
                                );
                              },
                              value: choice,
                              child: Text(choice));
                        }).toList();
                      },
                    ),
                  );
                },
              );
            } else {
              return const CircularProgressIndicator();
            }
          },
        ));
  }
}
