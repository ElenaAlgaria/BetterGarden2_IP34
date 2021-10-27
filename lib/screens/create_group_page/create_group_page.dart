import 'package:biodiversity/components/drawer.dart';
import 'package:biodiversity/models/storage_provider.dart';
import 'package:biodiversity/services/service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

/// Displays the impressum
class CreateGroupPage extends StatelessWidget {
  /// Displays the impressum
  CreateGroupPage(currentSpecies, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Neues Vernetzungsprojekt erstellen')),
      drawer: MyDrawer(),
      body: const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text('Hier werden neue Vernetzungsprojekte erstellt')
      )
    );
  }
}
