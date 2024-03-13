import 'package:flutter/material.dart';
import 'package:tutor_track/core/data_model/student.dart';
import 'package:tutor_track/screens/student_info_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'inherited_widget.dart';

class StudentProfile extends StatelessWidget {
  StudentProfile({
    super.key,
    required this.details,
  });

  final Student details;

  bool editPayment = false;

  @override
  Widget build(BuildContext context) {
    ValueNotifier<Student> detailsValue = ValueNotifier(details);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await showModalBottomSheet(
              context: context,
              builder: (context) {
                return StatefulBuilder(builder: (context, setState1) {
                  return ListView.builder(
                      itemCount: AppDataProvider.of(context)
                          .appData
                          .payableMonths
                          .length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () async {
                            var month = AppDataProvider.of(context)
                                    .appData
                                    .payableMonths[index] +
                                '  payed on ${DateTime.now()}';
                            print('--->${month}');
                            details.paymentHistory =
                                List.from(details.paymentHistory!)..add(month);
                            print(
                                'payment history ---->${details.paymentHistory}');
                            AppDataProvider.of(context)
                                .appData
                                .updateStudentDetails(details);
                            detailsValue.notifyListeners();
                            Navigator.pop(context);
                            // setState1;
                          },
                          child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                alignment: Alignment.center,
                                height: 40,
                                decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(8)),
                                child: Text(
                                  AppDataProvider.of(context)
                                      .appData
                                      .payableMonths[index],
                                ),
                              )),
                        );
                      });
                });
              },
            );
          },
          child: const Icon(Icons.add)),
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Student Profile'),
        actions: [
          PopupMenuButton(
            itemBuilder: (c) {
              return {'Edit', 'Delete', 'Delete Payment'}.map((String choice) {
                return PopupMenuItem(
                    onTap: () async {
                      if (choice == 'Edit') {
                        Student? res = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StudentInfoScreen.update(
                                  details: details, batchId: details.batchId),
                            ));
                        if (res == null) return;
                        detailsValue.notifyListeners();
                        AppDataProvider.of(context)
                            .appData
                            .updateStudentDetails(res);
                      } else if (choice == 'Delete') {
                        AppDataProvider.of(context)
                            .appData
                            .deleteStudentDetails(details);
                        Future.delayed(
                          const Duration(seconds: 0),
                          () {
                            Navigator.pop(context, true);
                          },
                        );
                      } else if (choice == 'Delete Payment') {
                        print('top ---> ${editPayment}');
                        editPayment = true;
                        print('mid ---> ${editPayment}');

                        detailsValue.notifyListeners();
                      }
                    },
                    value: choice,
                    child: Text(choice));
              }).toList();
            },
          )
        ],
      ),
      body: ValueListenableBuilder(
          valueListenable: detailsValue,
          builder: (context, details, _) {
            print('-> inside ValueListenableBuilder : ${details.name}');
            return ListView(
              children: [
                Container(
                  height: 200,
                  decoration: const BoxDecoration(color: Colors.blue),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Name: ${details.name}',
                              style: const TextStyle(
                                  fontSize: 20, color: Colors.white),
                            ),
                            Text(
                              'Roll: ${details.roll}',
                              style: const TextStyle(
                                  fontSize: 20, color: Colors.white),
                            ),
                            Text(
                              'Srction: ${details.section}',
                              style: const TextStyle(
                                  fontSize: 20, color: Colors.white),
                            ),
                            Text(
                              details.payment ?? '',
                              style: const TextStyle(
                                  fontSize: 20, color: Colors.white),
                            ),
                            Row(
                              children: [
                                Text(
                                  details.mobile ?? '',
                                  style: const TextStyle(
                                      fontSize: 20, color: Colors.white),
                                ),
                                const Spacer(),
                                IconButton(
                                  onPressed: () {
                                    launchUrl(
                                        Uri.parse('tel:${details.mobile}'));
                                  },
                                  icon: const Icon(
                                    Icons.call,
                                    color: Colors.white,
                                  ),
                                ),
                                IconButton(
                                    onPressed: () {
                                      launchUrl(
                                          Uri.parse('sms:${details.mobile}'));
                                    },
                                    icon: const Icon(
                                      Icons.sms_rounded,
                                      color: Colors.white,
                                    ))
                              ],
                            ),
                            Text(
                              details.address ?? '',
                              style: const TextStyle(
                                  fontSize: 20, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                for (int i = 0; i < details.paymentHistory!.length; i++)
                  ListTile(
                    title: Text(details.paymentHistory![i]),
                    trailing: editPayment == true
                        ? IconButton(
                            onPressed: () {
                              details.paymentHistory =
                                  List.from(details.paymentHistory!)
                                    ..remove(details.paymentHistory![i]);
                              AppDataProvider.of(context)
                                  .appData
                                  .updateStudentDetails(details);
                              editPayment = false;
                              detailsValue.notifyListeners();
                            },
                            icon: const Icon(Icons.delete))
                        : null,
                  ),
                const SizedBox(
                  height: 60,
                ),
              ],
            );
          }),
    );
  }
}
