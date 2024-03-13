import 'package:flutter/material.dart';
import 'package:tutor_track/core/data_model/student.dart';
import 'package:tutor_track/screens/inherited_widget.dart';
import '../appdata/student_details_data_model.dart';

class StudentInfoScreen extends StatelessWidget {
  final Student details;
  final int? batchId;
  StudentInfoScreen({super.key, this.batchId}) : details = Student();
  StudentInfoScreen.update(
      {super.key, required this.details, required this.batchId});
  ValueNotifier<bool> isInvalid = ValueNotifier(false);
  late final nameController = TextEditingController(text: details.name);
  late final addressController = TextEditingController(text: details.address);
  late final rollController = TextEditingController(text: details.roll);
  late final mobileController = TextEditingController(text: details.mobile);
  late final paymentController = TextEditingController(text: details.payment);
  late final sectionController = TextEditingController(text: details.section);
  @override
  Widget build(BuildContext context) {
    print(batchId);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Student Information',
          style: TextStyle(
              fontSize: 16, color: Colors.blue, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ValueListenableBuilder(
                valueListenable: isInvalid,
                builder: (context, v, _) {
                  return TextField(
                    controller: nameController,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      errorText: v ? 'Please enter the Student name' : null,
                      labelText: 'Name',
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
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  labelText: 'Roll',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16))),
              controller: rollController,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
                  labelText: 'section',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16))),
              controller: sectionController,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                  labelText: 'Mobile',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16))),
              controller: mobileController,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              keyboardType: TextInputType.streetAddress,
              decoration: InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16))),
              controller: addressController,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  labelText: 'Payment',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16))),
              controller: paymentController,
            ),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text != '') {
                details.name = nameController.text;
                details.payment = paymentController.text;
                details.roll = rollController.text;
                details.section = sectionController.text;
                details.address = addressController.text;
                details.mobile = mobileController.text;
                details.batchId = batchId;
                Navigator.pop(context, details);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Name is Empty')));
                isInvalid.value = true;
              }
            },
            child: Container(
              height: 40,
              width: MediaQuery.of(context).size.width - 10,
              decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(12)),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    'Save',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
