import 'dart:convert';
import 'dart:developer' as logging;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// A class which provides a single place where external Storage is accessed
class StorageProvider {
  StorageProvider._privateConstructor();

  static final _instance = StorageProvider._privateConstructor();
  static final _fileStorage = FirebaseStorage.instance;
  static final _database = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;
  static final _googleSignIn = GoogleSignIn();
  static final _facebookAuth = FacebookAuth.instance;
  static final _googleAuthProvider = GoogleAuthProvider();

  /// Instance of the StorageProvider
  static final StorageProvider instance = _instance;

  /// Reference to the file-storage instance
  final FirebaseStorage fileStorage = _fileStorage;

  /// Reference to the database instance
  final FirebaseFirestore database = _database;

  /// Reference to the authentication service instance
  final FirebaseAuth auth = _auth;

  /// Reference to the google sign in provider
  final GoogleSignIn googleSignIn = _googleSignIn;

  /// Reference to the facebook oAuth provider
  final FacebookAuth facebookAuth = _facebookAuth;

  /// Reference to the google oAuth provider
  final GoogleAuthProvider googleAuthProvider = _googleAuthProvider;

  /// returns the content of a file from the fileStorage as String
  Future<String> getTextFromFileStorage(String path) async {
    try {
      final parent = await fileStorage.ref().child(path).parent.listAll();
      if (parent.items.map((e) => e.fullPath).contains(path)) {
        final data = await fileStorage.ref().child(path).getData(1024 * 1024);
        return data != null ? const Utf8Decoder().convert(data) : null;
      } else {
        logging.log('No element found at address $path');
        return null;
      }
    } catch (e) {
      logging.log('Something went wrong on text loading from storage.'
          '\nError: $e');
      return null;
    }
  }
}
