import 'package:flutter/material.dart';

// Explains, what a connection project actually is. Hard-Coded Text
class GeneralInformationPages extends StatelessWidget {
  final String title;
  final String description;

  GeneralInformationPages(this.title, this.description, {Key key})
      : super(key: key);

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
            Padding(
              padding: EdgeInsets.fromLTRB(30, 40, 20, 0),
              child: Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                textAlign: TextAlign.left,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(30),
              child: Text(
                description,
                style: TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
