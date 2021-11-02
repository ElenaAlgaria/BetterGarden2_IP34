import 'package:biodiversity/components/information_object_list_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:biodiversity/components/drawer.dart';

class CreateVernetzungsprojekt extends StatelessWidget {
  CreateVernetzungsprojekt({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vernetzungsprojekt erstellen')),
      drawer: MyDrawer(),
      body: Column(
      children: [
         const TextField(
          decoration:InputDecoration(
            hintText: 'Projekttitel',
            labelText: 'Projekttitel',
            labelStyle: TextStyle(
              fontSize: 15,
              color: Colors.black,
/*              validaor: (value) {
                if (value == null || value.isEmpty) {
                  return 'Geben Sie Ihrem Vernetzungsprojekt einen Titel.';
                }
                return null;
              }*/
            )
          ),
              maxLength: 20,
        ),
        const TextField(
          decoration: InputDecoration(
            hintText: 'Projektbeschreibung',
            labelText: 'Projektbeschreibung',
            labelStyle: TextStyle(
              fontSize: 15,
              color: Colors.black,
            )
          ),
            maxLength: 500,
          maxLines: 2,
        ),
        ElevatedButton.icon(
          onPressed: () {  },
          label: Text("Vernetzungsprojekt speichern"),
          icon: Icon(Icons.save) ,
        )
      ],
    )
    );
  }
}