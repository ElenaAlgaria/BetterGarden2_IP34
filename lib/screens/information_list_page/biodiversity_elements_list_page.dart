import 'package:biodiversity/components/drawer.dart';
import 'package:biodiversity/components/general_information_pages.dart';
import 'package:biodiversity/components/information_object_list_widget.dart';
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
                      builder: (context) => GeneralInformationPages(
                          "Lebensräume",
                          "Hier erhältst Du weitere Informationen über die Schaffung und Pflege von Lebensräumen in Deinem Garten. Am Ende jedes Textes siehst Du, welche Arten mit dem jeweiligen Lebensraum gefördert werden.\n\nAusserdem kannst Du mit Hilfe des “+”-Symbols einen Lebensraum in einem Deiner Gärten registrieren.")),
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
