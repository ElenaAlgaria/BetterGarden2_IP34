import 'package:biodiversity/components/edit_dialog.dart';
import 'package:biodiversity/components/simple_information_object_card_widget.dart';
import 'package:biodiversity/components/white_redirect_page.dart';
import 'package:biodiversity/models/garden.dart';
import 'package:biodiversity/models/information_object_amount_container.dart';
import 'package:biodiversity/screens/information_list_page/biodiversity_elements_list_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

///Workflow Add Element To One's Garden: overview before saving the added element
class AddElementToGardenOverviewPage extends StatefulWidget {
  ///Workflow Add Element To One's Garden: overview before saving the added element
  AddElementToGardenOverviewPage({Key key}) : super(key: key);

  @override
  _AddElementToGardenOverviewPageState createState() =>
      _AddElementToGardenOverviewPageState();
}

class _AddElementToGardenOverviewPageState
    extends State<AddElementToGardenOverviewPage> {
  @override
  Widget build(BuildContext context) {
    final container =
        Provider.of<InformationObjectAmountContainer>(context, listen: false);
    return EditDialog(
      title: 'Lebensraum hinzufügen',
      abort: 'Zurück',
      abortIcon: Icons.navigate_before,
      abortCallback: () {
        Navigator.pop(context);
      },
      saveCallback: () {
        //save amount and element to selected garden
        final amounts = container.amounts;
        Provider.of<Garden>(context, listen: false)
            .addOwnedObject(amounts.keys.first.name, amounts.values.first);
        Provider.of<Garden>(context, listen: false).saveGarden();

        //clear the container
        container.amounts.clear();

        //redirect back to list
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => WhiteRedirectPage(
                  'Element gespeichert und hinzugefügt',
                  BiodiversityElementListPage())),
        );
      },
      cancelCallback: () {
        container.amounts.clear();

        // go back 2 times to leave the AddElementToGarden workflow
        var i = 0;
        Navigator.popUntil(context, (route) => route.isFirst || i++ == 3);
      },
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Lebensraum hinzufügen',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text('Element bestätigen.'),
          const SizedBox(height: 20),
          SimpleInformationObjectCard(
            container.amounts.keys.first,
            amountLocked: true,
            amount: container.amounts.values.first,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const Icon(Icons.house),
              Text(' Gewählter Garten: ${container.gardenName}'),
            ],
          ),
        ],
      ),
    );
  }
}
