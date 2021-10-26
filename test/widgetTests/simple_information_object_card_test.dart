import 'package:biodiversity/components/simple_information_object_card_widget.dart';
import 'package:biodiversity/models/biodiversity_measure.dart';
import 'package:biodiversity/models/information_object.dart';
import 'package:biodiversity/models/species.dart';
import 'package:biodiversity/models/take_home_message.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../environment/mock_provider_environment.dart';
import '../environment/mock_service_provider.dart';
import '../environment/mock_storage_provider.dart';

void main() {
  testWidgets('Test fields present', (tester) async {
    final storage = MockStorageProvider();
    final service = MockServiceProvider(storageProvider: storage);
    final attributes = {
      'name': 'testname',
      'title': 'testname',
      'shortDescription': 'Some description...',
      'unit': 'unit...',
      'type': 'dummy',
      'beneficialFor': ['vogel'],
      'goodTogetherWith': ['birds'],
      'dimension': 'dimension..',
      'unusedField': 'xyz'
    };
    final elements = <InformationObject>[];
    elements.add(BiodiversityMeasure.fromMap(attributes,
        storageProvider: storage, serviceProvider: service));
    elements.add(Species.fromMap(attributes,
        serviceProvider: service, storageProvider: storage));
    elements.add(TakeHomeMessage.fromMap(attributes, storageProvider: storage));

    for (final element in elements) {
      await setUpBiodiversityEnvironment(
          tester: tester,
          widget: Scaffold(
            body: SimpleInformationObjectCard(
              element,
              serviceProvider: service,
            ),
          ),
          storageProvider: storage);
      expect(find.text(attributes['title']), findsOneWidget,
          reason: '${element.runtimeType}: title of the card is missing');
      expect(find.byType(CachedNetworkImage), findsOneWidget,
          reason: '${element.runtimeType}: image should be visible');
      expect(find.textContaining('merken'), findsNothing,
          reason: '${element.runtimeType}: '
              'merken button should not be present');
      expect(find.textContaining('hinzufügen'), findsNothing,
          reason: '${element.runtimeType}: '
              'hinzufügen button should not be present');
      expect(find.text(attributes['shortDescription']), findsNothing,
          reason: '${element.runtimeType}: '
              'shortDescription should only in expanded mode be visible');
    }
  });
}
