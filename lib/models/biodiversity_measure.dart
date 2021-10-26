import 'package:biodiversity/models/information_object.dart';
import 'package:biodiversity/models/storage_provider.dart';
import 'package:biodiversity/services/service_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// A container class of a Measure to improve biodiversity.
/// Example: A pile of branches
class BiodiversityMeasure implements InformationObject {
  @override
  final String name;

  @override
  String description;

  @override
  String shortDescription;

  @override
  final String type;

  @override
  String get category => type;

  @override
  String get additionalInfo => null;

  /// in which unit this Biodiversity element is measured e.g. point
  final String dimension;

  /// A list with all Species this BiodiversityMeasure is good for
  List<String> beneficialFor;

  /// All other measures which work well together with this measure
  List<String> goodTogetherWith;

  /// a reference to the image
  final String imageSource;

  /// the reference to the location in the database
  final DocumentReference reference;

  final _descriptionPath = 'biodiversityMeasures/description';
  final StorageProvider _storage;
  final ServiceProvider _service;

  /// creates a [BiodiversityMeasure] from the provided map
  /// used to load elements from the database and for testing
  BiodiversityMeasure.fromMap(Map<String, dynamic> map,
      {this.reference,
      StorageProvider storageProvider,
      ServiceProvider serviceProvider})
      : _storage = storageProvider ?? StorageProvider.instance,
        _service = serviceProvider ?? ServiceProvider.instance,
        name = map.containsKey('name') ? map['name'] as String : '',
        shortDescription = map.containsKey('shortDescription')
            ? map['shortDescription'] as String
            : '',
        beneficialFor =
            map.containsKey('beneficialFor') && map['beneficialFor'] is List
                ? map['beneficialFor'].cast<String>()
                : [],
        goodTogetherWith = map.containsKey('goodTogetherWith') &&
                map['goodTogetherWith'] is List
            ? map['goodTogetherWith'].cast<String>()
            : [],
        type = map.containsKey('type') ? map['type'] as String : '',
        imageSource = map.containsKey('image')
            ? map['image'] as String
            : 'res/Logo_basic.png',
        dimension =
            map.containsKey('dimension') ? map['dimension'] as String : '',
        description = 'Lädt...' {
    _loadDescription();
  }

  Future<void> _loadDescription() async {
    description =
        await _storage.getTextFromFileStorage('$_descriptionPath/$name.md');
    description ??= shortDescription;
  }

  /// load a [BiodiversityMeasure] form a database snapshot
  BiodiversityMeasure.fromSnapshot(DocumentSnapshot snapshot,
      {StorageProvider storageProvider, ServiceProvider serviceProvider})
      : this.fromMap(snapshot.data(),
            reference: snapshot.reference,
            storageProvider: storageProvider,
            serviceProvider: serviceProvider);

  @override
  Map<String, Iterable<InformationObject>> get associationMap {
    final beneficialObjects = <InformationObject>[];
    for (final item in beneficialFor) {
      final species = _service.speciesService.getSpeciesByName(item);
      if (species != null) beneficialObjects.add(species);
    }
    final goodTogetherObjects = <InformationObject>[];
    for (final item in goodTogetherWith) {
      final object =
          _service.biodiversityService.getBiodiversityMeasureByName(item);
      if (object != null) goodTogetherObjects.add(object);
    }
    return {
      'Gut für die folgenden Tiere:': beneficialObjects,
      'Gut zusammen mit:': goodTogetherObjects
    };
  }
}
