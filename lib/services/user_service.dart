import 'dart:async';

import 'package:biodiversity/models/storage_provider.dart';
import 'package:biodiversity/models/user.dart';
import 'package:biodiversity/services/service_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A service which loads all [User] at once and stores them.
class UserService extends ChangeNotifier {
  final List<User> _users = [];

  StreamSubscription _streamSubscription;

  StorageProvider _storage;

  /// Initializes the service [UserService].
  ///
  /// Should only be used once.
  UserService({StorageProvider storageProvider}) {
    _storage = storageProvider ?? StorageProvider.instance;
    _streamSubscription = _storage.database
        .collection('users')
        .snapshots()
        .listen(_updateElements);
  }

  /// Gets called when object is removed from the widget tree permanently.
  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }

  /// Updates all [User].
  void _updateElements(QuerySnapshot snapshots) {
    _users.clear();
    for (final DocumentSnapshot snapshot in snapshots.docs) {
      _users.add(User.fromSnapshot(snapshot));
    }
    notifyListeners();
  }

  /// Returns a list of all registered [User].
  List<User> getAllUsers() {
    return _users;
  }

  /// Returns a single [User] referenced by the provided [reference].
  User getUserByReference(DocumentReference reference) {
    return _users?.where((element) => element.reference == reference)?.first;
  }

  /// Returns a single [User] referenced by the provided [reference] (uuid).
  User getUserByUuid(DocumentReference reference) {
    return _users?.where((element) => element.reference == reference)?.first;
  }

  /// Deletes a [User] referenced by that [user].
  Future<void> deleteUserAccount(User user) async {
    if (user.reference != null) {
      if (user.imageURL != null && user.imageURL.isNotEmpty) {
        ServiceProvider.instance.imageService
            .deleteImage(imageURL: user.imageURL);
      }
      await _storage.database.runTransaction((Transaction myTransaction) async {
        myTransaction.delete(user.reference);
      });
      _users.remove(user);
    }
  }
}
