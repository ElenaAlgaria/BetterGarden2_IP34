import 'package:biodiversity/models/biodiversity_measure.dart';
import 'package:biodiversity/models/information_object.dart';
import 'package:biodiversity/models/storage_provider.dart';
import 'package:biodiversity/services/service_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Container class for a species
class Species implements InformationObject {
  @override
  final String name;

  @override
  String shortDescription;

  @override
  String description;

  @override
  final String type;

  @override
  final String category;

  @override
  String get additionalInfo => null;

  /// other species which
  final List<String> connectedTo;

  /// a list of objects which support this species
  final List<String> supportedBy;

  /// reference to the store location in the database
  final DocumentReference reference;

  /// reference to an imageSource of the species
  final String imageSource;

  final _descriptionPath = 'species/description';
  final StorageProvider _storage;
  final ServiceProvider _service;

  /// creates a Species object from a Map
  Species.fromMap(Map<String, dynamic> map,
      {this.reference,
      ServiceProvider serviceProvider,
      StorageProvider storageProvider})
      : _service = serviceProvider ?? ServiceProvider.instance,
        _storage = storageProvider ?? StorageProvider.instance,
        category = map.containsKey('class') ? map['class'] as String : '',
        name = map.containsKey('name') ? map['name'] as String : '',
        shortDescription = map.containsKey('shortDescription')
            ? map['shortDescription'] as String
            : '',
        imageSource = map.containsKey('imageSource')
            ? map['imageSource'] as String
            : 'res/Logo_basic.png',
        description = 'Lädt...',
        type = map.containsKey('type') ? map['type'] as String : '',
        connectedTo = map.containsKey('connectedTo')
            ? map['connectedTo'].cast<String>()
            : [],
        supportedBy = map.containsKey('supportedBy')
            ? map['supportedBy'].cast<String>()
            : [] {
    _loadDescription();
  }

  Future<void> _loadDescription() async {
    description =
        await _storage.getTextFromFileStorage('$_descriptionPath/$name.md');
    description ??= shortDescription;
  }

  /// creates a Species object from a database snapshot
  Species.fromSnapshot(DocumentSnapshot snapshot,
      {ServiceProvider serviceProvider})
      : this.fromMap(snapshot.data(),
            reference: snapshot.reference, serviceProvider: serviceProvider);

  /// returns a formatted string with the [BiodiversityMeasure]
  /// supporting the species
  String getSupportedBy() => _getCommaSeparatedString(supportedBy);

  /// returns a formatted string with other [Species]
  /// which go well together with this
  String getConnectedTo() => _getCommaSeparatedString(connectedTo);

  String _getCommaSeparatedString(Iterable<String> elements) {
    final string = StringBuffer();
    for (final s in elements) {
      string.write('$s, ');
    }
    final s = string.toString();
    if (s.length > 1) {
      return s.substring(0, s.length - 2);
    } else {
      return 'nichts';
    }
  }

  @override
  Map<String, Iterable<InformationObject>> get associationMap {
    final supported = <InformationObject>[];
    for (final element in supportedBy) {
      final item =
          _service.biodiversityService.getBiodiversityMeasureByName(element);
      if (item != null) supported.add(item);
    }
    final connected = <InformationObject>[];
    for (final element in connectedTo) {
      final item = _service.speciesService.getSpeciesByName(element);
      if (item != null) connected.add(item);
    }
    return {
      'Unterstützt durch die folgenden Lebensräume:': supported,
      'Verbunden mit:': connected
    };
  }
}
