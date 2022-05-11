import 'dart:async';
import 'dart:developer' as logging;
import 'dart:io';
import 'dart:typed_data';

import 'package:biodiversity/models/storage_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

/// Service which holds the image urls and copyright information
/// This helps to reduce loading times
class ImageService extends ChangeNotifier {
  StreamSubscription _streamSubscription;
  final Map<String, String> _urls = <String, String>{};
  final Map<String, String> _copyrightInfo = <String, String>{};
  final Map<String, String> _caption = <String, String>{};
  final StorageProvider _storage;

  /// Service which holds the image urls and copyright information
  ImageService({StorageProvider storageProvider})
      : _storage = storageProvider ?? StorageProvider.instance {
    _streamSubscription = _storage.database
        .collection('imageReferences')
        .snapshots()
        .listen((change) {
      for (final doc in change.docs) {
        if (doc.data().containsKey('downloadURL')) {
          _urls[doc.reference.id] = doc.data()['downloadURL'];
        }
        if (doc.data().containsKey('copyright')) {
          _copyrightInfo[doc.reference.id] = doc.data()['copyright'];
        }
        if (doc.data().containsKey('caption')) {
          _caption[doc.reference.id] = doc.data()['caption'];
        }
      }
    });
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }

  /// defines how the reference on the database is named
  String _key(String name, {int imageNr}) {
    name = name.toLowerCase().trim();
    if (imageNr != null) return '$name-$imageNr';
    return '$name-1';
  }

  /// Returns an image which is loaded dynamically from the database/firestore
  Widget getImage(String name, String type,
      {int imageNr,
      double width = double.infinity,
      double height,
      BoxFit fit = BoxFit.fitWidth,
      Widget errorWidget,
      bool displayCopyrightInfo = false,
      AlignmentGeometry copyrightAlignment = AlignmentDirectional.bottomEnd}) {
    final key = _key(name, imageNr: imageNr);

    Widget _getImage(String url) {
      return CachedNetworkImage(
        width: width,
        height: height,
        fit: fit,
        imageUrl: url,
        errorWidget: (context, str, err) =>
            errorWidget ?? getImage('default-1', 'error'),
      );
    }

    Widget _getImageWithCopyright(String url, String copyright) {
      return Stack(
        alignment: copyrightAlignment,
        children: [
          _getImage(_urls[key]),
          Padding(
            padding: const EdgeInsets.all(4),
            child: Text(copyright),
          )
        ],
      );
    }

    //shortcut loading to prevent the appearance of circularProgressIndicator
    if (_urls.containsKey(key)) {
      if (!displayCopyrightInfo) {
        return _getImage(_urls[key]);
      } else if (_copyrightInfo.containsKey(key)) {
        return _getImageWithCopyright(_urls[key], _copyrightInfo[key]);
      }
    }

    return FutureBuilder(
      future: getImageURL(name, type, imageNr: imageNr),
      builder: (context, url) {
        if (url.connectionState == ConnectionState.done &&
            !url.hasError &&
            url.data != null) {
          if (displayCopyrightInfo) {
            return FutureBuilder(
                future: getImageCopyright(name),
                builder: (context, copyright) {
                  if (copyright.connectionState == ConnectionState.done &&
                      !copyright.hasError) {
                    return _getImageWithCopyright(url.data, copyright.data);
                  } else {
                    return Container(
                      width: width,
                      height: height,
                      child: const CircularProgressIndicator(),
                    );
                  }
                });
          } else {
            return _getImage(url.data);
          }
        } else {
          return Container(
            width: width,
            height: height,
            child: const CircularProgressIndicator(),
          );
        }
      },
    );
  }

  /// Returns the image referenced by the provided URL
  Widget getImageByUrl(String url,
      {int imageNr,
      double width = double.infinity,
      double height,
      BoxFit fit = BoxFit.fitWidth,
      Widget errorWidget,
      AlignmentGeometry copyrightAlignment = AlignmentDirectional.bottomEnd}) {
    return CachedNetworkImage(
      width: width,
      height: height,
      fit: fit,
      imageUrl: url,
      errorWidget: (context, str, error) =>
          errorWidget ?? getImage('default-1', 'error'),
    );
  }

