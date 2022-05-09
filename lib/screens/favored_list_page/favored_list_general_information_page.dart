import 'package:flutter/material.dart';

// Explains, what a connection project actually is. Hard-Coded Text
class FavoredListGeneralInformationPage extends StatefulWidget {
  FavoredListGeneralInformationPage({Key key}) : super(key: key);

  @override
  _FavoredListGeneralInformationPageState createState() =>
      _FavoredListGeneralInformationPageState();
}

class _FavoredListGeneralInformationPageState
    extends State<FavoredListGeneralInformationPage> with TickerProviderStateMixin {
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
                "Merkliste",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                textAlign: TextAlign.left,
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(30),
              child: Text(
                'Die Merkliste speichert alle Texte über Lebensräume und Arten, die Du mit dem Herz-Symbol markiert hast. So sind die für Dich relevanten Informationen mit nur einem Klick erreichbar.',
                style: TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
