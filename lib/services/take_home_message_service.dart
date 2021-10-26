import 'dart:async';

import 'package:biodiversity/models/storage_provider.dart';
import 'package:biodiversity/models/take_home_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

/// a service which loads all [TakeHomeMessage] at once and stores them
class TakeHomeMessageService extends ChangeNotifier {
  StreamSubscription _streamSubscription;
  final List<TakeHomeMessage> _messages = [];
  final StorageProvider _storage;

  /// initializer for the service
  TakeHomeMessageService({StorageProvider storageProvider})
      : _storage = storageProvider ?? StorageProvider.instance {
    _streamSubscription = _storage.database
        .collection('takeHomeMessages')
        .snapshots()
        .listen(_updateElements);
  }

  @override
  Future<void> dispose() async {
    await _streamSubscription.cancel();
    super.dispose();
  }

  void _updateElements(QuerySnapshot snapshots) {
    _messages.clear();
    for (final DocumentSnapshot snapshot in snapshots.docs) {
      _messages.add(TakeHomeMessage.fromSnapshot(snapshot));
    }
    notifyListeners();
  }

  /// returns the complete list of [TakeHomeMessage]
  List<TakeHomeMessage> getFullTakeHomeMessageObjectList() {
    return _messages.toList();
  }
}
