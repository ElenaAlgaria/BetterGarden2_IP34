/// this interface defines the common access points for information objects
/// such as BiodiversityElements or species.
/// With the help of this interface, every Widget which displays information
/// about a specific thing can be used with different classes
abstract class InformationObject {
  /// returns the title or name of the object
  String get name;

  /// returns a brief description what this element can do
  String get shortDescription;

  /// returns a long description, preferably as a markdown String
  String get description;

  /// returns which type of object this is
  String get type;

  /// the category of an object is used to create a filter for a list
  String get category;

  /// used to display additional infos on the information_object_cards.
  /// For example reading time on Take-home-messages
  ///
  /// return null, if no additional information should be displayed
  String get additionalInfo;

  /// returns a map of linked informationObjects
  /// formatted like this:
  /// ```
  /// {
  ///   'a title to display': [item1, item2],
  ///   'another title': [item4, item5, etc...]
  /// }
  /// ```
  Map<String, Iterable<InformationObject>> get associationMap;
}
