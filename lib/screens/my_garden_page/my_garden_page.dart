import 'dart:ui';

import 'package:biodiversity/components/circlesOverview.dart';
import 'package:biodiversity/components/drawer.dart';
import 'package:biodiversity/components/information_object_list_widget.dart';
import 'package:biodiversity/models/garden.dart';
import 'package:biodiversity/models/user.dart';
import 'package:biodiversity/screens/map_page/maps_page.dart';
import 'package:biodiversity/screens/my_garden_page/my_garden_delete.dart';
import 'package:biodiversity/screens/my_garden_page/my_garden_edit.dart';
import 'package:biodiversity/services/image_service.dart';
import 'package:biodiversity/services/service_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Displays the page where the user can see his own garden
class MyGarden extends StatefulWidget {
  /// Displays the page where the user can see his own garden
  MyGarden({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MyGardenState();
  }
}

class _MyGardenState extends State<MyGarden> {
  List<Garden> gardens;
  Garden garden;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    gardens =
        ServiceProvider.instance.gardenService.getAllGardensFromUser(user);
    garden = Provider.of<Garden>(context);
    if (gardens.isNotEmpty && garden.isEmpty) {
      garden = gardens.first;
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("Mein Garten"),
        actions: [
          IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          title: const Text("Mein Garten"),
                          content: const Text(
                              "Unter “Mein Garten” siehst Du eine Zusammenfassung der Lebensräume, die Du in Deinem Garten registriert hast. Unter den drei Punkten oben rechts kannst Du den aktuell angezeigten Garten wechseln, deine Gärten bearbeiten oder einen neuen Garten hinzufügen."),
                          actions: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.exit_to_app_rounded),
                            )
                          ],
                        ));
              },
              icon: const Icon(Icons.help)),
          PopupMenuButton(
            onSelected: _handleTopMenu,
            itemBuilder: (context) {
              final _gardens = gardens.map((garden) => garden.name);
              final _menuItems = [
                PopupMenuItem(
                  value: 'gardenAddPage',
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: Icon(
                          Icons.add,
                          color: Colors.black,
                        ),
                      ),
                      const Text('Garten hinzufügen')
                    ],
                  ),
                )
              ];
              if (gardens.isNotEmpty) {
                _menuItems.addAll([
                  PopupMenuItem(
                    value: 'MyGardenEdit',
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Icon(
                            Icons.perm_contact_calendar_sharp,
                            color: Colors.black,
                          ),
                        ),
                        const Text('Garten bearbeiten'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'MyGardenDelete',
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Icon(
                            Icons.delete_forever,
                            color: Colors.black,
                          ),
                        ),
                        const Text('Garten löschen')
                      ],
                    ),
                  ),
                ]);
              }

              if (_gardens.length < 2) {
                return _menuItems;
              }
              for (final _garden in _gardens) {
                if (_garden !=
                    Provider.of<Garden>(context, listen: false).name) {
                  _menuItems.add(PopupMenuItem(
                    value: _garden,
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Icon(
                            Icons.home,
                            color: Colors.black,
                          ),
                        ),
                        Flexible(
                            child: Text(
                          'Zu $_garden wechseln',
                        )),
                      ],
                    ),
                  ));
                }
              }
              return _menuItems;
            },
          ),
        ],
      ),
      drawer: MyDrawer(),
      body: ListView(
        physics: const ScrollPhysics(),
        children: <Widget>[
          if (gardens.isEmpty)
            Column(
              children: <Widget>[
                Image(
                  width: MediaQuery.of(context).size.width,
                  height: 200,
                  fit: BoxFit.fitWidth,
                  image: const AssetImage('res/myGarden.jpg'),
                  semanticLabel: garden.name,
                ),
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                          'Hallo\n\nHier siehst du die Übersicht über deinen Garten.\n'
                          'Damit du Lebensräume in deinem Garten hinzufügen kannst '
                          'und dich mit anderen Gärtnern vernetzen kannst musst du zuerst einen Garten erstellen.',
                          style: TextStyle(fontSize: 15)),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () {
                          ServiceProvider.instance.gardenService
                              .handle_create_garden(context);
                        },
                        child: const Text('Einen Garten erstellen'),
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Stack(
                  alignment: AlignmentDirectional.center,
                  children: <Widget>[
                    (garden.imageURL.isNotEmpty)
                        ? ImageService().getImageByUrl(garden.imageURL,
                            height: 100,
                            width: MediaQuery.of(context).size.width,
                            fit: BoxFit.fitWidth)
                        : Image(
                            image: const AssetImage('res/myGarden.jpg'),
                            height: 100,
                            width: MediaQuery.of(context).size.width,
                            fit: BoxFit.fitWidth,
                            semanticLabel: garden.name,
                          ),
                    Center(
                      child: Text(
                        garden.name,
                        textAlign: TextAlign.center,
                        softWrap: true,
                        textScaleFactor: 2,
                        style: const TextStyle(
                            color: Color.fromRGBO(255, 255, 255, 0.8)),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 30, left: 30, top: 50),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Zusammenfassung von ${garden.name}:\n',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const Text(
                          'Hier sehen Sie die Lebenräume, die Sie registriert haben. '
                          'Die Menge der einzelnen Lebensräume wird je nach Typ unterschiedlich berechnet. '
                          'Je mehr unterschiedliche Lebensräume in ihrem Garten vorhanden sind, '
                          'desto grösser ist die Anzahl der Arten, die in Ihrem Garten vorkommen könnten.'),
                      const SizedBox(height: 20),
                      CirclesOverview(context, garden),
                      const SizedBox(height: 15.0),
                      TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        MapsPage(garden: garden)));
                          },
                          child: Row(
                            children: <Widget>[
                              const Icon(
                                Icons.map,
                                color: Colors.black,
                              ),
                              const SizedBox(width: 10.0),
                              const Text('Garten auf Karte anzeigen',
                                  style: TextStyle(fontSize: 16))
                            ],
                          )),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 30, left: 30, top: 30),
                  child: Text('Lebensräume in Ihrem Garten suchen',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                InformationObjectListWidget(
                  key: Key(garden.name),
                  objects: ServiceProvider.instance.gardenService
                      .getAllBiodiversityMeasuresFromGarden(garden),
                  showDeleteAndEdit: true,
                  hideLikeAndAdd: true,
                  physics: const NeverScrollableScrollPhysics(),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _handleTopMenu(String value) {
    if (value == 'MyGardenEdit') {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => MyGardenEdit()));
    } else if (value == 'gardenAddPage') {
      ServiceProvider.instance.gardenService.handle_create_garden(context);
    } else if (value == 'MyGardenDelete') {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => MyGardenDelete()));
    } else {
      final _garden = gardens.where((garden) => garden.name == value).first;
      Provider.of<Garden>(context, listen: false).switchGarden(_garden);
    }
  }
}
