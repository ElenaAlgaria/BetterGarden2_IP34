import 'dart:developer';

import 'package:biodiversity/components/drawer.dart';
import 'package:biodiversity/components/dropdown_formfield.dart';
import 'package:biodiversity/models/connection_project.dart';
import 'package:biodiversity/models/garden.dart';
import 'package:biodiversity/models/species.dart';
import 'package:biodiversity/models/user.dart';
import 'package:biodiversity/services/service_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateProjectPage extends StatefulWidget {
  /// Display the create project page
  CreateProjectPage({Key key, Species currentSpecies}) : super(key: key);

  @override
  _CreateProjectPageState createState() => _CreateProjectPageState();
}

class _CreateProjectPageState extends State<CreateProjectPage>
    with TickerProviderStateMixin {
  final _formkey = GlobalKey<FormState>();

  List<Species> _speciesList = [];
  List<Garden> _gardensList = [];
  Garden _currentGarden;
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
    _currentSpecies = ModalRoute.of(context).settings.arguments as Species;
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
                        padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 10.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TextFormField(
                              controller: _titleController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Geben Sie Ihrem Projekt einen Titel.';
                                } else {
                                  return null;
                                }
                              },
                              decoration: const InputDecoration(
                                  hintText: 'Projekttitel',
                                  labelText: 'Projekttitel',
                                  labelStyle: TextStyle(
                                    fontSize: 15,
                                  )),
                              maxLength: 20,
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
                              margin: const EdgeInsets.fromLTRB(0, 10.0, 0, 0),
                              child: gardensListWidget(),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                if (!_formkey.currentState.validate()) {
                                  return;
                                } else {
                                  saveProject();
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
    newConnectionProject.gardens.add(_currentGarden.reference);
    newConnectionProject.targetSpecies = _currentSpecies.reference;
    newConnectionProject.saveConnectionProject();

    log('saved following connectionProject');
    log(_currentSpecies.name);
    log(_currentGarden.name);
    log(_titleController.text);
    log(_descriptionController.text);

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'Verbindungsprojekt wurde erfolgreich erstellt.')));

    // TODO: close Widget again after successful save
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

  Widget gardensListWidget() {
    final user = Provider.of<User>(context);
    _gardensList =
        ServiceProvider.instance.gardenService.getAllGardensFromUser(user);
    if(_gardensList.isEmpty) {
      throw ArgumentError(
          'You have to register a garden, before creating a connection project');
    } else {
      _currentGarden = _gardensList.first;
    }
    return DropDownFormField(
      titleText: 'Garten',
      hintText: 'Bitte auswählen',
      value: _currentGarden,
      onSaved: (value) {
        setState(() {
          _currentGarden = value;
        });
      },
      onChanged: (value) {
        setState(() {
          _currentGarden = value;
        });
      },
      dataSource: _gardensList.map((garden) {
        return {
          "display": garden.name,
          "value": garden,
        };
      }).toList(),
      textField: 'display',
      valueField: 'value',
    );
  }
}
