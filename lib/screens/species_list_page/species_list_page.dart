import 'package:biodiversity/components/drawer.dart';
import 'package:biodiversity/components/information_object_list_widget.dart';
import 'package:biodiversity/screens/species_list_page/species_general_information_page.dart';
import 'package:biodiversity/services/service_provider.dart';
import 'package:flutter/material.dart';

/// Page where all Species are listed
class SpeciesListPage extends StatelessWidget {
  /// Page where all Species are listed
  SpeciesListPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Arten'),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SpeciesGeneralInformationPage()),
                  );
                },
                icon: const Icon(Icons.help))
          ],
        ),
        drawer: MyDrawer(),
        body: InformationObjectListWidget(
          objects: ServiceProvider.instance.speciesService
              .getFullSpeciesObjectList(),
        ));
  }
}
