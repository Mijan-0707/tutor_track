import 'package:flutter/material.dart';
import 'package:tutor_track/core/data_model/batch.dart';
import 'package:tutor_track/core/data_model/student.dart';
import 'package:tutor_track/screens/inherited_widget.dart';
import 'package:toggle_switch/toggle_switch.dart';

class BatchInfoScreen extends StatelessWidget {
  final Batch details;

  static var context;
  BatchInfoScreen({super.key}) : details = Batch();
  BatchInfoScreen.update({super.key, required this.details});

  ValueNotifier<bool> isInvalid = ValueNotifier(false);
  bool isActive = true;
  late final batchNameController = TextEditingController(text: details.name);
  late final batchDescriptionController =
      TextEditingController(text: details.description);
  late final batchTimeController = TextEditingController(text: details.time);
  @override
  Widget build(BuildContext context) {
    print('I am in');
    final List<String> weekDays = [
      'Sat',
      'Sun',
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri'
    ];
    ValueNotifier<List<String>> workingDays = ValueNotifier([]);
    ValueNotifier<TimeOfDay> selectedTime = ValueNotifier(TimeOfDay.now());
    if (details.weekDays != null) workingDays.value = details.weekDays!;
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'Student Information',
            style: TextStyle(
                fontSize: 16, color: Colors.blue, fontWeight: FontWeight.bold),
          )),
      body: ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ValueListenableBuilder(
                valueListenable: isInvalid,
                builder: (context, v, _) {
                  return TextField(
                    controller: batchNameController,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      errorText: v ? 'Please enter the Batch name' : null,
                      labelText: 'Batch Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  );
                }),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16))),
              controller: batchDescriptionController,
            ),
          ),
          SizedBox(
            height: 45,
            child: ListView.builder(
              itemCount: weekDays.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, i) {
                return GestureDetector(
                  onTap: () {
                    if (workingDays.value.contains(weekDays[i])) {
                      workingDays.value = List.from(workingDays.value)
                        ..remove(weekDays[i]);
                    } else {
                      workingDays.value = List.from(workingDays.value)
                        ..add(weekDays[i]);
                    }
                  },
                  child: ValueListenableBuilder(
                      valueListenable: workingDays,
                      builder: (context, days, _) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 5, right: 5),
                          child: Container(
                            height: 35,
                            width: 35,
                            margin: const EdgeInsets.all(8),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: days.contains(weekDays[i])
                                    ? Colors.green
                                    : Colors.grey),
                            child: Text(weekDays[i]),
                          ),
                        );
                      }),
                );
              },
            ),
          ),
          ValueListenableBuilder(
              valueListenable: selectedTime,
              builder: (context, t, _) {
                return Container(
                  height: 50,
                  width: 50,
                  color: Colors.transparent,
                  child: Center(child: Text('${t.hour}:${t.minute}')),
                );
              }),
          GestureDetector(
              onTap: () async {
                final TimeOfDay? timeOfDay = await showTimePicker(
                    context: context, initialTime: selectedTime.value);
                if (timeOfDay != null) {
                  selectedTime.value = timeOfDay;
                }
              },
              child: Container(
                height: 50,
                width: 50,
                color: Colors.transparent,
                child: const Center(child: Text('Pick Batch Time')),
              )),
          // Here, default theme colors are used for activeBgColor, activeFgColor, inactiveBgColor and inactiveFgColor
          // ToggleSwitch(
          //   initialLabelIndex: 0,
          //   totalSwitches: 2,
          //   labels: const ['Active', 'Deactivate'],
          //   onToggle: (index) => index == 0 ? isActive = true : false

          //     // print('switched to: $index');

          // ),
          ElevatedButton(
            onPressed: () async {
              if (batchNameController.text.trim() != '') {
                details.name = batchNameController.text;
                details.description = batchDescriptionController.text;
                details.weekDays = workingDays.value;
                details.isActive = true;
                details.time = selectedTime.value.toString();
                Navigator.pop(context, details);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Name is Empty')));
                isInvalid.value = true;
              }
            },
            child: const Text(
              'Save',
            ),
          )
        ],
      ),
    );
  }
}
