import 'package:biodiversity/components/edit_dialog.dart';
import 'package:biodiversity/components/white_redirect_page.dart';
import 'package:biodiversity/models/garden.dart';
import 'package:biodiversity/models/information_object_amount_container.dart';
import 'package:biodiversity/models/user.dart';
import 'package:biodiversity/screens/information_list_page/add_element_to_garden_overview_page.dart';
import 'package:biodiversity/screens/my_garden_page/my_garden_add.dart';
import 'package:biodiversity/services/service_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

///Workflow Add Element To One's Garden: define location of selected element/to which garden it will be added
class AddElementToGardenLocationPage extends StatefulWidget {
  ///Workflow Add Element To One's Garden: define location of selected element/to which garden it will be added
  AddElementToGardenLocationPage({Key key}) : super(key: key);

  @override
  _AddElementToGardenLocationPageState createState() =>
      _AddElementToGardenLocationPageState();
}

class _AddElementToGardenLocationPageState
    extends State<AddElementToGardenLocationPage> {
  List<Garden> gardens = [];
  List<bool> isSelected = [];

  @override
  void initState() {
    super.initState();
    gardens = ServiceProvider.instance.gardenService
        .getAllGardensFromUser(Provider.of<User>(context, listen: false));
    isSelected = List.generate(gardens.length, (index) => false);
    isSelected[0] = true;
  }

  @override
  Widget build(BuildContext context) {
    if (gardens.isEmpty) {
      return WhiteRedirectPage(
          'Bitte erstelle zuerst einen Garten', MyGardenAdd());
    }
    return EditDialog(
      title: 'Lebensraum hinzufügen',
      abort: 'Zurück',
      abortIcon: Icons.navigate_before,
      abortCallback: () {
        Navigator.pop(context);
      },
      save: 'Weiter',
      saveIcon: Icons.navigate_next,
      saveCallback: () {
        //get selected element
        final selected = isSelected.indexWhere((element) => element == true);
        final selectedGarden = gardens.elementAt(selected);
        //save to provider
        Provider.of<InformationObjectAmountContainer>(context, listen: false)
            .garden = selectedGarden;
        //switch garden to selected
        Provider.of<Garden>(context, listen: false)
            .switchGarden(selectedGarden);
        //redirect to overview
        Navigator.push(
          context,
          MaterialPageRoute(
              settings: const RouteSettings(name: 'AddElementToGarden'),
              builder: (context) => AddElementToGardenOverviewPage()),
        );
      },
      cancelCallback: () {
        Provider.of<InformationObjectAmountContainer>(context, listen: false)
            .amounts
            .clear();
        // go back 3 times to leave the AddElementToGarden workflow
        var i = 0;
        Navigator.popUntil(context, (route) => route.isFirst || i++ == 2);
      },
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Lebensraum hinzufügen',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
                'Wähle den Garten, in dem Du den Lebensraum hinzufügen möchtest.'),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              child: ToggleButtons(
                  selectedBorderColor: Theme.of(context).primaryColor,
                  selectedColor: Theme.of(context).primaryColor,
                  direction: Axis.vertical,
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                  onPressed: (int index) {
                    setState(() {
                      for (var i = 0; i < isSelected.length; i++) {
                        if (i == index) {
                          isSelected[i] = true;
                        } else {
                          isSelected[i] = false;
                        }
                      }
                    });
                  },
                  isSelected: isSelected,
                  children: List.generate(gardens.length, (index) {
                    return Center(child: Text(gardens.elementAt(index).name));
                  })),
            )
          ],
        ),
      ),
    );
  }
}
