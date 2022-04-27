import 'dart:math' as math;

import 'package:biodiversity/components/connection_project_list_widget.dart';
import 'package:biodiversity/components/drawer.dart';
import 'package:biodiversity/components/garden_dropdown_widget.dart';
import 'package:biodiversity/models/connection_project.dart';
import 'package:biodiversity/models/garden.dart';
import 'package:biodiversity/models/species.dart';
import 'package:biodiversity/models/user.dart';
import 'package:biodiversity/screens/project_page/create_project_page.dart';
import 'package:biodiversity/screens/project_page/project_general_information_page.dart';
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
  List<Garden> gardens;
  Garden garden;

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
    final user = Provider.of<User>(context);
    gardens =
        ServiceProvider.instance.gardenService.getAllGardensFromUser(user);
    garden = Provider.of<Garden>(context);
    if (gardens.isNotEmpty && garden.isEmpty) {
      garden = gardens.first;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vernetzungsprojekte'),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProjectGeneralInformationPage()),
                );
              },
              icon: const Icon(Icons.help)),
        ],
      ),
      drawer: MyDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              "Aktueller Garten: " + garden.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
            IconButton(
                onPressed: () {
                  itemBuilder: (context) {
                    final _gardens = gardens.map((garden) => garden.name);
                    final _menuItems = [
                      PopupMenuItem(
                        value: 'gardenAddPage',
                        child: Row(
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: Icon(
                                Icons.add,
                                color: Colors.black,
                              ),
                            ),
                            const Text('Garten hinzufügen')
                          ],
                        ),
                      )
                    ];
                    if (gardens.isNotEmpty) {
                      _menuItems.addAll([
                        PopupMenuItem(
                          value: 'MyGardenEdit',
                          child: Row(
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(right: 10),
                                child: Icon(
                                  Icons.perm_contact_calendar_sharp,
                                  color: Colors.black,
                                ),
                              ),
                              const Text('Garten bearbeiten'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'MyGardenDelete',
                          child: Row(
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(right: 10),
                                child: Icon(
                                  Icons.delete_forever,
                                  color: Colors.black,
                                ),
                              ),
                              const Text('Garten löschen')
                            ],
                          ),
                        ),
                      ]);
                    }

                    if (_gardens.length < 2) {
                      return _menuItems;
                    }
                    for (final _garden in _gardens) {
                      if (_garden !=
                          Provider.of<Garden>(context, listen: false).name) {
                        _menuItems.add(PopupMenuItem(
                          value: _garden,
                          child: Row(
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(right: 10),
                                child: Icon(
                                  Icons.home,
                                  color: Colors.black,
                                ),
                              ),
                              Flexible(
                                  child: Text(
                                    'Zu $_garden wechseln',
                                  )),
                            ],
                          ),
                        ));
                      }
                    }
                    return _menuItems;
                  };
                },
                icon: const Icon(Icons.add)),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Meine Vernetzungsprojekte',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
            ),
            ConnectionProjectListWidget(
              objects: getJoinedConnectionProjects(),
              joinedProject: true,
            ),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Verfügbare Vernetzungsprojekte',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
            ),
            ConnectionProjectListWidget(
              objects: getJoinableConnectionProjects(),
              joinedProject: false,
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
            backgroundColor: Theme
                .of(context)
                .cardColor,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateProjectPage(),
                ),
              );
            },
            child: Icon(icons[2], color: Theme
                .of(context)
                .backgroundColor),
          ),
        ),
      )
    ];
  }

  List<ConnectionProject> getJoinedConnectionProjects() {
    return ServiceProvider.instance.connectionProjectService
        .getAllConnectionProjects()
        .where((element) =>
        element.gardens.contains(Provider
            .of<Garden>(context)
            .reference))
        .toList();
  }

  List<ConnectionProject> getJoinableConnectionProjects() {
    return ServiceProvider.instance.connectionProjectService
        .getAllConnectionProjects()
        .where((element) =>
    !element.gardens.contains(Provider
        .of<Garden>(context)
        .reference))
        .where((element) =>
        getConnectionProjectsInRadius(
            Provider.of<Garden>(context),
            element,
            ServiceProvider.instance.speciesService
                .getSpeciesByReference(element.targetSpecies)
                .radius))
        ?.toList();
  }

  bool getConnectionProjectsInRadius(Garden garden,
      ConnectionProject projectToCompareWith, int radius) {
    return projectToCompareWith.gardens
        .map((e) =>
    ServiceProvider.instance.gardenService.getGardenByReference(e) ??
        Garden.empty())
        .any((element) => element.isInRange(garden, radius));
  }

  void _handleTopMenu(String value) {
      final _garden = gardens.where((garden) => garden.name == value).first;
      Provider.of<Garden>(context, listen: false).switchGarden(_garden);
  }
}
