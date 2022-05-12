import 'dart:async';
import 'dart:developer' as logging;
import 'dart:math';

import 'package:biodiversity/models/connection_project.dart';
import 'package:biodiversity/models/garden.dart';
import 'package:biodiversity/models/storage_provider.dart';
import 'package:biodiversity/services/service_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// a service which loads and stores all map markers
class MapMarkerService extends ChangeNotifier {
  final Map<String, BitmapDescriptor> _icons = <String, BitmapDescriptor>{};
  bool _initialized = false;

  ///init of the service, should only be used once
  MapMarkerService({StorageProvider storageProvider}) {
    _loadIcons();
    updateElements();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void updateElements() {
    _initialized = true;
    notifyListeners();
  }

  Future<void> _loadIcons() async {
    BitmapDescriptor gardenIcon;
    BitmapDescriptor connectionProjectIcon;
    BitmapDescriptor joinableGardenIcon;

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      gardenIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(),
        'res/gardenIcon.png',
      );
      connectionProjectIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(),
        // TODO: change to correct icon
        'res/methodIcon.png',
      );
      joinableGardenIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(),
        'res/2.0x/joinableGardenIcon.png',
      );
    } else {
      gardenIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(),
        'res/2.0x/gardenIcon.png',
      );
    }
    connectionProjectIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      'res/2.0x/methodIcon.png',
    );

    joinableGardenIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      'res/2.0x/joinableGardenIcon.png',
    );

    _icons.putIfAbsent('garden', () => gardenIcon);
    _icons.putIfAbsent('connectionProject', () => connectionProjectIcon);
    _icons.putIfAbsent('joinableGarden', () => joinableGardenIcon);
  }

  void setMarker() {}

  /// returns a set of all markers
  Future<Marker> getGardenMarkerSet(Garden garden,
      {Function(Garden element) onTapCallback}) async {
    var marker = (Marker(
      markerId: MarkerId('garden' + garden.reference.id),
      position: garden.getLatLng(),
      icon: _icons['garden'],
      onTap: () {
        onTapCallback(garden);
      },
    ));

    return marker;
  }

  Future<Marker> getJoinableMarker(Garden garden,
      {Function(Garden element) onTapCallback}) async {
    while (!_initialized) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    var marker = Marker(
      markerId: MarkerId('joinableGarden' + garden.reference.id.toString()),
      position:
          LatLng(garden.getLatLng().latitude, garden.getLatLng().longitude),
      icon: _icons['joinableGarden'],
      onTap: () {
        onTapCallback(garden);
      },
    );
    return marker;
  }

  /// returns a set of all ConnectionProjectMarkers
  Set<Marker> getConnectionProjectMarkerSet(
      {Function(ConnectionProject element) onTapCallback}) {
    final list = <Marker>{};
    final latLngList = <LatLng>{};
    ServiceProvider.instance.connectionProjectService
        .getAllConnectionProjects()
        .forEach((project) {
      var allGardenCoordinates = project.gardens.map((e) => ServiceProvider
          .instance.gardenService
          .getGardenByReference(e)
          .coordinates);

      var midLat;
      var midLng;

      if (allGardenCoordinates.length > 1) {
        var maxLat = allGardenCoordinates.map((e) => e.latitude).reduce(max);
        var minLat = allGardenCoordinates.map((e) => e.latitude).reduce(min);
        var maxLng = allGardenCoordinates.map((e) => e.longitude).reduce(max);
        var minLng = allGardenCoordinates.map((e) => e.longitude).reduce(min);
        midLat = (maxLat + minLat) / 2;
        midLng = (maxLng + minLng) / 2;
        //latLngList.add(LatLng(midLat, midLng));
      } else if (allGardenCoordinates.length == 1) {
        midLat = allGardenCoordinates.elementAt(0).latitude - 0.0002;
        midLng = allGardenCoordinates.elementAt(0).longitude - 0.0002;
      } else {
        logging.log("ConnectionProject without gardens in service detected: " +
            project.title);
      }

      while (latLngList.contains(LatLng(midLat, midLng))) {
        midLat -= 0.00005;
        midLng -= 0.00005;
      }

      latLngList.add(LatLng(midLat, midLng));

      // logging.log('Create connection project marker at ' +
      //     midLat.toString() +
      //     '/' +
      //     midLng.toString() +
      //     '/' +
      //     project.creationDate.toString() +
      //     '/' +
      //     project.gardens.length.toString());
      
      list.add(Marker(
        markerId: MarkerId(midLat.toString() +
            midLng.toString() +
            project.creationDate.toString()),
        position: LatLng(midLat, midLng),
        icon: _icons['connectionProject'],
        onTap: () {
          onTapCallback(project);
        },
      ));
    });
    logging.log('Created connection project markers');
    return list;
  }
}
