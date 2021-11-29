import 'dart:developer';

import 'package:biodiversity/components/drawer.dart';
import 'package:biodiversity/components/dropdown_formfield.dart';
import 'package:biodiversity/components/garden_dropdown_widget.dart';
import 'package:biodiversity/models/connection_project.dart';
import 'package:biodiversity/models/garden.dart';
import 'package:biodiversity/models/species.dart';
import 'package:biodiversity/models/user.dart';
import 'package:biodiversity/services/service_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
    if(ModalRoute.of(context).settings.arguments != '' && _currentSpecies == null) {
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
                                  margin:
                                      const EdgeInsets.fromLTRB(0, 10.0, 0, 0),
                                  child: gardenDropDown(onGardenChanged: (selectedGarden) {
                                    _selectedGarden = selectedGarden;
                                  },),
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
    newConnectionProject.gardens.add(_selectedGarden.reference);
    newConnectionProject.targetSpecies = _currentSpecies.reference;
    newConnectionProject.saveConnectionProject();

    log('saved following connectionProject');
    log(_currentSpecies.name);
    log(_selectedGarden.name);
    log(_titleController.text);
    log(_descriptionController.text);

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Verbindungsprojekt wurde erfolgreich erstellt.')));

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
}
