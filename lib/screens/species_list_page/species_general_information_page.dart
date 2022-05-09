import 'package:flutter/material.dart';

// Explains, what a connection project actually is. Hard-Coded Text
class SpeciesGeneralInformationPage extends StatefulWidget {
  SpeciesGeneralInformationPage({Key key}) : super(key: key);

  @override
  _SpeciesGeneralInformationPageState createState() =>
      _SpeciesGeneralInformationPageState();
}

class _SpeciesGeneralInformationPageState
    extends State<SpeciesGeneralInformationPage> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Informationen"),
        centerTitle: true,
      ),
      //drawer: MyDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 40, 20, 0),
              child: Text(
                "Arten",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                textAlign: TextAlign.left,
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(30),
              child: Text(
                "Hier erhältst Du weitere Informationen über jene Arten und Artengruppen, die Du mit einem Vernetzungsprojekt fördern kannst. Die kurzen Infotexte stellen die wichtigsten Merkmale der Lebensweise einer Art zusammen und geben Tipps, wie die Art im Garten gefördert werden kann. Ausserdem siehst Du am Ende jedes Textes die Verbindung mit anderen Arten und Lebensräumen.",
                style: TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
