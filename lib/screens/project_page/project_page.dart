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
  static const List<IconData> icons = [
    Icons.playlist_add,
    Icons.house,
  ];

  @override
  void initState() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Test-Titel")),
      drawer: MyDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                "Text",
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

  String getTitle() {
    return Provider.of<ConnectionProject>(context).title;
  }

  String getDescription() {
    return Provider.of<ConnectionProject>(context).description;
  }
}
