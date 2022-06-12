import 'dart:async';

import 'package:biodiversity/models/species.dart';
import 'package:biodiversity/models/storage_provider.dart';
import 'package:biodiversity/services/service_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

/// service for species data
class SpeciesService extends ChangeNotifier {
  final List<Species> _species = [];
  final List<String> _classes = [];
  StreamSubscription _streamSubscription;
  bool _initialized = false;
  final StorageProvider _storage;

  /// init the service, should only be used once
  SpeciesService(
      {StorageProvider storageProvider, ServiceProvider serviceProvider})
      : _storage = storageProvider ?? StorageProvider.instance {
    _streamSubscription = _storage.database
        .collection('species')
        .snapshots()
        .listen((snapshot) =>
            _updateElements(snapshot, serviceProvider: serviceProvider));
  }

  /// discard (free up) resources
  @override
  Future<void> dispose() async {
    await _streamSubscription.cancel();
    super.dispose();
  }

  /// updates local data from database and notifies listeners
  void _updateElements(QuerySnapshot snapshots,
      {ServiceProvider serviceProvider}) {
    _species.clear();
    for (final DocumentSnapshot snapshot in snapshots.docs) {
      _species.add(
          Species.fromSnapshot(snapshot, serviceProvider: serviceProvider));
    }
    notifyListeners();
    _initialized = true;
  }

  /// returns all species  associated with the given type
  List<Species> getSpeciesObjectList(String type) {
    return _species
        .where((element) => element.type.toLowerCase() == type.toLowerCase())
        .toList();
  }

  /// returns all Species from local data as list
  List<Species> getFullSpeciesObjectList() {
    return _species.toList();
  }

  /// lookup, returns the type of a given species
  Future<String> getTypeOfObject(String name) async {
    while (!_initialized) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    final element = _species.firstWhere((element) => element.name == name,
        orElse: () => null);
    if (element != null) {
      return element.type;
    } else {
      return 'unknown';
    }
  }

  /// returns a single Species referenced by the provided reference
  Species getSpeciesByReference(DocumentReference reference) {
    return _species.where((element) => element.reference == reference).first;
  }

  /// returns a single Species referenced by the provided reference
  Species getSpeciesByName(String name) {
    try {
      return _species.where((element) => element.name == name).first;
    } on StateError {
      return null;
    }
  }

  /// returns a list of all distinct classes all species are in
  List<String> getAllClasses() {
    if (_classes.isNotEmpty) {
      return _classes.toList();
    }
    for (final s in _species) {
      if (!_classes.contains(s.type)) {
        _classes.add(s.type);
      }
    }
    return _classes.toList();
  }
}