  /// returns the associated download link to the name<br>
  /// Example name: Asthaufen<br>
  /// Example type: biodiversityMeasures
  Future<String> getImageURL(String name, String type, {int imageNr}) async {
    final key = _key(name, imageNr: imageNr);
    var doc = await _storage.database.doc('imageReferences/$key').get();
    if (!doc.exists) {
      final query = _storage.database
          .collection('imageReferences')
          .where('name', isEqualTo: name)
          .where('type', isEqualTo: type)
          .where('order', isEqualTo: imageNr ?? 1);
      final docs = await query.get();
      if (docs.docs.isNotEmpty) {
        doc = docs.docs.first;
      }
    }
    if (!doc.exists || !doc.data().containsKey('downloadURL')) {
      if (name != 'default') {
        final url = await getImageURL('default', '');
        if (url != null) _urls[key] = url;
        return url;
      }
      logging.log('default image source not found', level: 1000);
      return null;
    }
    _urls[key] = doc.data()['downloadURL'];
    return doc.data()['downloadURL'];
  }

  /// returns copyright information about the image associated with that name
  /// and type. <br>
  /// Example name: Asthaufen<br> Example type: biodiversityMeasures
  Future<String> getImageCopyright(String name, {int imageNr}) async {
    final key = _key(name, imageNr: imageNr);
    if (_copyrightInfo.containsKey(key)) {
      return _copyrightInfo[key];
    }
    final doc = await _storage.database.doc('imageReferences/$key').get();
    if (!doc.exists || !doc.data().containsKey('copyright')) {
      if (name != 'default') {
        final copyright = await getImageCopyright('default');
        if (copyright != null) _copyrightInfo[key] = copyright;
        return copyright;
      }
      logging.log('default image copyright not found', level: 100);
      return '';
    }
    _copyrightInfo[key] = doc.data()['copyright'];
    return doc.data()['copyright'];
  }

  /// Handles the upload of an image to firestore.
  /// Any existing image with the same name will be overridden<br>
  /// Returns the download URL of the image. <br>
  /// The bucket parameter will dictate which folder will be used.
  /// Example: user/{USERID} would create a folder user
  /// and for each user id another subfolder
  Future<String> uploadImage(Uint8List file, String bucket,
      {String filename,
      int quality = 80,
      int minImageSize = 500,
      bool compress = true}) async {
    var uploadImage;
    var tempPath;
    tempPath = (await getTemporaryDirectory()).path;
    var tempFile = File('$tempPath/temp.jpeg');
    tempFile.writeAsBytesSync(file);
    if (compress) {
      // Resize image to make sure its smaller than the maxSize
      uploadImage = await FlutterImageCompress.compressAndGetFile(
          tempFile.path, '$tempPath/temp_comp.jpeg', //'${file.path}'
          minHeight: minImageSize,
          minWidth: minImageSize,
          quality: quality);
    } else {
      uploadImage = file;
    }
    // upload of the file
    final reference =
        _storage.fileStorage.ref().child('userUpload/$bucket/$filename');
    final task = reference.putFile(uploadImage);
    final docRef = await task;
    if (compress) {
      File('$tempPath/temp_comp.jpeg').delete();
      // ignore: unawaited_futures
    }
    File('$tempPath/temp.jpeg').delete();
    return await docRef.ref.getDownloadURL();
  }

  /// deletes a image from Storage
  void deleteImage({@required String imageURL}) {
    final ref = _storage.fileStorage.refFromURL(imageURL);
    ref.delete();
  }

  /// returns a list of URLs wich are associated to the given name and type
  Future<List<String>> getListOfImageURLs(
      {@required String name, String type}) async {
    final docs = await _storage.database
        .collection('imageReferences')
        .where('name', isEqualTo: name)
        .where('type', isEqualTo: type)
        .get();
    final urls = <String>[];
    for (final doc in docs.docs) {
      if (doc.data().containsKey('downloadURL')) {
        urls.add(doc.data()['downloadURL'] as String);
      }
    }
    return urls;
  }

  Map<String, String> get copyrightInfo => _copyrightInfo;

  Map<String, String> get caption => _caption;
}
