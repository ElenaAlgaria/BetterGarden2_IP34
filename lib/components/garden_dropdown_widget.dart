import 'package:biodiversity/components/dropdown_formfield.dart';
import 'package:biodiversity/models/garden.dart';
import 'package:biodiversity/models/user.dart';
import 'package:biodiversity/services/service_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class gardenDropDown extends StatefulWidget {
  final ValueChanged<Garden> onGardenChanged;

  gardenDropDown({Key key, this.onGardenChanged}) : super(key: key);

  @override
  gardenDropDownState createState() => gardenDropDownState();
}

class gardenDropDownState extends State<gardenDropDown> {
  Garden currentGarden;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    var _gardensList =
        ServiceProvider.instance.gardenService.getAllGardensFromUser(user);

    if (_gardensList == null || _gardensList.isEmpty) {
      throw ArgumentError(
          'You have to register a garden, before creating a connection project');
    } else {
      currentGarden = _gardensList.first;
      widget.onGardenChanged(currentGarden);
    }

    return DropDownFormField(
      titleText: 'Garten',
      hintText: 'Bitte auswählen',
      value: currentGarden,
      onSaved: (value) {
        setState(() {
          currentGarden = value;
        });
      },
      onChanged: (value) {
        widget.onGardenChanged(value);
      },
      dataSource: _gardensList.map((garden) {
        return {
          'display': garden.name,
          'value': garden,
        };
      }).toList(),
      textField: 'display',
      valueField: 'value',
    );
  }
}