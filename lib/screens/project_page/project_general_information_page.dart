import 'package:flutter/material.dart';

// Explains, what a connection project actually is. Hard-Coded Text
class ProjectGeneralInformationPage extends StatefulWidget {
  ProjectGeneralInformationPage({Key key}) : super(key: key);

  @override
  _ProjectGeneralInformationPageState createState() => _ProjectGeneralInformationPageState();
}

class _ProjectGeneralInformationPageState extends State<ProjectGeneralInformationPage> with TickerProviderStateMixin {

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
                "Seitenbeschreibung",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                textAlign: TextAlign.left,
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(30),
              child: Text(
                'Auf dieser Seite siehst du die Vernetzungsprojekte, in denen du bereits Mitglied bist und jene zu denen du beitreten kannst. Die Mitglieder eines Vernetzungsprojekts können sich über die Pinnwand der Projektseite austauschen.',
                style: TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
              ),
            ),
            Divider(
              color: Colors.black
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 30, 20, 0),
              child: Text(
                "Was ist ein Vernetzungsprojekt?",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                textAlign: TextAlign.left,
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(30),
              child: Text(
                'Über ein Vernetzungsprojekt schliesst du dich mit anderen Gärtner*innen in deiner Umgebung zusammen, um gemeinsam Massnahmen zur Förderung einer Art in den Gärten umzusetzen. Dadurch kreiert ihr ein Netz aus Trittsteinen für eine Art und verbessert ihren Lebensraum. Infos wie du eine Art fördern kannst, erhältst du unter “Arten”.',
                style: TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}