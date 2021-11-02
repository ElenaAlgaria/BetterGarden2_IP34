import 'package:biodiversity/components/drawer.dart';
import 'package:biodiversity/models/storage_provider.dart';
import 'package:biodiversity/services/service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

/// Displays the impressum
class ButtonPage extends StatelessWidget {
  /// Displays the impressum
  ButtonPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Button')),
      drawer: MyDrawer(),
      body: ListView(
          children: <Widget>[


            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.all(25.0),
              child:    ElevatedButton.icon(
              onPressed: () {  },

              label: Text("Vernetzungsprojekt speichern"),
              icon: Icon(Icons.save) ,

            )
            )
                ]
            ),


    );

  }


}
