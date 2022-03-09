import 'dart:developer';

import 'package:biodiversity/components/drawer.dart';
import 'package:biodiversity/components/dropdown_formfield.dart';
import 'package:biodiversity/components/garden_dropdown_widget.dart';
import 'package:biodiversity/models/connection_project.dart';
import 'package:biodiversity/models/garden.dart';
import 'package:biodiversity/models/species.dart';
import 'package:biodiversity/models/user.dart';
import 'package:biodiversity/services/service_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditProjectPage extends StatefulWidget {
  final ValueChanged<ConnectionProject> onConnectionProjectChanged;
  final ConnectionProject project;

  EditProjectPage(
      {Key key,
      Species currentSpecies,
      this.onConnectionProjectChanged,
      this.project,})
      : super(key: key);

  @override
  _EditProjectPageState createState() => _EditProjectPageState();
}

class _EditProjectPageState extends State<EditProjectPage>
    with TickerProviderStateMixin {
  final _formkey = GlobalKey<FormState>();

  List<Species> _speciesList = [];
  Garden _selectedGarden;
  Species _currentSpecies;
  ConnectionProject _currentConnectionProject;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _speciesList =
        ServiceProvider.instance.speciesService.getFullSpeciesObjectList();
    _currentConnectionProject = widget.project;
    _titleController.text = _currentConnectionProject.title;
    _descriptionController.text = _currentConnectionProject.description;
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
        appBar: AppBar(title: const Text('Vernetzungsprojekt bearbeiten')),
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
                                      /*hintText: _currentConnectionProject.title,*/
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
                                      labelText: 'Projektbeschreibung',
                                      labelStyle: TextStyle(
                                        fontSize: 15,
                                      )),
                                  maxLength: 500,
                                  maxLines: 3,
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    if (!_formkey.currentState.validate()) {
                                      return;
                                    } else {
                                      updateProject();
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

    Navigator.pop(context);
  }

  void updateProject() {
    _currentConnectionProject.title = _titleController.text;
    _currentConnectionProject.description = _descriptionController.text;
    _currentConnectionProject.saveConnectionProject();

    widget.onConnectionProjectChanged(_currentConnectionProject);

    log('updated following connectionProject');
    log(_currentConnectionProject.title);

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Verbindungsprojekt wurde erfolgreich aktualisiert.')));

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
}
