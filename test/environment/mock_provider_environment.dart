import 'package:biodiversity/models/garden.dart';
import 'package:biodiversity/models/map_interactions_container.dart';
import 'package:biodiversity/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'mock_storage_provider.dart';

Future<void> setUpBiodiversityEnvironment(
    {@required WidgetTester tester,
    @required Widget widget,
    MockStorageProvider storageProvider,
    bool pumpAndSettle = true}) async {
  storageProvider ??= MockStorageProvider();
  await storageProvider.database
      .doc('imageReferences/default-1')
      .set({'downloadURL': 'defaultDownloadURL'});
  await tester.pumpWidget(loadProviders(
    widget: widget,
    storageProvider: storageProvider,
  ));
  if (pumpAndSettle) {
    await tester.pumpAndSettle(const Duration(minutes: 1));
  }
  await tester.idle();
}

Widget loadProviders(
    {@required Widget widget,
    MockStorageProvider storageProvider,
    GlobalKey globalKey}) {
  return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => User.empty(storageProvider: storageProvider),
          lazy: false,
        ),
        ChangeNotifierProvider(
            create: (context) => Garden.empty(storageProvider: storageProvider),
            lazy: false),
        ChangeNotifierProvider(
            create: (context) => MapInteractionContainer.empty(), lazy: false),
      ],
      child: MaterialApp(
        key: globalKey,
        home: widget,
      ));
}
