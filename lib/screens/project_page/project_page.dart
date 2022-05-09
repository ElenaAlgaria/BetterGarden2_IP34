import 'package:biodiversity/components/drawer.dart';
import 'package:biodiversity/components/join_connection_project_popup_button.dart';
import 'package:biodiversity/components/leave_connection_project_button.dart';
import 'package:biodiversity/models/connection_project.dart';
import 'package:biodiversity/screens/project_page/edit_project_page.dart';
import 'package:biodiversity/services/service_provider.dart';
import 'package:flutter/material.dart';

class ProjectPage extends StatefulWidget {
  final ConnectionProject project;
  final bool joinedProject;

  ProjectPage(
      {Key key,
      this.project,
      this.joinedProject,
      ServiceProvider serviceProvider})
      : super(key: key);

  @override
  _ProjectPageState createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  ConnectionProject project;
  ConnectionProject updatedProject;

  @override
  void initState() {
    project = widget.project;
    updatedProject = project;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(project.title)),
      drawer: MyDrawer(),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                project.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
              ),
              const Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 40)),
              Container(
                width: 200.0,
                height: 60.0,
                child: TextField(
                  readOnly: true,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50.0),
                      borderSide: const BorderSide(color: Colors.grey, width: 2.0),
                    ),
                    hintText: ServiceProvider.instance.speciesService
                        .getSpeciesByReference(project.targetSpecies)
                        .name,
                  ),
                ),
              ),
              const Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 20)),
              Text(
                project.description,
                style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
              ),
              const Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 20)),
              widget.joinedProject
                  ? leaveConnectionProjectButton(connectionProject: project)
                  : joinConnectionProjectButton(connectionProject: project),
              if(widget.joinedProject == true)
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 15),
                child: TextButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              EditProjectPage(
                                project: widget.project,
                                onConnectionProjectChanged: (_currentConnectionProject) {
                                  //updatedProject = _currentConnectionProject;
                                },
                              )),
                    );
                    setState(() {
                      //project = updatedProject;
                    });
                  },
                  child: const Text(
                    'Bearbeiten',
                    style: TextStyle(decoration: TextDecoration.underline),
                  ),
                ),
              )
            ],
          ),
        ),
      )
    );
  }
}
