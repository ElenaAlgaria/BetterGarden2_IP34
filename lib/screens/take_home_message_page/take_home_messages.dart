import 'package:biodiversity/components/drawer.dart';
import 'package:biodiversity/components/information_object_list_widget.dart';
import 'package:biodiversity/services/service_provider.dart';
import 'package:flutter/material.dart';

/// Page which displays some key messages for the gardeners
class TakeHomeMessagePage extends StatelessWidget {
  /// Page which displays some key messages for the gardeners
  TakeHomeMessagePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wissensgrundlagen'),
        actions: [
          IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Wissensgrundlagen"),
                      content: const Text(
                          "Diese Seite bietet Dir eine Zusammenfassung von Erkenntnissen aus der Forschung in der Form von acht Schlüsselbotschaften. Diese wurden im Rahmen des vom schweizerischen Nationalfonds finanzierten Projekts «Let`s talk about Better Gardens»\n(SNF – Agora Nr. 191645) kreiert und fassen die wichtigsten Resultate aus vier Jahren Forschungsarbeit im «Better Gardens»-Projekts (SNF–Sinergia Nr. 154416) zusammen."),
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
        objects: ServiceProvider.instance.takeHomeMessageService
            .getFullTakeHomeMessageObjectList(),
      ),
    );
  }
}
