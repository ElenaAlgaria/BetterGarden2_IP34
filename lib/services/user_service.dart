/*import 'dart:async';

import 'package:biodiversity/models/storage_provider.dart';
import 'package:biodiversity/models/user.dart';
import 'package:biodiversity/services/service_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:biodiversity/services/service_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';


/// A service which load all users and stores them
class UserService extends ChangeNotifier {
  final List<User> _users = [];
*//*  final List<String> _classes = [];*//*
  StreamSubscription _streamSubscription;
*//*  bool _initialized = false;*//*
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
  }

}*/
