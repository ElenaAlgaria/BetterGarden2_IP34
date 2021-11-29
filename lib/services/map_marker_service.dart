import 'dart:async';

import 'package:biodiversity/models/connection_project.dart';
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
  final List<Garden> _gardens = [];
  final List<ConnectionProject> _connectionProjects = [];
  bool _initialized = false;
  final StorageProvider _storage;
  StreamSubscription _gardenStreamSubscription;

  ///init of the service, should only be used once
  MapMarkerService({StorageProvider storageProvider})
      : _storage = storageProvider ?? StorageProvider.instance {
    _gardenStreamSubscription = _storage.database
        .collectionGroup('gardens')
        .snapshots()
        .listen(_updateElements);
    _loadIcons();
  }

  @override
  void dispose() {
    _gardenStreamSubscription.cancel();
    super.dispose();
  }

  void _updateElements(QuerySnapshot snapshots) {
    _gardens.clear();
    _gardens.addAll(ServiceProvider.instance.gardenService.getAllGardens());
    _connectionProjects.clear();
    _connectionProjects.addAll(ServiceProvider.instance.connectionProjectService
        .getAllConnectionProjects());
    _initialized = true;
    notifyListeners();
  }

  Future<void> _loadIcons() async {
    //TODO: add images for linking project
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
  Future<Set<Marker>> getGardenMarkerSet(
      {Function(Garden element) onTapCallback}) async {
    while (!_initialized) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    final list = <Marker>{};
    for (final object in _gardens) {
      list.add(Marker(
        markerId: MarkerId(
            object.getLatLng().toString() + object.creationDate.toString()),
        position: object.getLatLng(),
        icon: _icons['garden'],
        onTap: () {
          onTapCallback(object);
        },
      ));
    }

    return list;
  }

  Future<Marker> getJoinableMarkerSet(Garden garden,
      {Function(Garden element) onTapCallback}) async {
    while (!_initialized) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    var marker = Marker(
      markerId: MarkerId(garden.getLatLng().toString() + garden.toString()),
      position: garden.getLatLng(),
      icon: _icons['joinableGarden'],
      onTap: () {
        onTapCallback(garden);
      },
    );
    return marker;
  }

  /// returns a set of all markers
  Future<Set<Marker>> getConnectionProjectMarkerSet(
      {Function(ConnectionProject element) onTapCallback}) async {
    while (!_initialized) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    final list = <Marker>{};
    for (final object in _connectionProjects) {
      // TODO: implement getting center of project with multiple gardens
      var projectLatLng = ServiceProvider.instance.gardenService
          .getGardenByReference(object.gardens?.first)
          ?.getLatLng();
      debugPrint(object.creationDate.toString() +
          '/' +
          object.gardens.length.toString());
      list.add(Marker(
        markerId:
            MarkerId(projectLatLng.toString() + object.creationDate.toString()),
        position: LatLng(projectLatLng.latitude - 0.0003, projectLatLng.longitude),
        icon: _icons['connectionProject'],
        onTap: () {
          onTapCallback(object);
        },
      ));
    }
    return list;
  }
}
