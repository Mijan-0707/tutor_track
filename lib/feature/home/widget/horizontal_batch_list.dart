import 'package:flutter/material.dart';
import 'package:tutor_track/core/data_model/batch.dart';
import 'package:tutor_track/screens/inherited_widget.dart';
import 'package:isar/isar.dart';

import '../../../core/data_model/student.dart';
import '../../../screens/student_info_screen.dart';
import '../../../screens/studentlist.dart';
import '../../batch/screen/batch_info_screen.dart';
import 'batch_tile.dart';

class HorizantalBatchList extends StatefulWidget {
  const HorizantalBatchList({super.key});

  @override
  State<HorizantalBatchList> createState() => _HorizantalBatchListState();
}

class _HorizantalBatchListState extends State<HorizantalBatchList> {
  @override
  Widget build(BuildContext context) {
    final isar = AppDataProvider.of(context).appData.isar!;
    var batches = isar.batchs.where().watch(fireImmediately: true);
    return SizedBox(
      height: 250,
      child: StreamBuilder(
        stream: batches,
        builder: (
          context,
          batches,
        ) {
          if (batches.data == null) {
            return const CircularProgressIndicator();
          } else {
            batches.data!.sort((a, b) => a.name!.compareTo(b.name!));
            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) => index < batches.data!.length
                  ? BatchTile(
                      batch: batches.data![index],
                      menuMap: {
                        'Edit': () async {
                          Batch result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BatchInfoScreen.update(
                                    details: batches.data![index]),
                              ));

                          await AppDataProvider.of(context)
                              .appData
                              .updateBatchDetails(result);
                          setState(() {});
                        },
                        'Delete': () async {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('data'),
                                content: Text('data'),
                                actions: [
                                  TextButton(
                                      onPressed: () {}, child: Text('data'))
                                ],
                              );
                            },
                          );
                          await AppDataProvider.of(context)
                              .appData
                              .deleteBatchDetails(batches.data![index]);
                          setState(() {});
                        }
                      },
                      onTapBody: () async {
                        var res = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => StudentListPage(
                                      batchDetails: batches.data![index],
                                    )));
                        if (res == true) setState(() {});
                      },
                      onTapAdd: () async {
                        Student? result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StudentInfoScreen(
                                  batchId: batches.data![index].id),
                            ));
                        if (result == null) return;
                        batches.data![index].students += 1;
                        AppDataProvider.of(context)
                            .appData
                            .updateBatchDetails(batches.data![index]);
                        print('list---> ${batches.data![index].students}');
                        AppDataProvider.of(context)
                            .appData
                            .addNewStudent(result);
                      },
                    )
                  : BatchTile.empty(
                      onTapEmptyCard: () async {
                        Batch result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BatchInfoScreen(),
                            ));
                        // print(result);
                        if (result.name != null) {
                          await AppDataProvider.of(context)
                              .appData
                              .createBatch(result);
                          setState(() {});
                        }
                      },
                    ),
              itemCount: batches.data!.length + 1,
            );
          }
        },
      ),
    );
  }
}
