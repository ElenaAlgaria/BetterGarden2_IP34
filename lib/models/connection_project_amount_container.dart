import 'package:biodiversity/models/connection_project.dart';
import 'package:biodiversity/models/garden.dart';
import 'package:biodiversity/models/information_object.dart';
import 'package:flutter/cupertino.dart';

/// Container to keep track of the amount of InformationObjects added to someones garden.<br>
/// Only used as a temporary container to keep track over the amount over multiple pages
class ConnectionProjectAmountContainer extends ChangeNotifier {
  /// Amounts for each InformationObject
  final Map<ConnectionProject, int> amounts = {};

  /// to which garden the InformationObjects are associated
  Garden garden;

  /// resets the Container to the initial value
  void clear() {
    garden = null;
    amounts.clear();
  }

  /// returns the name of the garden or an empty string
  String get gardenName => garden != null ? garden.name : '';
}
