import 'dart:async';

import 'package:biodiversity/models/garden.dart';
import 'package:biodiversity/models/storage_provider.dart';
import 'package:biodiversity/services/service_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// a service which loads and stores all map markers
class MapMarkerService extends ChangeNotifier {
  final Map<String, BitmapDescriptor> _icons = <String, BitmapDescriptor>{};
  final List<Garden> _markers = [];
  bool _initialized = false;
  final StorageProvider _storage;
  StreamSubscription _streamSubscription;

  ///init of the service, should only be used once
  MapMarkerService({StorageProvider storageProvider})
      : _storage = storageProvider ?? StorageProvider.instance {
    _streamSubscription = _storage.database
        .collection('gardens')
        .snapshots()
        .listen(_updateElements);
    _loadIcons();
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }

  void _updateElements(QuerySnapshot snapshots) {
    _markers.clear();
    _markers.addAll(ServiceProvider.instance.gardenService.getAllGardens());
    _initialized = true;
    notifyListeners();
  }

   Future<void> _loadIcons(BitmapDescriptor joinableGarden) async {
    //TODO: add images for linking project
    BitmapDescriptor gardenIcon;

    if(defaultTargetPlatform == TargetPlatform.iOS){
      gardenIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(),
        'res/gardenIcon.png',
      );
    }else{
      if(joinableGarden == gardenIcon){
      gardenIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(),
        'res/2.0x/gardenIcon.png',
      );
      } else{
        // Todo create new Icon
        joinableGarden = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), 'res/plantIcon.png', );
      }
    }

    _icons.putIfAbsent('garden', () => gardenIcon);
    _icons.putIfAbsent('joinableGarden', () => joinableGarden);
  }

  void setMarker(){

  }

  /// returns a set of all markers
  Future<Set<Marker>> getMarkerSet(String icon, {Function(Garden element) onTapCallback}) async {
    while (!_initialized) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    final list = <Marker>{};
    for (final object in _markers){
      list.add(Marker(
        markerId: MarkerId(
            object.getLatLng().toString() + object.creationDate.toString()),
        position: object.getLatLng(),
        icon: _icons[icon],
        onTap: () {
          onTapCallback(object);
        },
        )
      );
    }
    return list;
  }
}
