import 'dart:async';

import 'package:biodiversity/models/storage_provider.dart';
import 'package:biodiversity/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A service which load all users and stores them
class UserService extends ChangeNotifier {
  final List<User> _users = [];

  StreamSubscription _streamSubscription;

  StorageProvider _storage;

  /// init the service, should only be used once
  UserService({StorageProvider storageProvider}) {
    _storage = storageProvider ?? StorageProvider.instance;
    _streamSubscription = _storage.database
        .collection('users')
        .snapshots()
        .listen(_updateElements);
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }

  void _updateElements(QuerySnapshot snapshots) {
    _users.clear();
    for (final DocumentSnapshot snapshot in snapshots.docs) {
      _users.add(User.fromSnapshot(snapshot));
    }
    notifyListeners();
  }

  /// Returns a list of all registered Users
  List<User> getAllUsers() {
    return _users;
  }

  /// returns a single User referenced by the provided reference
  User getUserByReference(DocumentReference reference) {
    return _users?.where((element) => element.reference == reference)?.first;
  }
}
