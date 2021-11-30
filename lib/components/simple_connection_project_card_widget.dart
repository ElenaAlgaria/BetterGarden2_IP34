import 'package:biodiversity/models/biodiversity_measure.dart';
import 'package:biodiversity/models/connection_project.dart';
import 'package:biodiversity/models/connection_project_amount_container.dart';
import 'package:biodiversity/models/information_object.dart';
import 'package:biodiversity/models/information_object_amount_container.dart';
import 'package:biodiversity/services/service_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

/// same as expandable\_information\_object\_card\_widget.dart, but with less infos,
/// not expandable
class SimpleConnectionProjectCard extends StatelessWidget {
  /// the [InformationObject] to display
  final ConnectionProject project;

  ///if amount is changeable by user
  final bool amountLocked;

  ///if amount is given
  final int amount;

  /// what should happen if you tap on the card
  final Function onTapHandler;

  /// additional Info to be displayed
  //final String additionalInfo;

  final ServiceProvider _serviceProvider;

  /// formKey to control the amount input field
  final GlobalKey<FormState> formKey;

  /// Non expandable ListTile, displaying a [BiodiversityMeasure]
  SimpleConnectionProjectCard(this.project,
      {this.onTapHandler,
        //this.additionalInfo,
        this.amountLocked = false,
        this.amount,
        ServiceProvider serviceProvider,
        this.formKey,
        Key key})
      : _serviceProvider = serviceProvider ?? ServiceProvider.instance,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    String _unit;
    if (project.runtimeType == BiodiversityMeasure) {
      final biodiversityObject = project as BiodiversityMeasure;
      /*if (biodiversityObject.dimension == 'Fläche') {
        _unit = 'm\u00B2';
      } else if (biodiversityObject.dimension == 'Linie') {
        _unit = 'm';
      } else {
        _unit = 'Stück';
      }*/
    }

    return InkWell(
      onTap: onTapHandler,
      child: Container(
        padding: const EdgeInsets.only(left: 5),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(3)),
          border: Border.all(
            color: const Color.fromRGBO(200, 200, 200, 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(project.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),
                  // SizedBox(
                  //   height: 40,
                  //   width: 100,
                  //   child: Form(
                  //     key: formKey,
                  //     child: TextFormField(
                  //       readOnly: amountLocked,
                  //       initialValue: amount != null ? amount.toString() : '1',
                  //       decoration: InputDecoration(
                  //           labelText: _unit,
                  //           border: const OutlineInputBorder()),
                  //       keyboardType: TextInputType.number,
                  //       onSaved: (value) =>
                  //           Provider.of<ConnectionProjectAmountContainer>(
                  //               context,
                  //               listen: false)
                  //               .amounts
                  //               .putIfAbsent(project, () => int.tryParse(value)),
                  //       inputFormatters: <TextInputFormatter>[
                  //         FilteringTextInputFormatter.digitsOnly
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  /*if (additionalInfo != null)
                    Text(
                      additionalInfo,
                      softWrap: true,
                      maxLines: 4,
                      overflow: TextOverflow.fade,
                    ),*/
                ],
              ),
            ),
           /* ClipRRect(
              borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(3),
                  bottomRight: Radius.circular(3)),
              child: _serviceProvider.imageService.getImage(
                  project.title, project.title,
                  height: 60, width: 60, fit: BoxFit.cover),
            ),*/
          ],
        ),
      ),
    );
  }
}
