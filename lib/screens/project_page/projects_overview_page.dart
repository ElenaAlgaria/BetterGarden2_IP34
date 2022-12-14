import 'dart:math' as math;

import 'package:biodiversity/components/connection_project_list_widget.dart';
import 'package:biodiversity/components/drawer.dart';
import 'package:biodiversity/models/connection_project.dart';
import 'package:biodiversity/models/garden.dart';
import 'package:biodiversity/models/species.dart';
import 'package:biodiversity/screens/project_page/create_project_page.dart';
import 'package:biodiversity/services/service_provider.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:biodiversity/models/user.dart';

/// Displays an overview of all ConnectionProjects
class ProjectsOverviewPage extends StatefulWidget {
  /// Displays a list of all ConnectionProjects
  ProjectsOverviewPage({Key key}) : super(key: key);

  @override
  _ProjectsOverviewPageState createState() => _ProjectsOverviewPageState();
}

class _ProjectsOverviewPageState extends State<ProjectsOverviewPage>
    with TickerProviderStateMixin {
  TabController _tabController;
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
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
    garden = gardens.firstWhere(
        (element) =>
            element.reference == Provider.of<Garden>(context).reference,
        orElse: () => null);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vernetzungsprojekte'),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          title: const Text('Vernetzungsprojekte'),
                          content: const Text(
                              'Auf dieser Seite siehst Du die Vernetzungsprojekte, in denen Du bereits Mitglied bist und jene, zu denen Du beitreten kannst. Die Mitglieder eines Vernetzungsprojekts k??nnen sich ??ber die Pinnwand der Projektseite austauschen.\n\n??ber ein Vernetzungsprojekt schliesst Du dich mit anderen G??rtner*innen in Deiner Umgebung zusammen, um gemeinsam eine Art- oder einer Gruppe von Arten zu f??rdern. Dadurch kn??pft Ihr ein Netz aus Lebensr??umen, das immer dichter wird, je mehr Leute beitreten. Infos wie Du eine Art f??rdern kannst, erh??ltst Du unter ???Arten???.'),
                          actions: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.exit_to_app_rounded),
                            )
                          ],
                        ));
              },
              icon: const Icon(Icons.help))
        ],
      ),
      drawer: MyDrawer(),
      body: Container(
        child: Column(
          children: [
            const SizedBox(height: 20),
            DropdownButtonHideUnderline(
              child: DropdownButton2(
                items: gardens
                    .map((item) => DropdownMenuItem<Garden>(
                          value: item,
                          child: Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ))
                    .toList(),
                value: garden,
                onChanged: (value) {
                  setState(() {
                    garden = value as Garden;
                  });
                  Provider.of<Garden>(context, listen: false)
                      .switchGarden(garden);
                },
                icon: const Icon(Icons.arrow_drop_down_circle),
                iconDisabledColor: const Color(0xFFC05410),
                iconEnabledColor: const Color(0xFFC05410),
                buttonWidth: 380,
                buttonPadding: const EdgeInsets.all(8),
                dropdownPadding: const EdgeInsets.symmetric(vertical: 15),
                buttonDecoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                  ),
                ),
                scrollbarRadius: const Radius.circular(40),
                scrollbarThickness: 6,
                scrollbarAlwaysShow: true,
              ),
            ),
            const SizedBox(height: 20),
            TabBar(
              unselectedLabelColor: Colors.black,
              labelColor: Theme.of(context).primaryColor,
              tabs: [
                const Tab(
                  text: 'Meine Vernetzungsprojekte',
                ),
                const Tab(
                  text: 'Verf??gbare',
                ),
              ],
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  ConnectionProjectListWidget(
                      objects: getJoinedConnectionProjects()
                  ),
                  ConnectionProjectListWidget(
                      objects: getJoinableConnectionProjects()
                  ),
                ],
              ),
            )
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
        .where((element) =>
            element.gardens.contains(Provider.of<Garden>(context).reference))
        .toList();
  }

  List<ConnectionProject> getJoinableConnectionProjects() {
    return ServiceProvider.instance.connectionProjectService
        .getAllConnectionProjects()
        .where((element) =>
            !element.gardens.contains(Provider.of<Garden>(context).reference))
        .where((element) => getConnectionProjectsInRadius(
            Provider.of<Garden>(context),
            element,
            ServiceProvider.instance.speciesService
                .getSpeciesByReference(element.targetSpecies)
                .radius))
        ?.toList();
  }

  bool getConnectionProjectsInRadius(
      Garden garden, ConnectionProject projectToCompareWith, int radius) {
    return projectToCompareWith.gardens
        .map((e) =>
            ServiceProvider.instance.gardenService.getGardenByReference(e) ??
            Garden.empty())
        .any((element) => element.isInRange(garden, radius));
  }
}
