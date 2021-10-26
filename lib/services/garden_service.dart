import 'dart:async';

import 'package:biodiversity/components/white_redirect_page.dart';
import 'package:biodiversity/models/biodiversity_measure.dart';
import 'package:biodiversity/models/garden.dart';
import 'package:biodiversity/models/storage_provider.dart';
import 'package:biodiversity/models/user.dart';
import 'package:biodiversity/screens/login_page/login_page.dart';
import 'package:biodiversity/screens/my_garden_page/my_garden_add.dart';
import 'package:biodiversity/services/service_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

/// A service which loads all gardens and stores them
class GardenService extends ChangeNotifier {
  final List<Garden> _gardens = [];
  StreamSubscription _streamSubscription;
  StorageProvider _storage;

  /// init the service, should only be used once
  GardenService({StorageProvider storageProvider}) {
    _storage = storageProvider ?? StorageProvider.instance;
    _streamSubscription = _storage.database
        .collection('gardens')
        .snapshots()
        .listen(_updateElements);
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }

  void _updateElements(QuerySnapshot snapshots) {
    _gardens.clear();
    for (final DocumentSnapshot snapshot in snapshots.docs) {
      _gardens.add(Garden.fromSnapshot(snapshot));
    }
    notifyListeners();
  }

  ///handles the routing to MyGardenAdd, if logged in: redirects to MyGardenAdd, if not: redirect to LoginPage
  void handle_create_garden(BuildContext context, {LatLng startingPosition}) {
    if (Provider.of<User>(context, listen: false).isLoggedIn) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MyGardenAdd(
                    startingPosition: startingPosition,
                  )));
    } else {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => WhiteRedirectPage(
                  'Bitte melde Dich zuerst an', LoginPage())));
    }
  }

  /// Returns a list of Gardens which the provided User has
  List<Garden> getAllGardensFromUser(User user) {
    return _gardens.where((garden) => garden.owner == user.userUUID).toList();
  }

  ///Delete all gardens from the user when the account is being deleted
  void deleteAllGardensFromUser(User user) {
    final gardens = [];

    gardens.addAll(_gardens.where((garden) => garden.owner == user.userUUID));
    gardens.forEach((element) {
      deleteGarden(element);
    });
  }

  /// Returns a list of all registered Gardens
  List<Garden> getAllGardens() {
    return _gardens;
  }

  ///Returns all elements inside the users active garden
  List<BiodiversityMeasure> getAllBiodiversityMeasuresFromGarden(
      Garden garden) {
    final result = <BiodiversityMeasure>[];
    for (final item in garden.ownedObjects.keys) {
      result.add(ServiceProvider.instance.biodiversityService
          .getBiodiversityMeasureByName(item));
    }
    return result;
  }

  /// returns a single Garden referenced by the provided reference
  Garden getGardenByReference(DocumentReference reference) {
    return _gardens.where((element) => element.reference == reference).first;
  }

  /// returns the nickname of the garden owner if showGardenOnMap is set to true for this user
  Future<String> getNicknameOfOwner(Garden garden) async {
    final doc = await _storage.database.doc('users/${garden.owner}').get();
    if (doc != null && doc.exists) {
      final data = doc.data();
      if (data.containsKey('showNameOnMap') && data.containsKey('nickname')) {
        final showName = data['showNameOnMap'] as bool;
        return showName ? doc.data()['nickname'] : 'Anonym';
      }
    }
    return 'Anonym';
  }

  ///function to delete the garden from an user
  Future<void> deleteGarden(Garden garden) async {
    if (garden.reference != null) {
      if (garden.imageURL != null && garden.imageURL.isNotEmpty) {
        ServiceProvider.instance.imageService
            .deleteImage(imageURL: garden.imageURL);
      }
      _storage.database.doc(garden.reference.path).delete();
    }
    _gardens.remove(garden);
  }
}
