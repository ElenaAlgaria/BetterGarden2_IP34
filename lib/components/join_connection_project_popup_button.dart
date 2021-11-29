import 'dart:developer' as logging;

import 'package:biodiversity/components/garden_dropdown_widget.dart';
import 'package:biodiversity/models/connection_project.dart';
import 'package:biodiversity/models/user.dart';
import 'package:biodiversity/services/service_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class joinConnectionProjectButton extends StatefulWidget {
  final ConnectionProject connectionProject;

  joinConnectionProjectButton({Key key, this.connectionProject})
      : super(key: key);

  @override
  joinConnectionProjectButtonState createState() => joinConnectionProjectButtonState();
}

class joinConnectionProjectButtonState extends State<joinConnectionProjectButton> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    var _gardensList = ServiceProvider
        .instance.gardenService
        .getAllGardensFromUser(user);

    // TODO: disable when no
    var _disabled = false;
    // var _disabled = _gardensList.any((element) => );

    return ElevatedButton.icon(
      onPressed: _disabled ? null : () {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              var _selectedGarden;

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
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                    'Wähle den Garten, mit welchem du dem Vernetzungsprojekt beitreten willst.'),
                                Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(0, 10.0, 0, 0),
                                  child: gardenDropDown(
                                    onGardenChanged: (selectedGarden) {
                                      _selectedGarden = selectedGarden;
                                    },
                                    gardensList: _gardensList,
                                  ),
                                ),
                                Container(
                                    margin: const EdgeInsets.fromLTRB(
                                        0, 20.0, 0, 0),
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        if (!_formKey.currentState.validate()) {
                                          return;
                                        } else {
                                          if (!widget.connectionProject.gardens
                                              .contains(
                                                  _selectedGarden.reference)) {
                                            widget.connectionProject.addGarden(
                                                _selectedGarden.reference);
                                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                                content: Text('Du bist dem Verbindungsprojekt erfolgreich beigetreten.')));
                                            logging.log(
                                                'Add garden \"${_selectedGarden.name}\" to connectionProject \"${widget.connectionProject.title}\"');
                                            Navigator.of(context).pop();
                                          } else {
                                            throw ArgumentError(
                                                'garden already belongs to connectionProject');
                                          }
                                        }
                                      },
                                      label: const Text('beitreten'),
                                      icon: const Icon(Icons.add_location_alt),
                                    ))
                              ],
                            ))),
                  ],
                ),
              );
            });
      },
      label: const Text('beitreten'),
      icon: const Icon(Icons.add_location_alt),
    );
  }
}
