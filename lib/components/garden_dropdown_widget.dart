import 'package:biodiversity/components/dropdown_formfield.dart';
import 'package:biodiversity/models/garden.dart';
import 'package:flutter/cupertino.dart';

class gardenDropDown extends StatefulWidget {
  final ValueChanged<Garden> onGardenChanged;
  final List<Garden> gardensList;

  gardenDropDown({Key key, this.onGardenChanged, this.gardensList})
      : super(key: key);

  @override
  gardenDropDownState createState() => gardenDropDownState();
}

class gardenDropDownState extends State<gardenDropDown> {
  Garden currentGarden;

  @override
  Widget build(BuildContext context) {
    if (widget.gardensList == null || widget.gardensList.isEmpty) {
      throw ArgumentError('there are no gardens present for selection');
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
        setState(() {
          currentGarden = value;
        });
        widget.onGardenChanged(value);
      },
      dataSource: widget.gardensList.map((garden) {
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
