import 'package:biodiversity/components/drawer.dart';
import 'package:biodiversity/components/join_connection_project_popup_button.dart';
import 'package:biodiversity/services/service_provider.dart';
import 'package:flutter/material.dart';

class ButtonPage extends StatelessWidget {
  ButtonPage({Key key}) : super(key: key);

  var testProj = ServiceProvider.instance.connectionProjectService
      .getAllConnectionProjects()
      .first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Testsite')),
      drawer: MyDrawer(),
      body: ListView(children: <Widget>[
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.all(25.0),
          child: joinConnectionProjectButton(
            connectionProject: testProj,
          ),
        ),
      ]),
    );
  }
}
