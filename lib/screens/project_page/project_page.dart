import 'package:biodiversity/components/drawer.dart';
import 'package:biodiversity/components/join_connection_project_popup_button.dart';
import 'package:biodiversity/components/leave_connection_project_button.dart';
import 'package:biodiversity/models/connection_project.dart';
import 'package:biodiversity/screens/detailview_page/detailview_page_information_object.dart';
import 'package:biodiversity/screens/project_page/edit_project_page.dart';
import 'package:biodiversity/services/service_provider.dart';
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
  ConnectionProject updatedProject;

  @override
  void initState() {
    project = widget.project;
    updatedProject = project;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(project.title)),
        drawer: MyDrawer(),
        body: Container (
          child: SingleChildScrollView(
            child: Column(
              children: [
                ServiceProvider.instance.imageService.getImage(
                    ServiceProvider.instance.speciesService.getSpeciesByReference(project.targetSpecies).name,
                    "species",
                    ),
                const Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 20)),
                Text(
                  project.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 30),
                ),
                const Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 20)),
                Container(
                    child: ElevatedButton.icon(
                        style: const ButtonStyle(
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DetailViewPageInformationObject(
                                ServiceProvider.instance.speciesService
                                    .getSpeciesByReference(
                                        project.targetSpecies),
                              ),
                            ),
                          );
                        },
                        label: Text(
                          ServiceProvider.instance.speciesService
                              .getSpeciesByReference(project.targetSpecies)
                              .name,
                        ),
                        icon: const Icon(Icons.emoji_nature))),
                const Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 20)),
                const Text(
                  "Projektbeschreibung",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 10)),
                Text(
                  project.description,
                  style: const TextStyle(
                      fontWeight: FontWeight.normal, fontSize: 18),
                ),
                const Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 20)),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (widget.joinedProject == true)
                      ElevatedButton.icon(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EditProjectPage(
                                      project: widget.project,
                                      onConnectionProjectChanged:
                                          (_currentConnectionProject) {
                                        //updatedProject = _currentConnectionProject;
                                      },
                                    )),
                          );
                          setState(() {
                            //project = updatedProject;
                          });
                        },
                        label: const Text('Bearbeiten'),
                        icon: const Icon(Icons.edit),
                      ),
                    SizedBox(width: 20),
                    widget.joinedProject
                        ? leaveConnectionProjectButton(
                            connectionProject: project)
                        : joinConnectionProjectButton(
                            connectionProject: project),
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}
