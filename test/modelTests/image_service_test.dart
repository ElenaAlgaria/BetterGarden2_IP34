import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../environment/mock_provider_environment.dart';
import '../environment/mock_service_provider.dart';
import '../environment/mock_storage_provider.dart';

Future<void> main() async {
  testWidgets('Test get Image', (tester) async {
    final storage = MockStorageProvider();
    final service = MockServiceProvider(storageProvider: storage);
    await storage.database
        .doc('imageReferences/name-1')
        .set({'downloadURL': 'res/Logo_basic.png', 'copyright': 'copyright'});

    await setUpBiodiversityEnvironment(
        tester: tester,
        widget: Scaffold(
          body: service.imageService.getImage('name', 'type'),
        ));
    await tester.pumpAndSettle(const Duration(minutes: 1));
    expect(find.byType(CachedNetworkImage), findsOneWidget,
        reason: 'Image not loaded');
  });

  testWidgets('Test default Image', (tester) async {
    final storage = MockStorageProvider();
    final service = MockServiceProvider(storageProvider: storage);
    await storage.database
        .doc('imageReferences/default-1')
        .set({'downloadURL': 'res/Logo_basic.png', 'copyright': 'copyright'});

    await setUpBiodiversityEnvironment(
        tester: tester,
        widget: Scaffold(
          body: service.imageService.getImage('name', 'type'),
        ));
    await tester.pumpAndSettle(const Duration(minutes: 1));
    expect(find.byType(CachedNetworkImage), findsOneWidget,
        reason: 'Default image not loaded');
  });

  testWidgets('Image not found', (tester) async {
    final service = MockServiceProvider();
    await setUpBiodiversityEnvironment(
        tester: tester,
        pumpAndSettle: false,
        widget: Scaffold(
          body: service.imageService.getImage('random', 'type'),
        ));
    expect(find.byType(CircularProgressIndicator), findsOneWidget,
        reason: 'If no image is found, a Progress Indikator should be shown');
  });

  test('test get copyright string', () async {
    final storage = MockStorageProvider();
    final service = MockServiceProvider(storageProvider: storage);
    await storage.database
        .doc('imageReferences/name-1')
        .set({'copyright': 'testCopyright'});
    final copyright = await service.imageService.getImageCopyright('name');
    expect(copyright, 'testCopyright',
        reason: 'correct copyright was not loaded');
  });

  test('test default copyright string', () async {
    final storage = MockStorageProvider();
    final service = MockServiceProvider(storageProvider: storage);
    await storage.database
        .doc('imageReferences/default-1')
        .set({'copyright': 'defaultCopyright'});
    final copyright =
        await service.imageService.getImageCopyright('randomName');
    expect(copyright, 'defaultCopyright',
        reason: 'default copyright was not loaded');
  });

  test('test getImageUrl', () async {
    final storage = MockStorageProvider();
    final service = MockServiceProvider(storageProvider: storage);
    await storage.database
        .doc('imageReferences/default-1')
        .set({'downloadURL': 'defaultDownloadURL'});
    final defaultUrl = await service.imageService.getImageURL('name', 'type');
    expect(defaultUrl, 'defaultDownloadURL',
        reason: 'Default URL was not loaded');
    await storage.database
        .doc('imageReferences/name-1')
        .set({'downloadURL': 'specificURL'});
    final url = await service.imageService.getImageURL('name', 'type');
    expect(url, 'specificURL',
        reason: 'Url of specific element was not returned');
  });
}
