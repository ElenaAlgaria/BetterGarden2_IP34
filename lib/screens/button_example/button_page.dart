import 'package:biodiversity/components/drawer.dart';
import 'package:biodiversity/components/join_connection_project_popup_button.dart';
import 'package:biodiversity/components/leave_connection_project_button.dart';
import 'package:biodiversity/services/service_provider.dart';
import 'package:flutter/material.dart';

class ButtonPage extends StatelessWidget {
  ButtonPage({Key key}) : super(key: key);

  var testProj = ServiceProvider.instance.connectionProjectService
      .getAllConnectionProjects()
      .where((element) =>
          element.reference.id == 'd7a7b1b2-06fb-42e4-aeb0-e87dfc143db0')
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
            child: Column(children: [
              leaveConnectionProjectButton(
                connectionProject: testProj,
              ),
              joinConnectionProjectButton(
                connectionProject: testProj,
              ),
            ]))
      ]),
    );
  }
}
