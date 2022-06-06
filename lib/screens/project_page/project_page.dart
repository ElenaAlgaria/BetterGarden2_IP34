import 'package:biodiversity/components/drawer.dart';
import 'package:biodiversity/components/join_connection_project_popup_button.dart';
import 'package:biodiversity/components/leave_connection_project_button.dart';
import 'package:biodiversity/models/connection_project.dart';
import 'package:biodiversity/models/user.dart';
import 'package:biodiversity/screens/detailview_page/detailview_page_information_object.dart';
import 'package:biodiversity/screens/project_page/edit_project_page.dart';
import 'package:biodiversity/services/service_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProjectPage extends StatefulWidget {
  final ConnectionProject project;

  ProjectPage(
      {Key key,
      this.project,
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
    var userGardenReferences = ServiceProvider.instance.gardenService
        .getAllGardensFromUser(Provider.of<User>(context, listen: false))
        .map((e) => e.reference);

    return Scaffold(
        appBar: AppBar(title: Text(project.title)),
        drawer: MyDrawer(),
        body: Container(
          child: SingleChildScrollView(
            child: Column(
              children: [
                ServiceProvider.instance.imageService.getImage(
                  ServiceProvider.instance.speciesService
                      .getSpeciesByReference(project.targetSpecies)
                      .name,
                  'species',
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
                  'Projektbeschreibung',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
                    if (widget.project.gardens
                        .any((garden) => userGardenReferences.contains(garden)))
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
                          setState(() {});
                        },
                        label: const Text('Bearbeiten'),
                        icon: const Icon(Icons.edit),
                      ),
                    const SizedBox(width: 15),
                    joinConnectionProjectButton(connectionProject: project),
                    const SizedBox(width: 15),
                    leaveConnectionProjectButton(connectionProject: project, connectionProjectPage: true),
                  ],
                ),
                const Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 20)),
                const Text(
                  'Teilnehmende',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                RichText(
                    text: TextSpan(children: <TextSpan>[
                  TextSpan(
                      text: '\n' +
                          getLinksOfGardensOfProject(widget.project.gardens)
                              .join('\n'),
                      style:
                          const TextStyle(color: Colors.black, fontSize: 18)),
                ]))
              ],
            ),
          ),
        ));
  }

  List<String> getLinksOfGardensOfProject(
      List<DocumentReference<Object>> gardenRef) {
    var gardens = gardenRef.map(
        (e) => ServiceProvider.instance.gardenService.getGardenByReference(e));
    var allUsers = ServiceProvider.instance.userService.getAllUsers();
    var gardenNames = gardens
        .map((e) =>
            '  •  ' +
            e.name +
            ' von ' +
            (allUsers
                    ?.firstWhere(
                        (user) =>
                            user.gardenReferences?.contains(e.reference) ??
                            false,
                        orElse: () => null)
                    ?.nickname ??
                'Anonymous'))
        .toList();

    // TODO: return every gardenName with a link, with which you access the map with the location of the garden and open the corresponding expandable card
    return gardenNames;
  }
}
