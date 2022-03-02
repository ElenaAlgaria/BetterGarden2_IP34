import 'package:biodiversity/components/edit_dialog.dart';
import 'package:biodiversity/components/simple_information_object_card_widget.dart';
import 'package:biodiversity/components/white_redirect_page.dart';
import 'package:biodiversity/models/garden.dart';
import 'package:biodiversity/models/information_object.dart';
import 'package:biodiversity/models/information_object_amount_container.dart';
import 'package:biodiversity/screens/my_garden_page/my_garden_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

///Workflow Add Element To One's Garden: define amount of selected element
class DeleteElementGardenPage extends StatefulWidget {
  ///Workflow Add Element To One's Garden: define amount of selected element
  DeleteElementGardenPage({Key key, this.object}) : super(key: key);

  @override
  _DeleteElementGardenPageState createState() =>
      _DeleteElementGardenPageState();

  ///Selected InformationObject
  final InformationObject object;
}

class _DeleteElementGardenPageState extends State<DeleteElementGardenPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final garden = Provider.of<Garden>(context, listen: false);
    return EditDialog(
      title: 'Element löschen',
      abortCallback: () {
        Provider.of<InformationObjectAmountContainer>(context, listen: false)
            .amounts
            .clear();
        Navigator.pop(context);
      },
      save: 'Löschen',
      saveIcon: Icons.delete_forever,
      saveCallback: () {
        Provider.of<Garden>(context, listen: false)
            .removeFromOwnedObjects(widget.object.name);

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  WhiteRedirectPage('Element wurde entfernt', MyGarden())),
        );
      },
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Lebensraum löschen',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text('Wollen Sie das ausgewählte Element wirklich löschen?'),
          const SizedBox(height: 20),
          SimpleInformationObjectCard(
            widget.object,
            formKey: _formKey,
            amount: garden.ownedObjects[widget.object.name],
            amountLocked: true,
          ),
        ],
      ),
    );
  }
}
