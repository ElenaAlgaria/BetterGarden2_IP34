import 'package:flutter/material.dart';

// Explains, what a connection project actually is. Hard-Coded Text
class GardenGeneralInformationPage extends StatefulWidget {
  GardenGeneralInformationPage({Key key}) : super(key: key);

  @override
  _GardenGeneralInformationPageState createState() =>
      _GardenGeneralInformationPageState();
}

class _GardenGeneralInformationPageState
    extends State<GardenGeneralInformationPage> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informationen'),
        centerTitle: true,
      ),
      //drawer: MyDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 40, 20, 0),
              child: Text(
                "Mein Garten",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                textAlign: TextAlign.left,
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(30),
              child: Text(
                'Unter “Mein Garten” siehst Du eine Zusammenfassung der Lebensräume, die Du in Deinem Garten registriert hast. Unter den drei Punkten oben rechts kannst Du den aktuell angezeigten Garten wechseln, deine Gärten bearbeiten oder einen neuen Garten hinzufügen.',
                style: TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
