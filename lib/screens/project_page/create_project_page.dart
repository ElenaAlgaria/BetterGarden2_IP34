import 'dart:developer';

import 'package:biodiversity/components/drawer.dart';
import 'package:biodiversity/components/dropdown_formfield.dart';
import 'package:biodiversity/components/garden_dropdown_widget.dart';
import 'package:biodiversity/models/connection_project.dart';
import 'package:biodiversity/models/garden.dart';
import 'package:biodiversity/models/species.dart';
import 'package:biodiversity/models/user.dart';
import 'package:biodiversity/screens/map_page/project_already_exists_page.dart';
import 'package:biodiversity/services/service_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class CreateProjectPage extends StatefulWidget {
  final ValueChanged<ConnectionProject> onConnectionProjectAdded;

  /// Display the create project page
  CreateProjectPage({Key key, this.onConnectionProjectAdded, Species currentSpecies}) : super(key: key);

  @override
  _CreateProjectPageState createState() => _CreateProjectPageState();
}

class _CreateProjectPageState extends State<CreateProjectPage>
    with TickerProviderStateMixin {
  final _formkey = GlobalKey<FormState>();

  List<Species> _speciesList = [];
  Garden _selectedGarden;
  Species _currentSpecies;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _speciesList =
        ServiceProvider.instance.speciesService.getFullSpeciesObjectList();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    if (ModalRoute.of(context).settings.arguments != '' &&
        _currentSpecies == null) {
      _currentSpecies = ModalRoute.of(context).settings.arguments as Species;
    } else {
      _currentSpecies ??= _speciesList[2];
    }
    return Scaffold(
        appBar: AppBar(title: const Text('Vernetzungsprojekt starten')),
        drawer: MyDrawer(),
        body: Builder(
            builder: (context) => Center(
                child: SingleChildScrollView(
                    padding: EdgeInsets.all(32),
                    child: Form(
                        key: _formkey,
                        child: Padding(
                            padding:
                                const EdgeInsets.fromLTRB(20.0, 0, 20.0, 10.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                TextFormField(
                                  decoration: const InputDecoration(
                                      labelText: 'Projekttitel',
                                      hintText: 'Projekttitel',
                                      labelStyle: TextStyle(
                                        fontSize: 15,
                                      )
                                  ),
                                  maxLength: 20,
                                  controller: _titleController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Geben Sie Ihrem Projekt einen Titel.';
                                    } else {
                                      return null;
                                    }
                                  },

                                ),
                                TextFormField(
                                  controller: _descriptionController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Geben Sie Ihrem Projekt eine Beschreibung.';
                                    } else {
                                      return null;
                                    }
                                  },
                                  decoration: const InputDecoration(
                                      hintText: 'Projektbeschreibung',
                                      labelText: 'Projektbeschreibung',
                                      labelStyle: TextStyle(
                                        fontSize: 15,
                                      )),
                                  maxLength: 500,
                                  maxLines: 3,
                                ),
                                speciesListWidget(),
                                Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(0, 10.0, 0, 0),
                                  child: gardenDropDown(
                                      onGardenChanged: (selectedGarden) {
                                        _selectedGarden = selectedGarden;
                                      },
                                      gardensList: ServiceProvider
                                          .instance.gardenService
                                          .getAllGardensFromUser(user)),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    if (!_formkey.currentState.validate()) {
                                      return;
                                    } else {
                                      var species =
                                          getJoinableConnectionProjectsForSpecies(
                                              _currentSpecies, _selectedGarden);
                                      if (species != null) {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ProjectAlreadyExistsPage(species, _selectedGarden)),
                                        );
                                      } else {
                                        saveProject();
                                      }
                                    }
                                  },
                                  label: Text("Vernetzungsprojekt starten"),
                                  icon: Icon(Icons.save),
                                )
                              ],
                            )))))));
  }

  void saveProject() {
    var newConnectionProject = ConnectionProject.empty();
    newConnectionProject.title = _titleController.text;
    newConnectionProject.description = _descriptionController.text;
    newConnectionProject.gardens.add(_selectedGarden.reference);
    newConnectionProject.targetSpecies = _currentSpecies.reference;
    newConnectionProject.saveConnectionProject();

    widget.onConnectionProjectAdded(newConnectionProject);

    log('saved following connectionProject');
    log(_currentSpecies.name);
    log(_selectedGarden.name);
    log(_titleController.text);
    log(_descriptionController.text);

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Verbindungsprojekt wurde erfolgreich erstellt.')));

    Navigator.pop(context);
  }

  Widget speciesListWidget() {
    return DropDownFormField(
      titleText: 'Spezies',
      hintText: 'Bitte auswählen',
      value: _currentSpecies,
      onSaved: (value) {
        setState(() {
          _currentSpecies = value;
        });
      },
      onChanged: (value) {
        setState(() {
          _currentSpecies = value;
        });
      },
      dataSource: _speciesList.map((species) {
        return {
          "display": species.name,
          "value": species,
        };
      }).toList(),
      textField: 'display',
      valueField: 'value',
    );
  }

  ConnectionProject getJoinableConnectionProjectsForSpecies(
      Species specie, Garden garden) {
    var project = ServiceProvider.instance.connectionProjectService
        .getAllConnectionProjects()
        .where((element) => !element.gardens.contains(garden.reference))
        .where((element) => element.targetSpecies.path == specie.reference.path)
        .where((element) => getConnectionProjectsInRadius(
        garden,
        element,
        ServiceProvider.instance.speciesService
            .getSpeciesByReference(element.targetSpecies)
            .radius)).toList();
    if(project.isNotEmpty){
      return project.first;
    }
  }

  bool getConnectionProjectsInRadius(
      Garden garden, ConnectionProject projectToCompareWith, int radius) {
   var x = projectToCompareWith.gardens
        .map((e) =>
        ServiceProvider.instance.gardenService.getGardenByReference(e))
        .any((element) => element.isInRange(element, garden, radius));
    return x;
  }
}
