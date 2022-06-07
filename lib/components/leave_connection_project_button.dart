import 'dart:developer' as logging;

import 'package:biodiversity/components/confirmation_dialog.dart';
import 'package:biodiversity/components/garden_dropdown_widget.dart';
import 'package:biodiversity/models/connection_project.dart';
import 'package:biodiversity/models/garden.dart';
import 'package:biodiversity/models/user.dart';
import 'package:biodiversity/screens/map_page/maps_page.dart';
import 'package:biodiversity/screens/project_page/projects_overview_page.dart';
import 'package:biodiversity/services/service_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class leaveConnectionProjectButton extends StatefulWidget {
  final ConnectionProject connectionProject;
  final ValueChanged<ConnectionProject> onConnectionProjectDeleted;
  final bool connectionProjectPage;

  leaveConnectionProjectButton(
      {Key key, this.connectionProject, this.onConnectionProjectDeleted, this.connectionProjectPage})
      : super(key: key);

  @override
  leaveConnectionProjectButtonState createState() =>
      leaveConnectionProjectButtonState();
}

class leaveConnectionProjectButtonState
    extends State<leaveConnectionProjectButton> {
  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final user = Provider.of<User>(context);
    var _ownedGardensInProject = ServiceProvider.instance.gardenService
        .getAllGardensFromUser(user)
        .where((element) =>
            widget.connectionProject.gardens.contains(element.reference))
        .toList();

    var _disabled = _ownedGardensInProject.isEmpty;

    return ElevatedButton.icon(
      onPressed: _disabled
          ? null
          : () async {
              Garden _selectedGarden;
              if (_ownedGardensInProject.length == 1) {
                await leaveConnectionProject(
                    context, _ownedGardensInProject.first, widget.connectionProjectPage);
              } else {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: Stack(
                          children: <Widget>[
                            Positioned(
                              right: -40.0,
                              top: -40.0,
                              child: InkResponse(
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                child: const CircleAvatar(
                                  backgroundColor: Colors.red,
                                  child: Icon(Icons.close),
                                ),
                              ),
                            ),
                            Form(
                                key: _formKey,
                                child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Text(
                                            'Wähle den Garten, mit welchem du das Vernetzungsprojekt verlassen willst.'),
                                        Container(
                                          margin: const EdgeInsets.fromLTRB(
                                              0, 10.0, 0, 0),
                                          child: gardenDropDown(
                                            onGardenChanged: (selectedGarden) {
                                              _selectedGarden = selectedGarden;
                                            },
                                            gardensList: _ownedGardensInProject,
                                          ),
                                        ),
                                        Container(
                                            margin: const EdgeInsets.fromLTRB(
                                                0, 20.0, 0, 0),
                                            child: ElevatedButton.icon(
                                              onPressed: () async {
                                                return await leaveConnectionProject(
                                                    context, _selectedGarden, widget.connectionProjectPage);
                                              },
                                              label: const Text('Verlassen'),
                                              icon: const Icon(
                                                  Icons.cancel_outlined),
                                            ))
                                      ],
                                    ))),
                          ],
                        ),
                      );
                    });
              }
            },
      label: const Text('Verlassen'),
      icon: const Icon(Icons.cancel_outlined),
    );
  }

  Future<void> leaveConnectionProject(
      BuildContext context, Garden gardenToRemove, bool connectionProjectPage) async {
    if (await confirm(context,
        content: Text(
            'Möchtest du das Vernetzungsprojekt \"${widget.connectionProject.title}\" wirklich verlassen?'),
        textOK: const Text('Verlassen'))) {
      widget.connectionProject.removeGarden(gardenToRemove.reference);

      // Delete ConnectionProject if no garden is remaining
      if (widget.connectionProject.gardens.isEmpty) {
        await ServiceProvider.instance.connectionProjectService
            .deleteConnectionProject(widget.connectionProject);
        // Navigator
        if(connectionProjectPage == true) {
          Navigator.push(context, MaterialPageRoute(
              builder: (context) =>
                  ProjectsOverviewPage()));
        } else {
          Navigator.pop(context);
        }
        widget.onConnectionProjectDeleted(widget.connectionProject);
      } else {
        if(connectionProjectPage == true) {
          Navigator.push(context, MaterialPageRoute(
              builder: (context) =>
                  ProjectsOverviewPage()));
        } else {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(
              builder: (context) =>
                  MapsPage(garden: gardenToRemove)));
        }
      }

      return logging.log(
          'left connectionProject ${widget.connectionProject.title} with garden ${gardenToRemove.name}');
    }
    return;
  }
}
