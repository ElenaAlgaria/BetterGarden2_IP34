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
class EditElementPage extends StatefulWidget {
  ///Workflow Add Element To One's Garden: define amount of selected element
  EditElementPage({Key key, this.object}) : super(key: key);

  @override
  _EditElementPageState createState() => _EditElementPageState();

  ///Selected InformationObject
  final InformationObject object;
}

class _EditElementPageState extends State<EditElementPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final garden = Provider.of<Garden>(context, listen: false);
    return EditDialog(
      title: 'Lebensraum bearbeiten',
      abortCallback: () {
        Provider.of<InformationObjectAmountContainer>(context, listen: false)
            .amounts
            .clear();
        Navigator.pop(context);
      },
      saveCallback: () {
        _formKey.currentState.save();

        //save amount and element to selected garden
        final container = Provider.of<InformationObjectAmountContainer>(context,
            listen: false);
        Provider.of<Garden>(context, listen: false).addOwnedObject(
            container.amounts.keys.first.name, container.amounts.values.first,
            overrideAmount: true);
        container.clear();

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  WhiteRedirectPage('Element wurde angepasst', MyGarden())),
        );
      },
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Lebensraum bearbeiten',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SimpleInformationObjectCard(
            widget.object,
            formKey: _formKey,
            amount: garden.ownedObjects[widget.object.name],
          ),
        ],
      ),
    );
  }
}
