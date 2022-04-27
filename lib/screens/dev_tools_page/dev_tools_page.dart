import 'dart:collection';
import 'dart:developer' as logging;

import 'package:biodiversity/components/drawer.dart';
import 'package:biodiversity/components/join_connection_project_popup_button.dart';
import 'package:biodiversity/components/leave_connection_project_button.dart';
import 'package:biodiversity/models/connection_project.dart';
import 'package:biodiversity/services/service_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DevToolsPage extends StatelessWidget {
  DevToolsPage({Key key}) : super(key: key);

  var testProj = ServiceProvider.instance.connectionProjectService
      .getAllConnectionProjects()
      .where((element) =>
          element.reference.id == 'ff71ce2b-6e8f-48fe-94b5-b7b4ce0a7f22')
      .first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Developer tools')),
      drawer: MyDrawer(),
      body: ListView(children: <Widget>[
        Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(children: [
              const Padding(
                padding: EdgeInsets.all(15), //apply padding to all four sides
                child: Text(
                  'Dev Tools',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              ElevatedButton.icon(
                  onPressed: () => fixInvalidGardenReferences(context),
                  icon: const Icon(Icons.sync_alt),
                  label: const Text(
                    'fix invalid gardenReferences',
                    textScaleFactor: 1.3,
                  )),
              ElevatedButton.icon(
                  onPressed: () => fixEmptyConnectionProjects(context),
                  icon: const Icon(Icons.sync_alt),
                  label: const Text(
                    'fix empty connectionProjects',
                    textScaleFactor: 1.3,
                  )),
              const Padding(
                padding: EdgeInsets.all(15), //apply padding to all four sides
                child: Text(
                  'Testing space',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              leaveConnectionProjectButton(
                connectionProject: testProj,
              ),
              joinConnectionProjectButton(
                connectionProject: testProj,
              ),
            ]))
      ]),
    );
  }

  void fixInvalidGardenReferences(BuildContext context) {
    var hashMap = HashMap<DocumentReference, ConnectionProject>();
    ServiceProvider.instance.connectionProjectService
        .getAllConnectionProjects()
        .forEach((project) => {
              project.gardens.forEach((element) {
                if (ServiceProvider.instance.gardenService
                        .getGardenByReference(element) ==
                    null) {
                  hashMap.putIfAbsent(element, () => project);
                }
              })
            });
    hashMap.forEach((key, value) {
      value.removeGarden(key);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('removed invalid gardenReference: ' + key.id)));
      logging.log('removed invalid gardenReference: ' + key.id);
    });
    if(hashMap.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
          Text('no empty invalid gardenReferences found :)')));
    }
  }

  void fixEmptyConnectionProjects(BuildContext context) {
    var projectsToDelete = <ConnectionProject>[];
    ServiceProvider.instance.connectionProjectService
        .getAllConnectionProjects()
        ?.forEach((element) {
      if (element.gardens.isEmpty) {
        projectsToDelete.add(element);
      }
    });
    projectsToDelete.forEach((element) {
      ServiceProvider.instance.connectionProjectService
          .deleteConnectionProject(element)
          .then((value) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text('removed empty connectionProject: ' + element.title)));
        logging.log('removed empty connectionProject: ' + element.title);
      });
    });
    if(projectsToDelete.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
          Text('no empty connectionProjects found :)')));
    }
  }
}
