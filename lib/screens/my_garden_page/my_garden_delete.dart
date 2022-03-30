import 'package:biodiversity/components/edit_dialog.dart';
import 'package:biodiversity/components/white_redirect_page.dart';
import 'package:biodiversity/models/garden.dart';
import 'package:biodiversity/models/information_object.dart';
import 'package:biodiversity/models/information_object_amount_container.dart';
import 'package:biodiversity/models/user.dart';
import 'package:biodiversity/screens/my_garden_page/my_garden_page.dart';
import 'package:biodiversity/services/service_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

///Workflow Add Element To One's Garden: define amount of selected element
class MyGardenDelete extends StatefulWidget {
  ///Workflow Add Element To One's Garden: define amount of selected element
  MyGardenDelete({Key key, this.object}) : super(key: key);

  @override
  _MyGardenDeleteState createState() => _MyGardenDeleteState();

  ///Selected InformationObject
  final InformationObject object;
}

class _MyGardenDeleteState extends State<MyGardenDelete> {
  final List<bool> isSelected = [true];

  @override
  Widget build(BuildContext context) {
    final garden = Provider.of<Garden>(context, listen: false);
    return EditDialog(
      title: 'Garten löschen',
      abortCallback: () {
        Provider.of<InformationObjectAmountContainer>(context, listen: false)
            .amounts
            .clear();
        Navigator.pop(context);
      },
      save: 'Löschen',
      saveIcon: Icons.delete_forever,
      saveCallback: () {
        final user = Provider.of<User>(context, listen: false);
        user.deleteGarden(garden);

        // remove garden from all connectionProjects
        ServiceProvider.instance.connectionProjectService
            .getAllConnectionProjects()
            .where((element) => element.gardens.contains(garden.reference))
            .forEach((element) => element.removeGarden(garden.reference));

        ServiceProvider.instance.gardenService.deleteGarden(garden);

        final nextGarden = ServiceProvider.instance.gardenService.getAllGardensFromUser(user)?.first;
        Provider.of<Garden>(context, listen: false)
            .switchGarden(nextGarden ?? Garden.empty());
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  WhiteRedirectPage('Garten wurde entfernt', MyGarden())),
        );
      },
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Garten löschen',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const SizedBox(height: 20),
          const Text('Wollen Sie den ausgewählten Garten wirklich löschen?'),
          const SizedBox(height: 20),
          Container(
              width: double.infinity,
              child: ToggleButtons(
                selectedBorderColor: Theme.of(context).primaryColor,
                selectedColor: Theme.of(context).primaryColor,
                direction: Axis.vertical,
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                onPressed: (value) {},
                isSelected: isSelected,
                children: [Center(child: Text(garden.name))],
              )),
        ],
      ),
    );
  }
}
