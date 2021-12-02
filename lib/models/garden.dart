import 'dart:core';
import 'dart:developer' as logging;

import 'package:biodiversity/models/biodiversity_measure.dart';
import 'package:biodiversity/models/storage_provider.dart';
import 'package:biodiversity/models/user.dart';
import 'package:biodiversity/services/service_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

/// Container class for the garden
class Garden extends ChangeNotifier {
  /// nickname of the garden
  String name;

  /// street and house number of the address of the garden
  String street;

  /// Type of garden
  String gardenType;

  /// the coordinates as [GeoPoint] of the Address
  GeoPoint coordinates;

  /// the time and date the object was created
  DateTime creationDate;

  /// reference where the object is stored in the database
  DocumentReference reference;

  /// which [BiodiversityMeasure] are contained in this garden
  Map<String, int> ownedObjects;

  /// reference to the associated User
  String owner;

  ///image URL for the image of the garden
  String imageURL;

  bool _isEmpty;

  final StorageProvider _storage;

  /// creates an empty garden as placeholder
  Garden.empty({StorageProvider storageProvider})
      : _storage = storageProvider ??= StorageProvider.instance {
    name = '';
    street = '';
    owner = '';
    gardenType = '';
    gardenType = '';
    ownedObjects = {};
    coordinates = const GeoPoint(0, 0);
    creationDate = DateTime.now();
    _isEmpty = true;
    imageURL = '';
  }

  /// loads the first garden of a user if one is present
  void loadGardenFromUser(User user) {
    if (!user.isLoggedIn || user.gardens.isEmpty) {
      return;
    }
    final gardens =
        ServiceProvider.instance.gardenService.getAllGardensFromUser(user);
    if (gardens.isNotEmpty) {
      logging
          .log('load garden ${gardens.first.name} from user ${user.nickname}');
      switchGarden(gardens.first);
    }
  }

  /// creates a Garden from the provided Map.
  /// Used for database loading and testing
  Garden.fromMap(Map<String, dynamic> map,
      {this.reference, StorageProvider storageProvider})
      : _storage = storageProvider ??= StorageProvider.instance,
        name = map.containsKey('name') ? map['name'] as String : '',
        street = map.containsKey('street') ? map['street'] as String : '',
        owner = map.containsKey('owner') ? map['owner'] as String : '',
        gardenType =
            map.containsKey('gardenType') ? map['gardenType'] as String : '',
        ownedObjects = map.containsKey('ownedObjects')
            ? Map<String, int>.from(map['ownedObjects'] as Map)
            : {},
        coordinates = map.containsKey('coordinates')
            ? (map['coordinates'] as GeoPoint)
            : const GeoPoint(0, 0),
        creationDate = map.containsKey('creationDate')
            ? (map['creationDate'] as Timestamp).toDate()
            : DateTime.now(),
        imageURL = map.containsKey('imageURL') ? map['imageURL'] as String : '',
        _isEmpty = false;

  /// loads a garden form a database snapshot
  Garden.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data(), reference: snapshot.reference);

  /// saves the garden object to the database
  /// any information already present on the database will be overridden
  Future<void> saveGarden() async {
    logging.log('Save garden $name');
    if (_isEmpty || reference == null) {
      reference = _storage.database.doc('gardens/${const Uuid().v4()}');
      _isEmpty = false;
    }
    final path = reference.path;
    await _storage.database.doc(path).set({
      'owner': owner,
      'name': name,
      'street': street,
      'gardenType': gardenType,
      'ownedObjects': ownedObjects,
      'coordinates': coordinates,
      'creationDate': creationDate,
      'imageURL': imageURL,
    });
  }

  /// function to load the details of another garden
  void switchGarden(Garden garden) {
    name = garden.name;
    street = garden.street;
    owner = garden.owner;
    ownedObjects.clear();
    ownedObjects.addAll(garden.ownedObjects);
    coordinates = garden.coordinates;
    gardenType = garden.gardenType;
    creationDate = garden.creationDate;
    reference = garden.reference;
    _isEmpty = garden._isEmpty;
    imageURL = garden.imageURL;
    notifyListeners();
  }

  /// adds an element with to a garden with the specified count
  /// and saves the garden to the database
  void addOwnedObject(String object, int count, {bool overrideAmount = false}) {
    if (object != null && object.isNotEmpty && count > 0) {
      if (!overrideAmount && ownedObjects.containsKey(object)) {
        ownedObjects[object] += count;
      } else {
        ownedObjects[object] = count;
      }
      saveGarden();
    } else {
      logging.log("can't add object $object with count $count");
    }
  }

  /// removes a element from the garden, changes are saved automatically
  void removeFromOwnedObjects(String object) {
    if (ownedObjects.containsKey(object)) {
      ownedObjects.remove(object);
      saveGarden();
    }
  }

  /// returns a [LatLng] object of the coordinates. Used for google Maps
  LatLng getLatLng() {
    return LatLng(coordinates.latitude, coordinates.longitude);
  }

  /// returns the nickname of the garden owner if showGardenOnMap is set to true for this user
  Future<bool> isShowImageOnGarden() async {
    final doc = await _storage.database.doc('users/$owner').get();
    if (doc != null && doc.exists) {
      final data = doc.data();
      if (data.containsKey('showGardenImageOnMap')) {
        final showImage = data['showGardenImageOnMap'] as bool;
        return showImage ? doc.data()['showGardenImageOnMap'] : false;
      }
    }
    return false;
  }

  int _countOwnedObjects(String dimension) {
    return ServiceProvider.instance.biodiversityService
        .getBiodiversityObjectList(dimension)
        .where((e) => ownedObjects.keys.contains(e.name))
        .fold(0, (value, element) => value += ownedObjects[element.name]);
  }

  int _countSupportedSpeciesObjects() {
    return ServiceProvider.instance.biodiversityService
        .getFullBiodiversityObjectList()
        .where((e) => ownedObjects.keys.contains(e.name))
        .expand((element) => element.beneficialFor)
        .toSet()
        .length;
  }

  bool isInRange(Garden g1, Garden g2, int radius) {
    var distance = Geolocator.distanceBetween(
      g1.getLatLng().latitude,
      g1.getLatLng().longitude,
      g2.getLatLng().latitude,
      g2.getLatLng().longitude,
    );
    return distance <= radius * 2 && distance != 0.0;
  }

  /// count of area objects
  int get totalAreaObjects => _countOwnedObjects('Fläche');

  /// count of point objects
  int get totalPointObjects => _countOwnedObjects('Punkt');

  /// count of point objects
  int get totalLengthObjects => _countOwnedObjects('Linie');

  /// count of point objects
  int get totalSupportedSpecies => _countSupportedSpeciesObjects();

  /// is true if this garden is an empty placeholder
  bool get isEmpty => _isEmpty;
}
