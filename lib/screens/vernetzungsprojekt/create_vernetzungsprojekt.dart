import 'package:biodiversity/components/information_object_list_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:biodiversity/components/drawer.dart';

class CreateVernetzungsprojekt extends StatelessWidget {
  CreateVernetzungsprojekt({Key key}) : super(key: key);

  final _formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Vernetzungsprojekt erstellen')),
        drawer: MyDrawer(),
        body: Builder(
            builder: (context) => Center(
                child: Form(
                    key: _formkey,
                    child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
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
                                    color: Colors.black,
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
                                    color: Colors.black,
                                  )),
                              maxLength: 500,
                              maxLines: 2,
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                if (!_formkey.currentState.validate()) {
                                  return;
                                }
                              },
                              label: Text("Vernetzungsprojekt speichern"),
                              icon: Icon(Icons.save),
                            )
                          ],
                        ))))));
  }
}
