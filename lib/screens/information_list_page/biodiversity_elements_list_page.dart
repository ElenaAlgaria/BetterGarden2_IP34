import 'package:biodiversity/components/drawer.dart';
import 'package:biodiversity/components/information_object_list_widget.dart';
import 'package:biodiversity/screens/information_list_page/biodiversity_elements_general_information_page.dart';
import 'package:biodiversity/services/service_provider.dart';
import 'package:flutter/material.dart';

/// Displays a list of all BiodiversityElements
class BiodiversityElementListPage extends StatelessWidget {
  /// Displays a list of all BiodiversityElements
  BiodiversityElementListPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lebensräume'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          BioDiversityElementsInformationPage()),
                );
              },
              icon: const Icon(Icons.help))
        ],
      ),
      drawer: MyDrawer(),
      body: InformationObjectListWidget(
        objects: ServiceProvider.instance.biodiversityService
            .getFullBiodiversityObjectList(),
      ),
    );
  }
}
