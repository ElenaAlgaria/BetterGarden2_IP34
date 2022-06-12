import 'package:biodiversity/components/drawer.dart';
import 'package:biodiversity/components/information_object_list_widget.dart';
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
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        scrollable: true,
                            title: const Text('Arten'),
                            content: const Text(
                                'Hier erhältst Du weitere Informationen über jene Arten und Artengruppen, die Du mit einem Vernetzungsprojekt fördern kannst. Die kurzen Infotexte stellen die wichtigsten Merkmale der Lebensweise einer Art zusammen und geben Tipps, wie die Art im Garten gefördert werden kann. Ausserdem siehst Du am Ende jedes Textes die Verbindung mit anderen Arten und Lebensräumen.'),
                            actions: [
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.exit_to_app_rounded),
                              )
                            ],
                          ));
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
