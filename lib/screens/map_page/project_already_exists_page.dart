import 'package:biodiversity/components/join_connection_project_popup_button.dart';
import 'package:biodiversity/models/connection_project.dart';
import 'package:biodiversity/models/garden.dart';
import 'package:biodiversity/screens/project_page/create_project_page.dart';
import 'package:biodiversity/screens/project_page/projects_overview_page.dart';
import 'package:biodiversity/services/service_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProjectAlreadyExistsPage extends StatelessWidget {
  final ConnectionProject connectionProject;
  Garden selectedGarden;

  ProjectAlreadyExistsPage(this.connectionProject, this.selectedGarden,
      {Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    builder:
    (context) {
      Provider.of<Garden>(context).switchGarden(selectedGarden);
    };
    return Scaffold(
      body: ListView(children: <Widget>[
        const SizedBox(height: 30),
        Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(children: [
              ServiceProvider.instance.imageService.getImage(
                  connectionProject.targetSpecies.toString().substring(48,
                      connectionProject.targetSpecies.toString().length - 1),
                  "species"),
              const Padding(
                padding: EdgeInsets.all(25.0),
                child: Text(
                    'Es gibt bereits ein Vernetzungsprojekt in deiner Nähe. Sieh dir das Projekt an oder wähle eine andere Spezies.'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProjectsOverviewPage()),
                  );
                },
                child: const Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Zu verfügbare Vernetzungsprojekte',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CreateProjectPage()),
                  );
                },
                child: const Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Andere Spezies wählen',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ]))
      ]),
    );
  }
}
