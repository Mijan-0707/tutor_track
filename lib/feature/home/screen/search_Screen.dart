import 'package:flutter/material.dart';
import 'package:tutor_track/screens/student_info_screen.dart';
import 'package:tutor_track/screens/studentprofile.dart';
import 'package:isar/isar.dart';
import 'package:tutor_track/screens/inherited_widget.dart';
import 'package:tutor_track/core/data_model/student.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // Replace List<Student> with your actual data type
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize your stream here
    // Replace fetchData() with your actual stream source
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              _searchController.text = value;
              print(_searchController.text);
            });
          },
          decoration: InputDecoration(
            hintText: 'Search',
          ),
        ),
      ),
      body: StreamBuilder(
        stream: AppDataProvider.of(context)
            .appData
            .isar!
            .students
            .filter()
            .nameContains(_searchController.text)
            .watch(fireImmediately: true),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final item = snapshot.data![index];
                return ListTile(
                  onTap: // Add your onTap code here!
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StudentProfile(
                          details: item,
                        ),
                      ),
                    );
                  },
                  title: Text(
                    ' ${item.name}',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  // Add any additional ListTile properties as needed
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
