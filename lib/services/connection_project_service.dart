import 'dart:async';
import 'dart:developer' as logging;

import 'package:biodiversity/models/connection_project.dart';
import 'package:biodiversity/models/storage_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A service which loads all connection projects and stores them
class ConnectionProjectService extends ChangeNotifier {
  final List<ConnectionProject> _connectionProjects = [];
  StreamSubscription _streamSubscription;
  StorageProvider _storage;

  /// init the service, should only be used once
  ConnectionProjectService({StorageProvider storageProvider}) {
    _storage = storageProvider ?? StorageProvider.instance;
    _streamSubscription = _storage.database
        .collection('connectionProjects')
        .snapshots()
        .listen(_updateElements);
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }

  void _updateElements(QuerySnapshot snapshots) {
    _connectionProjects.clear();
    for (final DocumentSnapshot snapshot in snapshots.docs) {
      _connectionProjects.add(ConnectionProject.fromSnapshot(snapshot));
    }
    notifyListeners();
  }

  ///handles the routing to MyConnectionProjectAdd, if logged in: redirects to MyConnectionProjectAdd, if not: redirect to LoginPage
  // TODO: create addConnectionProjectWidget and link in positon of MyConnectionProjectAdd
  // void handle_create_ConnectionProject(BuildContext context, {LatLng startingPosition}) {
  //   if (Provider.of<User>(context, listen: false).isLoggedIn) {
  //     Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //             builder: (context) => MyConnectionProjectAdd(
  //                   startingPosition: startingPosition,
  //                 )));
  //   } else {
  //     Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(
  //             builder: (context) => WhiteRedirectPage(
  //                 'Bitte melde Dich zuerst an', LoginPage())));
  //   }
  // }

  /// Returns a list of all registered ConnectionProjects
  List<ConnectionProject> getAllConnectionProjects() {
    return _connectionProjects;
  }

  /// returns a single ConnectionProject referenced by the provided reference
  ConnectionProject getConnectionProjectByReference(
      DocumentReference reference) {
    return _connectionProjects
        .where((element) => element.reference == reference)
        .first;
  }

  ///function to delete the ConnectionProject from an user
  Future<void> deleteConnectionProject(
      ConnectionProject connectionProject) async {
    if (connectionProject.reference != null) {
      _storage.database.doc(connectionProject.reference.path).delete();
    }
    logging.log('Deleted ConnectionProject' + connectionProject.title);
    _connectionProjects.remove(ConnectionProject);
  }
}
