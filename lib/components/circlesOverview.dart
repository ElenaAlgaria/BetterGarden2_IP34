import 'package:biodiversity/models/garden.dart';
import 'package:flutter/material.dart';

/// Displays four circles with a number in each as overview
class CirclesOverview extends StatelessWidget {
  ///passed BuildContext
  final BuildContext context;

  ///the garden of which the information needs to be displayed
  final Garden garden;

  ///constructor
  CirclesOverview(this.context, this.garden, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        runAlignment: WrapAlignment.spaceEvenly,
        runSpacing: 10,
        children: [
          _createCircle(
              '${garden.totalAreaObjects}', 'Lebensraum-Flächen\n(m\u00B2)'),
          _createCircle(
              '${garden.totalLengthObjects}', 'Lebensraum-Längen\n(m)'),
          _createCircle(
              '${garden.totalPointObjects}', 'Lebensraum-Strukturen\n(Anzahl)'),
          _createCircle(
              '${garden.totalSupportedSpecies}', 'Geförderte Arten\n(Anzahl)'),
        ],
      ),
    );
  }

  Widget _createCircle(String number, String text) {
    return SizedBox(
      width: 150,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              border: Border.all(width: 1),
              shape: BoxShape.circle,
              // You can use like this way or like the below line
              //borderRadius: new BorderRadius.circular(30.0),
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            child: Center(
                child: Text(number, style: const TextStyle(fontSize: 20.0))),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              text,
              style: TextStyle(
                  color:
                      Theme.of(context).colorScheme.onSurface.withAlpha(100)),
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
    );
  }
}
