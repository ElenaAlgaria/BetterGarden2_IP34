import 'dart:math' as math;

import 'package:biodiversity/components/connection_project_list_widget.dart';
import 'package:biodiversity/components/drawer.dart';
import 'package:biodiversity/models/connection_project.dart';
import 'package:biodiversity/models/species.dart';
import 'package:biodiversity/models/user.dart';
import 'package:biodiversity/screens/project_page/create_project_page.dart';
import 'package:biodiversity/services/service_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Displays an overview of all ConnectionProjects
class ProjectsOverviewPage extends StatefulWidget {
  /// Displays a list of all ConnectionProjects
  ProjectsOverviewPage({Key key}) : super(key: key);

  @override
  _ProjectsOverviewPageState createState() => _ProjectsOverviewPageState();
}

class _ProjectsOverviewPageState extends State<ProjectsOverviewPage>
    with TickerProviderStateMixin {
  AnimationController _fabController;
  List<Species> speciesList = [];

  static const List<IconData> icons = [
    Icons.playlist_add,
    Icons.house,
    Icons.animation_outlined,
  ];

  @override
  void initState() {
    speciesList =
        ServiceProvider.instance.speciesService.getFullSpeciesObjectList();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vernetzungsprojekte')),
      drawer: MyDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ConnectionProjectListWidget(
              objects: getJoinedConnectionProjects(),
            ),
            ConnectionProjectListWidget(
              objects: getJoinableConnectionProjects(),
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: getWidgetListTest()
          ..add(FloatingActionButton(
            heroTag: null,
            onPressed: () {
              if (_fabController.isDismissed) {
                _fabController.forward();
              } else {
                _fabController.reverse();
              }
            },
            child: AnimatedBuilder(
              animation: _fabController,
              builder: (context, child) {
                return Transform(
                  transform:
                      Matrix4.rotationZ(_fabController.value * 1.25 * math.pi),
                  alignment: FractionalOffset.center,
                  child: Icon(
                    _fabController.isDismissed ? Icons.add : Icons.add,
                    size: 30,
                  ),
                );
              },
            ),
          )),
      ),
    );
  }

  List<Widget> getWidgetListTest() {
    return [
      Container(
        height: 56.0,
        width: 75.0,
        alignment: FractionalOffset.center,
        child: ScaleTransition(
          scale: CurvedAnimation(
            parent: _fabController,
            curve: Interval(0.0, 1.0 - 1 / icons.length / 2.0,
                curve: Curves.easeOut),
          ),
          child: FloatingActionButton(
            heroTag: null,
            tooltip: 'Vernetzungsprojekt erstellen',
            backgroundColor: Theme.of(context).cardColor,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateProjectPage(),
                ),
              );
            },
            child: Icon(icons[2], color: Theme.of(context).backgroundColor),
          ),
        ),
      )
    ];
  }

  List<ConnectionProject> getJoinedConnectionProjects() {
    return ServiceProvider.instance.connectionProjectService
        .getAllConnectionProjects()
        .where((element) => element.gardens.any((element) =>
            Provider.of<User>(context).gardenReferences.contains(element)))
        .toList();
  }

  List<ConnectionProject> getJoinableConnectionProjects() {
    return ServiceProvider.instance.connectionProjectService
        .getAllConnectionProjects()
        .where((element) => element.gardens.any((element) =>
            !Provider.of<User>(context).gardenReferences.contains(element)))
        .toList();
  }
}