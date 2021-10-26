import 'dart:async';

import 'package:biodiversity/models/biodiversity_measure.dart';
import 'package:biodiversity/models/storage_provider.dart';
import 'package:biodiversity/services/service_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

/// a service which loads all [BiodiversityMeasure] at once and stores them
class BiodiversityService extends ChangeNotifier {
  StreamSubscription _streamSubscription;
  final List<BiodiversityMeasure> _measures = [];
  final List<String> _classes = [];
  bool _initialized = false;
  final StorageProvider _storage;

  /// initializer for the service
  BiodiversityService(
      {StorageProvider storageProvider, ServiceProvider serviceProvider})
      : _storage = storageProvider ?? StorageProvider.instance {
    _streamSubscription = _storage.database
        .collection('biodiversityMeasures')
        .snapshots()
        .listen((snapshot) =>
            _updateElements(snapshot, serviceProvider: serviceProvider));
  }

  /// whether the service is ready and has fetched data from the server
  bool get isInitialized => _initialized;

  @override
  Future<void> dispose() async {
    await _streamSubscription.cancel();
    super.dispose();
  }

  void _updateElements(QuerySnapshot snapshots,
      {ServiceProvider serviceProvider}) {
    _measures.clear();
    _classes.clear();
    for (final DocumentSnapshot snapshot in snapshots.docs) {
      final element = BiodiversityMeasure.fromSnapshot(snapshot,
          storageProvider: _storage, serviceProvider: serviceProvider);
      _measures.add(element);
      if (!_classes.contains(element.type)) {
        _classes.add(element.type);
      }
    }
    notifyListeners();
    _initialized = true;
  }

  /// returns a list of [BiodiversityMeasure] which have the given type
  List<BiodiversityMeasure> getBiodiversityObjectList(String dimension) {
    return _measures
        .where((element) =>
            element.dimension.toLowerCase() == dimension.toLowerCase())
        .toList();
  }

  /// returns the complete list of [BiodiversityMeasure]
  List<BiodiversityMeasure> getFullBiodiversityObjectList() {
    return _measures.toList();
  }

  /// returns the type of a [BiodiversityMeasure] identified by the given name
  Future<String> getTypeOfObject(String name) async {
    while (!_initialized) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    final element = _measures.firstWhere((element) => element.name == name,
        orElse: () => null);
    if (element != null) {
      return element.type;
    } else {
      return 'unknown';
    }
  }

  /// returns the measure type of a [BiodiversityMeasure]
  /// identified by the given name e.g. point
  Future<String> getMeasureOfObject(String name) async {
    while (!_initialized) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    final element = _measures.firstWhere((element) => element.name == name,
        orElse: () => null);
    if (element != null) {
      return element.dimension;
    } else {
      return null;
    }
  }

  /// returns the [BiodiversityMeasure] identified by the provided reference
  BiodiversityMeasure getBiodiversityMeasureByReference(
      DocumentReference reference) {
    try {
      return _measures.where((element) => element.reference == reference).first;
    } on StateError {
      return null;
    }
  }

  /// returns the [BiodiversityMeasure] identified by the name
  BiodiversityMeasure getBiodiversityMeasureByName(String name) {
    try {
      return _measures.where((element) => element.name == name).first;
    } on StateError {
      return null;
    }
  }

  /// returns a list of all distinct classes all species are in
  List<String> getAllClasses() {
    return _classes == null ? [] : _classes.toList();
  }
}
