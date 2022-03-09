import 'package:biodiversity/components/join_connection_project_popup_button.dart';
import 'package:biodiversity/models/connection_project.dart';
import 'package:biodiversity/screens/project_page/create_project_page.dart';
import 'package:biodiversity/services/service_provider.dart';
import 'package:flutter/material.dart';

class ProjectAlreadyExistsPage extends StatelessWidget {

  final ConnectionProject connectionProject;

  ProjectAlreadyExistsPage(this.connectionProject, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint("Substring: " + connectionProject.targetSpecies.toString().substring(48, connectionProject.targetSpecies.toString().length-1));
    return Scaffold(
      //appBar: AppBar(title: const Text('Testsite')),
      //drawer: MyDrawer(),
      body: ListView(children: <Widget>[
        const SizedBox(height: 30),
        const Padding(
          padding: EdgeInsets.all(25.0),
          child: Text('Es gibt bereits ein Vernetzungsprojekt in deiner Nähe. Trete dem Projekt bei oder wähle eine andere Spezies.'),
        ),
        Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(children: [
              ServiceProvider.instance.imageService
                  .getImage(connectionProject.targetSpecies.toString().substring(48, connectionProject.targetSpecies.toString().length-1), "species"),
              joinConnectionProjectButton(
                connectionProject: connectionProject,

              ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            CreateProjectPage()),
                  );
                },
                child: Row(
                  children: [
                    const Icon(Icons.arrow_back),
                    const SizedBox(width: 5),
                    const Text('Andere Spezies wählen'),
                  ],
                ),
              ),
            ]))
      ]),
    );
  }
}
