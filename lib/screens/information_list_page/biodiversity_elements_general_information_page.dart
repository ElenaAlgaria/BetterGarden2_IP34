import 'package:flutter/material.dart';

// Explains, what a connection project actually is. Hard-Coded Text
class BioDiversityElementsInformationPage extends StatefulWidget {
  BioDiversityElementsInformationPage({Key key}) : super(key: key);

  @override
  _BioDiversityElementsInformationPageState createState() =>
      _BioDiversityElementsInformationPageState();
}

class _BioDiversityElementsInformationPageState
    extends State<BioDiversityElementsInformationPage> with TickerProviderStateMixin {
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
                "Lebensräume",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                textAlign: TextAlign.left,
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(30),
              child: Text(
                "Hier erhältst Du weitere Informationen über die Schaffung und Pflege von Lebensräumen in Deinem Garten. Am Ende jedes Textes siehst Du, welche Arten mit dem jeweiligen Lebensraum gefördert werden.\n\nAusserdem kannst Du mit Hilfe des “+”-Symbols einen Lebensraum in einem Deiner Gärten registrieren.",
                style: TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
