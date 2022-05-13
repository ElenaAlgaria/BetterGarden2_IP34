import 'package:biodiversity/components/drawer.dart';
import 'package:biodiversity/components/information_object_list_widget.dart';
import 'package:biodiversity/models/information_object.dart';
import 'package:biodiversity/models/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Displays a list of all BiodiversityElements
class FavoredListPage extends StatelessWidget {
  /// Displays a list of all BiodiversityElements
  FavoredListPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final list = <InformationObject>[];
    list.addAll(Provider.of<User>(context).favoredHabitatObjects);
    list.addAll(Provider.of<User>(context).favoredSpeciesObjects);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Merkliste'),
        actions: [
          IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          title: const Text('Merkliste'),
                          content: const Text(
                              'Die Merkliste speichert alle Texte über Lebensräume und Arten, die Du mit dem Herz-Symbol markiert hast. So sind die für Dich relevanten Informationen mit nur einem Klick erreichbar.'),
                          actions: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.exit_to_app_rounded),
                            )
                          ],
                        ));
              },
              icon: const Icon(Icons.help))
        ],
      ),
      drawer: MyDrawer(),
      body: InformationObjectListWidget(
        key: Key(list.map((e) => e.name).toString()),
        objects: list,
        arrangeLikeAndAddAsRow: true,
      ),
    );
  }
}
