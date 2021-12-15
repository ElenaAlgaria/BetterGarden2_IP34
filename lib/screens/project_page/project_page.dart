import 'package:biodiversity/components/drawer.dart';
import 'package:biodiversity/models/connection_project.dart';
import 'package:biodiversity/services/service_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProjectPage extends StatefulWidget {
  final ConnectionProject project;
  final ServiceProvider _serviceProvider;

  ProjectPage({Key key, this.project, ServiceProvider serviceProvider})
      : _serviceProvider = serviceProvider ?? ServiceProvider.instance,
        super(key: key);

  @override
  _ProjectPageState createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  ConnectionProject project;

  @override
  void initState() {
    project = widget.project;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Test-Titel")),
      drawer: MyDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                project.title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                "Description",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
