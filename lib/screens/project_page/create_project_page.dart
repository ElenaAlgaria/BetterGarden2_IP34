import 'package:biodiversity/components/information_object_list_widget.dart';
import 'package:biodiversity/models/garden.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:biodiversity/components/drawer.dart';

class CreateProjectPage extends StatefulWidget {
  /// Display the create project page
  CreateProjectPage({Key key}) : super(key: key);

  @override
  _CreateProjectPageState createState() => _CreateProjectPageState();
}

class _CreateProjectPageState extends State<CreateProjectPage> with TickerProviderStateMixin {
  final _formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Vernetzungsprojekt starten')),
        drawer: MyDrawer(),
        body: Builder(
            builder: (context) => Center(
                child: Form(
                    key: _formkey,
                    child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TextFormField(
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
                            ElevatedButton.icon(
                              onPressed: () {
                                if (!_formkey.currentState.validate()) {
                                  return;
                                }
                              },
                              label: Text("Vernetzungsprojekt starten"),
                              icon: Icon(Icons.save),
                            )
                          ],
                        ))))));
  }
}
