import 'package:biodiversity/components/drawer.dart';
import 'package:biodiversity/components/join_connection_project_popup_button.dart';
import 'package:biodiversity/components/leave_connection_project_button.dart';
import 'package:biodiversity/models/connection_project.dart';
import 'package:biodiversity/services/service_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProjectPage extends StatefulWidget {
  final ConnectionProject project;
  final ServiceProvider _serviceProvider;
  final bool joinedProject;

  ProjectPage(
      {Key key,
      this.project,
      this.joinedProject,
      ServiceProvider serviceProvider})
      : _serviceProvider = serviceProvider ?? ServiceProvider.instance,
        super(key: key);

  @override
  _ProjectPageState createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  ConnectionProject project;

  @override
  void initState() {
    project = widget.project;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(project.title)),
      drawer: MyDrawer(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              project.title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            ),
            Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 20)),
            Text(
              ServiceProvider.instance.speciesService
                  .getSpeciesByReference(project.targetSpecies)
                  .name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                backgroundColor: Colors.grey[300],
              ),
            ),
            Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 20)),
            Text(
              project.description,
              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
            ),
            Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 20)),
            widget.joinedProject
                ? leaveConnectionProjectButton(connectionProject: project)
                : joinConnectionProjectButton(connectionProject: project),
          ],
        ),
      ),
    );
  }
}
