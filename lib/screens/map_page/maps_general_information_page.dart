import 'package:flutter/material.dart';

// Explains, what a connection project actually is. Hard-Coded Text
class MapsGeneralInformationPage extends StatefulWidget {
  MapsGeneralInformationPage({Key key}) : super(key: key);

  @override
  _MapsGeneralInformationPageState createState() =>
      _MapsGeneralInformationPageState();
}

class _MapsGeneralInformationPageState
    extends State<MapsGeneralInformationPage> with TickerProviderStateMixin {
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
                "Karte",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                textAlign: TextAlign.left,
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(30),
              child: Text(
                "Über die Karte kannst Du alle bereits registrierten Gärten und Vernetzungsprojekte erkunden. Das “+”-Symbol ermöglicht Dir, weitere Gärten oder Vernetzungsprojekte hinzuzufügen. Ausserdem können über das Layer-Symbol die Gärten und Vernetzungsprojekte auf der Karte ein- oder ausgeblendet werden.\n\nWenn Du eine Art oder Artengruppe im Suchfeld oben auswählst, siehst Du wie gross der Aktionsradius dieser Art um Deinen Garten ist. Alle Gärten innerhalb dieses Radius könnten einem Vernetzungsprojekt für diese Art beitreten.",
                style: TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
