import 'package:biodiversity/models/biodiversity_measure.dart';
import 'package:biodiversity/models/connection_project.dart';
import 'package:biodiversity/services/service_provider.dart';
import 'package:flutter/material.dart';

/// same as expandable\_connection\_project\_card\_widget.dart, but with less infos,
/// not expandable
class SimpleConnectionProjectCard extends StatelessWidget {
  /// the [ConnectionProject] to display
  final ConnectionProject project;

  ///if amount is changeable by user
  final bool amountLocked;

  ///if amount is given
  final int amount;

  /// what should happen if you tap on the card
  final Function onTapHandler;


  /// formKey to control the amount input field
  final GlobalKey<FormState> formKey;

  /// Non expandable ListTile, displaying a [BiodiversityMeasure]
  SimpleConnectionProjectCard(
      this.project,
      {
        this.onTapHandler,
        //this.additionalInfo,
        this.amountLocked = false,
        this.amount,
        ServiceProvider serviceProvider,
        this.formKey,
        Key key
      }
      ) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
