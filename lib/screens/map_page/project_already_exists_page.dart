import 'package:biodiversity/components/join_connection_project_popup_button.dart';
import 'package:biodiversity/models/connection_project.dart';
import 'package:biodiversity/screens/project_page/create_project_page.dart';
import 'package:biodiversity/services/service_provider.dart';
import 'package:flutter/material.dart';

class ProjectAlreadyExistsPage extends StatelessWidget {

  final ConnectionProject connectionProject;

  ProjectAlreadyExistsPage(this.connectionProject, {Key key}) : super(key: key);

  //var testProj = ServiceProvider.instance.connectionProjectService
  //    .getAllConnectionProjects()
  //    .where((element) =>
  //        element.reference.id == 'ff71ce2b-6e8f-48fe-94b5-b7b4ce0a7f22')
  //    .first;

  @override
  Widget build(BuildContext context) {
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
