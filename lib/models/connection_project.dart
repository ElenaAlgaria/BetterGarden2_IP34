import 'dart:core';
import 'dart:developer' as logging;

import 'package:biodiversity/models/storage_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

// TODO update coordinates of a connectionProject
// TODO and implement the logic.
/// Container class for the connection project
class ConnectionProject extends ChangeNotifier {
  /// title of the connection project
  String title;

  String description;

  DocumentReference targetSpecies;

  /// the time and date the object was created
  DateTime creationDate;

  List<DocumentReference> gardens;

  /// reference where the object is stored in the database
  DocumentReference reference;

  bool _isEmpty;

  final StorageProvider _storage;

  /// creates an empty conectionproject as placeholder
  ConnectionProject.empty({StorageProvider storageProvider})
      : _storage = storageProvider ??= StorageProvider.instance {
    title = '';
    description = '';
    targetSpecies = null;
    creationDate = DateTime.now();
    gardens = [];
    _isEmpty = true;
  }

  /// creates a ConnectionProject from the provided Map.
  /// Used for database loading and testing
  ConnectionProject.fromMap(Map<String, dynamic> map,
      {this.reference, StorageProvider storageProvider})
      : _storage = storageProvider ??= StorageProvider.instance,
        title = map.containsKey('title')
            ? map['title'] as String
            : '',
        description =
            map.containsKey('description')
                ? map['description'] as String
                : '',
        targetSpecies = map.containsKey('targetSpecies')
            ? map['targetSpecies'] as DocumentReference
            : '',
        creationDate = map.containsKey('creationDate')
            ? (map['creationDate'] as Timestamp).toDate()
            : DateTime.now(),
        gardens = map.containsKey('gardens')
            ? List<DocumentReference>.from(map['gardens'] as Iterable)
            : [],
        _isEmpty = false;

  /// loads a connectionproject from a database snapshot
  ConnectionProject.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data(), reference: snapshot.reference);

  /// saves the connectionproject object to the database
  /// any information already present on the database will be overridden
  Future<void> saveConnectionProject() async {
    logging.log('Save ConnectionProject $title');
    if (_isEmpty || reference == null) {
      reference =
          _storage.database.doc('connectionProjects/${const Uuid().v4()}');
      _isEmpty = false;
    }
    final path = reference.path;
    await _storage.database.doc(path).set({
      'title': title,
      'description': description,
      'targetSpecies': targetSpecies,
      'creationDate': creationDate,
      'gardens': gardens
    });
  }

  /// function to load the details of another conectionproject
  void switchConnectionProject(ConnectionProject connectionProject) {
    title = connectionProject.title;
    description = connectionProject.description;
    targetSpecies = connectionProject.targetSpecies;
    gardens.clear();
    gardens.addAll(connectionProject.gardens);
    creationDate = connectionProject.creationDate;
    reference = connectionProject.reference;
    _isEmpty = connectionProject._isEmpty;
    notifyListeners();
  }

  /// add a garden to the connectionProject
  /// and saves the connectionProject to the database
  void addGarden(DocumentReference garden) {
    if (garden != null && !gardens.contains(garden)) {
      gardens.add(garden);
      saveConnectionProject();
    }
  }

  /// removes a element from the connectionProject, changes are saved automatically
  void removeGarden(DocumentReference garden) {
    if (gardens.contains(garden)) {
      gardens.remove(garden);
      saveConnectionProject();
    }
  }

  /// is true if this connectionproject is an empty placeholder
  bool get isEmpty => _isEmpty;

  Future<void> deleteConnectionProject(
      DocumentReference connectionProjectReference) async {
    logging.log('Delete ConnectionProject $title');
    final path = '/' + connectionProjectReference.path;
    debugPrint(path.toString());
    await _storage.database.doc(path).delete();
  }
}
