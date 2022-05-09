import 'package:flutter/material.dart';

// Explains, what a connection project actually is. Hard-Coded Text
class TakeHomeMessageGeneralInformationPage extends StatefulWidget {
  TakeHomeMessageGeneralInformationPage({Key key}) : super(key: key);

  @override
  _TakeHomeMessageGeneralInformationPageState createState() =>
      _TakeHomeMessageGeneralInformationPageState();
}

class _TakeHomeMessageGeneralInformationPageState
    extends State<TakeHomeMessageGeneralInformationPage> with TickerProviderStateMixin {
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
                "Wissensgrundlagen",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                textAlign: TextAlign.left,
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(30),
              child: Text(
                "Diese Seite bietet Dir eine Zusammenfassung von Erkenntnissen aus der Forschung in der Form von acht Schlüsselbotschaften. Diese wurden im Rahmen des vom schweizerischen Nationalfonds finanzierten Projekts «Let`s talk about Better Gardens»\n(SNF – Agora Nr. 191645) kreiert und fassen die wichtigsten Resultate aus vier Jahren Forschungsarbeit im «Better Gardens»-Projekts (SNF–Sinergia Nr. 154416) zusammen.",
                style: TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
